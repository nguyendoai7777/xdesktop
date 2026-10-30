# materiant-gd1_06 — Vùng cuộn + danh sách ảo

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_03, gd1_04, gd1_05 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/scroll.rs` · `src/list.rs` SỬA · `examples/gallery/pages/scroll.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10 + fastcast `gd1_06` (launcher) qua mục 9.

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `cx.scrollbar_tokens()` → `ScrollbarTokens { thumb, thumb_hover }` — `muted` ở alpha 0,45, hover
  × `SCROLLBAR_THUMB_HOVER_ALPHA_SCALE` (1,35). Khác web: web viết cứng xám trung tính, ở đây theo `muted` của theme.
- Dòng chọn của `VirtualList`: nền gợi ý `c.neutral(Neutral::N100)` / chọn `N200` như sidebar gallery, hoặc
  `Accent::Primary.tokens(cx).ghost_hover` / `.tonal` nếu cần màu nhấn — chưa có token riêng ⇒ hằng cục bộ + mục 8.
- Ripple trên dòng (nếu làm): `.ripple(RippleConfig::default())` trên `Stateful<Div>` của dòng — lớp ripple chỉ xin
  khung khi đang chạy, không tốn gì với dòng đứng yên.
- Icon cần: `ChevronUp` / `ChevronDown` (nếu có nút cuộn).
- **Bẫy**: toạ độ chuột giả lập (`down@x,y`) là toạ độ logic trong cửa sổ; cuộn bằng con lăn chưa giả lập được trong
  `--keys` ⇒ test `#[gpui::test]` (`simulate_event(ScrollWheelEvent)`) trong `ui-tests/tests/scroll.rs`.
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `completed/materiant/gd1/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- `ScrollArea` kiểu `scroll` của materiant trên `gpui_base::Scrollbar`: thanh mảnh, hiện khi rê / khi đang cuộn rồi ẩn
  sau trễ, kéo thumb được, dọc + ngang.
- `VirtualList` trên `gpui_base::VirtualList` (hoặc `uniform_list` của gpui-pre nếu gọn hơn — ghi lý do mục 9): dòng
  cùng cao, chọn dòng bằng ↑ ↓ / PageUp / PageDown / Home / End, cuộn để dòng chọn luôn trong khung, `on_activate`
  (Enter / nhấp đúp).
- `scroll_to(ix, Align)` cho app (launcher lọc xong nhảy về đầu).

## 2. Không làm trong task này

- Dòng khác cao nhau (`virtual-row-measure`) — chỉ ghi nợ nếu GĐ2 cần (lịch sử ảnh). Không sửa `style.rs`.

## 2b. Phân vai

| Phần việc | Vai |
|---|---|
| `src/scroll.rs` (ScrollArea, style thanh cuộn) · `src/list.rs` (VirtualList, `ListNav`, `scroll_top_for_index`, phím) | `[opus]` |
| `examples/gallery/pages/scroll.rs` · `ui-tests/tests/scroll.rs` | `[opus]` — nhỏ, bám interface vừa chốt, giao Sonnet không lợi |
| Cuộn touchpad / bánh xe thật trên màn 144 Hz | `[owner-qa]` |

## 3. Interface

`ScrollArea::new(id).vertical().horizontal().child(…)`; `VirtualList::new(id, count, row_height, render_row)
.selected(ix).on_select(…).on_activate(…)`; trạng thái chọn là hàm thuần `ListNav::apply(key, ix, count, page) -> ix`.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\scroll\src\lib\` (`scrollable*.ts`, `scrollable.const.ts` cho số đo, hai
  `*.spec.ts`) và `virtual-scroll\src\lib\virtual-scroll\` (`virtual-anchor.util.ts`, `virtual-jump.ts`,
  `virtual-target.util.ts` + spec).
- Mẫu danh sách đã chạy ở launcher spike: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs`.

## 5. Đo

- Gallery 10 000 dòng: RAM (Task Manager) lúc mở trang và sau khi cuộn hết — không tăng theo số dòng; cuộn không khựng.

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho `ListNav::apply` · Khi ↓ ở dòng cuối / PageDown với `page` / Home / End / `count = 0` · Thì
  đứng yên / nhảy đúng `page` (kẹp cuối) / dòng đầu / dòng cuối / `None`. Kèm `[opus-unit]` UI: danh sách thật có focus,
  phím đổi dòng chọn, ↓ gán ở view cha không chạy.
- C2 `[opus-unit]` Cho `scroll_top_for_index` (khung 300, dòng 30, 1000 dòng) · Khi dòng trên / dưới / đã trong khung,
  `Start` / `Center` / `End` · Thì đúng số của `virtual-scroll.util.spec.ts` (2700 / 3330 / 3000, 3000 / 2865 / 2730).
- C3 `[opus-run]` Cho gallery trang `scroll` 10 000 dòng · Khi mở trang rồi End (cuộn hết) · Thì RAM không tăng theo số
  dòng (mục 5); thanh cuộn hiện khi rê / cuộn, ẩn sau trễ; kéo thumb cuộn (`[opus-unit]` UI: `dragging_thumb_scrolls`).
- C4 `[owner-qa]` Cho màn 144 Hz · Khi cuộn bằng touchpad + bánh xe · Thì mượt, không khựng.

## 7. Ghi chú UI

Trang `scroll`: trái — ScrollArea chứa đoạn văn dài + bảng rộng (cuộn ngang); phải — VirtualList 10 000 dòng có ô
nhập số "nhảy tới dòng".

## 8. Nợ chuyển task khác

- gd1_10: `list::bind_keys(cx)` vào `materiant::init` (hiện gán lười ở lần vẽ danh sách đầu — `lib.rs` cấm sửa ở làn
  song song). Hằng `ROW_RADIUS` 6 / `LIST_RADIUS` 8 (`list.rs`) và `THUMB_THICKNESS` / `THUMB_INSET` / `TRACK_THICKNESS` /
  `THUMB_MIN_LENGTH` (`scroll.rs`) ⇒ dời lên `style.rs` nếu component khác cần.
- gd1_10: nhịp thanh cuộn là của theme `gpui_base` toàn cục (`Theme::scrollbar.motion`), không đặt riêng từng thanh
  được ⇒ `theme/` đồng bộ `ScrollbarMotion::default().with_idle(1 s).with_enter(160 ms).with_exit(160 ms)` cho đúng web
  (`SCROLLABLE_AUTO_HIDE_DELAY_DEFAULT` 1000 ms, `transition: opacity 160ms`). Hiện: ẩn sau 2 s, hiện / ẩn tức thì.
- gd1_08 (`Menu`): ↑ ↓ của menu QUAY VÒNG + bỏ qua mục disabled — không dùng thẳng `ListNav` (không vòng); bẫy phím
  action-trước-`on_key_down` như khối bàn giao ở gd1_07 / gd1_09.
- **Cho fastcast** `gd1_06` (launcher): API thật ở mục 9 — `VirtualList` + `VirtualListHandle::navigate` (ô tìm giữ
  focus) + `scroll_to(0, Align::Start)` sau khi lọc; spec ghi `ListNav::apply(…) -> ix` ⇒ thật là `Option<usize>`.

## 9. Bàn giao thực tế

- **API** (`materiant::scroll`, `materiant::list`):
  - `ScrollArea::new(id).vertical().horizontal().scrollbar_visibility(…).track_scroll(&ScrollHandle)` + `Styled` (cỡ
    khung) + `ParentElement`. `ScrollbarVisibility::{Hover (mặc định), Scrolling, Always}`. `scroll::scrollbar_styles(
    cx.scrollbar_tokens())` = style thanh materiant cho `gpui_base::Scrollbar` tự dựng.
  - `VirtualList::new(id, count, row_height, |ix, window, cx| nội_dung).track(&VirtualListHandle).track_focus(&focus)
    .selected(Option<usize>).on_select(|ix, w, cx|).on_activate(…).scrollbar_visibility(…)` + `Styled`. Khung dòng
    (cao, nền rê N100 / chọn N200, bo 6, ripple, nhấp chọn + lấy focus, nhấp đúp ⇒ `on_activate`) do danh sách lo;
    `render_row` chỉ dựng nội dung. Có focus: vòng focus quanh khung (`ring_overlay`).
  - `VirtualListHandle`: `scroll_to(ix, Align::{Start, Center, End, Nearest})`, `navigate(ListKey, selected, count)`
    (cho launcher: ô nhập giữ focus — `ListKey::from_key(&keystroke.key)`), `page_rows()`, `scroll_top()`,
    `scroll_handle()`. `scroll_to` trước khung đầu ⇒ để `uniform_list` cuộn lúc dàn trang.
  - Hàm thuần: `ListNav::apply(key, Option<usize>, count, page) -> Option<usize>` (không vòng, kẹp, `count = 0` ⇒
    `None`), `scroll_top_for_index(ix, count, row_h, viewport_h, scroll_top, align)` (port `scrollTopForIndex`),
    `page_rows(viewport_h, row_h)`.
  - Phím: action `virtual_list::{SelectPrev, SelectNext, SelectPageUp, SelectPageDown, SelectFirst, SelectLast,
    Activate}` trong ngữ cảnh `list::KEY_CONTEXT` = `"VirtualList"`; Enter không có dòng chọn ⇒ nhả cho cha.
- **Chọn `uniform_list` thay `gpui_base::VirtualList`**: dòng cùng cao ⇒ chỉ cần số dòng; bản gpui-base đòi
  `Rc<Vec<Size>>` một phần tử mỗi dòng + `Entity` view. `gpui_base::Scrollbar` nhận sẵn `UniformListScrollHandle`.
- **Phím bằng action, không `on_key_down`**: GPUI chạy action của key binding TRƯỚC listener phím ⇒ `on_key_down` không
  chặn được ↑ ↓ của view cha; ngữ cảnh `VirtualList` sâu hơn nên thắng (test `keys_move_selection_and_keep_it_visible`
  gán ↓ ở cha để soát).
- **Số đo thanh cuộn theo web**: thumb 6 px, hở mép ngoài 3 px, vùng bắt chuột 9 px, thumb ≥ 24 px, tròn đầu, không
  phình khi rê; màu `ScrollbarTokens` (thumb / rê + kéo thumb = `thumb_hover`). Khác web: rê TRACK không đậm thumb (gpui-base
  chỉ có style thumb khi rê thumb), nhịp ẩn 2 s + không fade (mục 8).
- **Soát** (cwd worktree, `CARGO_TARGET_DIR=materiant/target/gd1_06`): `cargo build`, `cargo clippy --all-targets -- -D
  warnings`, `cargo test` (38 unit = 25 cũ + 13 mới; UI: 5 ripple + 4 theme + **7 scroll** + 1 gallery), `cargo deny
  check licenses` ok, `cargo tree -i gpui-component` không có.
- **C1 / C2** ✅ unit (`list::tests`, số khớp `virtual-scroll.util.spec.ts`) + UI (`ui-tests/tests/scroll.rs`: phím, Enter,
  rỗng, `scroll_to` 4 kiểu + `navigate`, nhấp / nhấp đúp, bánh xe danh sách + vùng cuộn 2 trục, kéo thumb).
- **C3** ✅ `gallery-run.ps1 -Page scroll` (exe release chép riêng): RAM mở trang **18,1 MB**, sau End (dòng 10 000) +
  nhảy 5000 **18,5 MB** (lượt khác 19,4 — dao động, không theo số dòng). Log: `SELECT 2 → 9999 → 9989 → 0 → 10`,
  `ACTIVATE 10`, `JUMP 4999`. Ảnh: rê khung ⇒ thumb hiện; kéo thumb 85 px ⇒ cuộn tới đoạn 5; End / PageDown ⇒ thumb
  hiện; rời khung + 2,6 s ⇒ ẩn. `foreground_unchanged=True`. Ảnh đã xoá. Máy một màn ⇒ mở ở màn chính, không giành focus.
- **C4** `[owner-qa]` chờ kiểm tay: `pwsh start.ps1` (hoặc `cargo run --example gallery -- --page scroll`) trên màn
  144 Hz, cuộn bằng touchpad + bánh xe ở cả ba khung — phải mượt; kéo thumb danh sách 10 000 dòng.
- **Bẫy gặp**: 4 worktree chung `CARGO_TARGET_DIR` ghi đè `libmateriant-*.rlib` của nhau (cargo băm path-crate theo
  đường dẫn tương đối) ⇒ lỗi giả `E0432` / `LNK1104`, hoặc `Fresh` mà là bản làn khác ⇒ session cha đổi luật: target riêng
  mỗi worktree.
- **Đề xuất đã làm** (D-8, tự chọn khi chủ dự án vắng): `VirtualListHandle::navigate` — launcher điều hướng bằng một lời
  gọi khi ô nhập giữ focus (thay vì tự ghép `ListNav::apply` + `page_rows` + `scroll_to`).

## 10. Đề xuất cải tiến

- [ux] Nhịp thanh cuộn lệch web — ẩn sau 2 s (web 1 s), hiện / ẩn tức thì (web fade 160 ms) — `gpui-base`
  `ScrollbarMotion::default()` — đặt motion ở `theme/` — gần web, đỡ "nháy" — S — P2. **Chưa làm**: `theme/` cấm sửa ở
  làn song song ⇒ mục 8 → gd1_10.
- [ux] Launcher cần điều hướng khi ô nhập giữ focus — `list.rs` — `VirtualListHandle::navigate` — đỡ app tự ghép 3
  bước — S — P1. **Đã làm.**
- [ux] PageDown kiểu hệ điều hành (lần đầu tới dòng cuối đang thấy, lần sau mới nhảy trang) — `ListNav::apply` nhảy
  thẳng `page` dòng — cần dòng đầu đang thấy — S — P3. **Bỏ**: bản web cũng nhảy thẳng; launcher ít dòng.
- [ux] `gallery-run.ps1` mặc định `-Exe` = `<repo>/target/release/…` — sau luật target riêng thì trỏ nhầm exe —
  `tools/gallery-run.ps1:21` — đọc `$env:CARGO_TARGET_DIR` trước — chạy thử đúng bản — S — P1. **Không làm ở đây**: ngoài
  danh sách tệp của làn; báo session cha (đang sửa luật target).
- [bảo mật] không áp (không đọc / ghi tệp, không IPC). [ram] không áp thêm — RAM không theo số dòng (C3).
  [pro] không áp.
