# materiant-gd1_09 — Dropdown (select), Tabs, Toast

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | M — ~800 dòng |
| Phụ thuộc | materiant-gd1_03 (nút đóng của toast) · **song song** với gd1_07 / gd1_08 (và gd1_04–06 nếu chưa xong) |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/select.rs` · `src/tabs.rs` · `src/toast.rs` SỬA · `examples/gallery/pages/{select,tabs,toast}.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10. Nếu lúc làm gd1_06 (cuộn) đã xong thì danh
sách của dropdown dùng `ScrollArea`; chưa xong thì dùng thanh cuộn mặc định của gpui-base + ghi mục 8.

## 0. Bàn giao từ materiant-gd1_03 (30/10/2026)

<!-- handoff: materiant-gd1_03 -->

- **Đã có sẵn để dùng**: nút đóng toast = `materiant::button::IconButton::new(id, IconName::CloseThin).size(Size::Sm)
  .accessibility_label(…)` (dáng `text`, màu mặc định `primary`; trên toast nhiều màu thì `.color(ink_của_toast)` hoặc
  `.base()`); bo tròn `.rounded_full()`. `Size::{Lg, Md, Sm}.height()` = 38 / 32 / 24 px — dùng cho chiều cao Select
  để đứng thẳng hàng với nút.
- Màu theo loại toast: `Accent::{Primary, Success, Warning, Danger}.tokens(cx)` + bảng thuần
  `ButtonPaint::resolve(Variant::Tonal, …)` nếu muốn toast nền nhạt cùng bậc thang với nút `tonal`.
- Nút có ripple + vòng focus bàn phím sẵn; nút trong toast `loading` / `disabled` tự bỏ khỏi Tab.
- **Bẫy**: chữ trong khung `line_height = 1` (trigger của Select, nhãn Tab) trông thấp ~2 px — xem `button::optical_lift`
  (pub(crate), dời lên `style.rs` ở gd1_10); `TextSystem::descent` của DirectWrite là số âm. GPUI sinh click bàn phím ở
  KeyUp ⇒ UI test gửi cả KeyDown + KeyUp (`press()` trong `ui-tests/tests/button.rs`); `--keys` của gallery chỉ KeyDown.
- **Bẫy build**: worktree dùng chung `CARGO_TARGET_DIR` đè rlib `materiant` của nhau khi build cùng lúc ⇒ target riêng
  khi có làn khác đang build.
- **Soát lại khi làm**: trang gallery `button`; `completed/materiant/gd1/materiant-gd1_03_button-kbd.md` mục 9 (API đầy đủ).

## 0. Bàn giao từ materiant-gd1_06 (30/10/2026)

<!-- handoff: materiant-gd1_06 -->

- **Đã có sẵn để dùng**: danh sách thả của `Select` dài ⇒ `materiant::list::scroll_top_for_index(…, Align::Nearest)` /
  `VirtualListHandle::scroll_to(ix, Align::Nearest)` để mục đang trỏ luôn lọt khung; `ListNav::apply` (↑ ↓ PageUp PageDown
  Home End, KHÔNG vòng, kẹp, `count = 0` ⇒ `None`). Bọc danh sách ngắn bằng `ScrollArea::new(id).vertical().max_h(…)`;
  `Scrollbar` tự dựng ⇒ `materiant::scroll::scrollbar_styles(cx.scrollbar_tokens())`.
- **Khác cần chú ý**: `ListNav` không vòng (đúng danh sách / launcher); typeahead chưa có ở `list.rs` — viết trong
  `select.rs`.
- **Bẫy đã gặp**: GPUI chạy action của key binding TRƯỚC `on_key_down` ⇒ ↑ ↓ / Enter của Select phải là action trong
  `key_context` riêng (sâu hơn cha nên thắng ↑ ↓ đổi trang của gallery); mẫu `materiant::list::bind_keys` + test
  `keys_move_selection_and_keep_it_visible` (`ui-tests/tests/scroll.rs`) gán ↓ ở view cha để soát.
- **Bẫy đã gặp**: build ở `CARGO_TARGET_DIR=materiant/target/<task>` riêng; `gallery-run.ps1 -Exe … -Out …` riêng.

## 1. Làm gì

- `Select` trên `gpui_base::Select`: đóng / mở bằng Enter / Space / ↓, ↑ ↓ chọn, typeahead (gõ chữ nhảy tới mục),
  disabled, có `FieldShell`-like nhãn (dùng lại style của gd1_04 chỉ khi đã gộp — không thì tự vẽ khung, ghi nợ).
- `Tabs`: ngang + dọc (sidebar Settings của fastcast), vạch chỉ báo (`tab-ink`) trượt, ← → / ↑ ↓ đổi tab, Home / End.
- `Toast`: hàng đợi chồng nhiều cái ở góc cửa sổ, tự ẩn sau thời gian (dừng đếm khi rê chuột), nút đóng
  (`IconButton`), loại `info` / `success` / `warning` / `danger`, animate vào / ra. App gọi `Toast::push(window, cx, …)`.

## 2. Không làm trong task này

- Tabs nhớ trạng thái theo URL (`query-memory`) — đặc thù web, bỏ. Select nhiều lựa chọn / có ô tìm — GĐ2 nếu cần.
- Không sửa `style.rs` / `icon.rs`.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `src/select.rs`, `src/tabs.rs`, `src/toast.rs` (logic thuần + component + unit test C1–C3) | `[opus]` |
| Test UI `ui-tests/tests/{select,tabs,toast}.rs` (bàn phím / focus / hàng đợi toast trong App ảo) | `[opus]` |
| Trang gallery `examples/gallery/pages/{select,tabs,toast}.rs` (ghép từ API đã chốt) | `[sonnet]` |
| Chạy thử gallery (C4), soát sáng / tối | `[opus-run]` |
| So với tài liệu web (C5) | `[owner-qa]` |

## 3. Interface

`Select::new(id, cx).items(…).selected(ix).on_change(…)`; `Tabs::new(id).vertical().tab(…).selected(ix)
.on_change(…)`; `Toast::push(window, cx, ToastSpec { kind, message, duration })`; bộ đếm giờ toast là hàm thuần
(`ToastTimer` tạm dừng / tiếp).

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\` — `form/ui/src/lib/dropdown/` (+ `dropdown-field`); `tabs/src/lib/`
  (`tab-group.ts`, `tab-nav.ts`, `tab-ink.ts`, `tabs.util.ts` + spec, `tabs.css`, `tab-bar/`); `toast/src/lib/`
  (`toast.service.ts`, `toast-timer.ts` + spec, `toast-ref.ts` + spec, `toast-viewport.ts`, `toast*.css`,
  `toast-item/`, `toast-message/`).

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho danh sách `Apple, banana, Blueberry, !Blackberry, Cherry, Bread` · Khi gõ `b` / `B` / `bb` /
  `bbb` / `bl` · Thì chọn mục đầu khớp tiền tố (không phân biệt hoa thường), gõ lại cùng chữ đi mục kế, bỏ mục tắt,
  quay vòng; nghỉ ≥ 500 ms thì chuỗi mới (`select::tests`).
- C2 `[opus-unit]` Cho `ToastTimer` 1000 ms · Khi rê (pause) rồi rời (resume) · Thì đang dừng không hết giờ, tiếp ⇒
  đếm lại đủ 1000 ms (đúng `toast-timer.spec.ts` "restart full duration" — xem mục 9); `None` / 0 không bao giờ hết
  giờ (`toast::tests`).
- C3 `[opus-unit]` Cho tabs có tab tắt · Khi ← → Home End · Thì bỏ tab tắt, quay vòng, Home / End về tab bật đầu /
  cuối — theo `tabs.util.spec.ts` (`tabs::tests`).
- C4 `[opus-run]` + `[opus]` test UI · Cho gallery · Khi đẩy 5 toast liên tiếp · Thì chồng cũ trên mới dưới, tự ẩn
  sau 5 s; tabs ngang (← →) + dọc (↑ ↓) đổi bằng phím, ↑ ↓ của gallery không đổi trang khi thanh dọc có focus; Select
  mở bằng Enter / ↓, ↑ ↓ + Enter chọn, Esc đóng, typeahead khi đóng chọn luôn.
- C5 `[owner-qa]` so ba trang với tài liệu materiant web ở sáng / tối.

## 7. Ghi chú UI

Trang `select`: vài dropdown (thường, disabled, 50 mục). Trang `tabs`: tabs ngang trên, tabs dọc trái. Trang `toast`:
bốn nút đẩy bốn loại toast.

## 8. Nợ chuyển task khác

- → materiant-gd1_10: dropdown của `Select` đang neo bằng `gpui_kit::base::Popup` trực tiếp (chưa lật lên khi thiếu chỗ
  phía dưới, chưa vào chồng tầng) ⇒ chuyển sang Popover / định vị của gd1_07.
- → gd1_10: `ToastViewport` do app tự đặt ở view gốc ⇒ cân nhắc `RootPlugin` đăng ký trong `materiant::init` (sửa
  `lib.rs`) để app khỏi đặt; khi đó gallery `main.rs` bỏ `ToastViewport` khỏi trang toast.
- → gd1_10: hằng cục bộ dời lên `style.rs` — mục dropdown 36 / bo 6 / nền con trỏ 10 %, panel bo 8 / đệm 4 / cao 240,
  tab đệm 10 × 16 / vạch 2 px 250 ms, toast bo 18 / khe 12 / rộng 420 / nhịp 450-300-220 ms; icon đặc của toast (vòng
  tròn + nét, cảnh báo là tam giác ở web) ⇒ `icon.rs`.
- → gd1_10: `FieldShell` chưa bọc được ô kiểu nút (ép `cursor_text`, nhãn / gợi ý nằm trong vùng neo) ⇒ tách
  `FieldLabel` / thêm `.cursor(..)` để `Select` dùng lại thay cho bản tự vẽ.
- GĐ2 nếu cần: Tabs cuộn ngang khi tràn; Select nhiều lựa chọn / ô tìm / nút xoá; toast vuốt để đóng.

## 9. Bàn giao thực tế

- **API** (doc đầu mỗi tệp có ví dụ):
  - `materiant::select::{Select, SelectItem}` — `Select::new(id).label(..).placeholder(..).hint(..).items(iter)
    .selected(Option<usize>).on_change(|&usize, w, cx|).disabled(bool).w(..)`; RenderOnce, state (mở / con trỏ /
    typeahead / focus) theo id. Hàm thuần: `first_match_index`, `typeahead_match`, `Typeahead` (500 ms).
    `KEY_CONTEXT = "MateriantSelectList"` (Home / End); ↑ ↓ Enter Space Esc là của `gpui_base::Select`.
  - `materiant::tabs::{Tabs, TabItem, TabKey}` — `Tabs::new(id).vertical()?.tab(..).tabs(..).selected(ix)
    .on_change(..)`; chỉ là thanh tab (nội dung app vẽ). Hàm thuần `next_enabled_index`, `target_index`,
    `resolve_selected` (port `tabs.util.ts`). `KEY_CONTEXT` / `KEY_CONTEXT_VERTICAL`.
  - `materiant::toast::{Toast, ToastSpec, ToastKind, ToastPlacement, ToastViewport, ToastTimer, ToastId}` —
    `Toast::push(window, cx, ToastSpec::new(kind, msg).title(..).duration(Option<Duration>)) -> ToastId`,
    `Toast::dismiss`, `Toast::dismiss_all`, `Toast::count`; app đặt MỘT `ToastViewport::new()` ở view gốc.
- **Lệch spec có chủ đích** (đã ghi `plan/confirm.md`): `Select::new(id)` không `cx`; `ToastTimer.resume` đếm lại đủ
  thời lượng (đúng `toast-timer.spec.ts`, C2 cũ ghi "phần còn lại" là đọc nhầm spec); Select tự vẽ khung theo
  `field_tokens()` thay vì bọc `FieldShell`; tối đa 5 toast; không `scale` / blur (GPUI không có cho `div`).
- **Bẫy đã gặp**: `window.refresh()` gọi trong lúc vẽ (callback `on_prepaint` đo kích thước) bị BỎ QUA
  (`invalidator.not_drawing()`) ⇒ toast mới đẩy chỉ hiện khi có sự kiện khác, vạch tab không theo số đo — dùng
  `window.request_animation_frame()`. Test UI không bắt được vì `frame()` tự `refresh()`; chỉ chạy gallery mới thấy.
  Cửa sổ test chưa focus gì thì action Tab của `Root` không chạy ⇒ test focus view gốc trước.
  `gpui_base::Select` gọi `content_focus.focus()` SAU handler Confirm ⇒ trả focus về trigger bằng `window.defer`.
  `gpui_base::Select` không phải `InteractiveElement` ⇒ ↑ ↓ đặt trên danh sách, typeahead trên lớp bọc ngoài.
- **Soát xanh** (cwd worktree, `CARGO_TARGET_DIR=materiant/target/gd1_09`): `cargo build`, `cargo clippy --all-targets
  -- -D warnings`, `cargo test` (unit mới: select 4, tabs 4, toast 7; UI mới: select 5, tabs 2, toast 3),
  `cargo deny check licenses` — xanh.
- **Chạy thật C4** (`tools/gallery-run.ps1`, exe release riêng, không giành focus): Push 5 ⇒ 5 toast chồng cũ trên mới
  dưới ở góc trên phải, hiện ngay, hết 5 s ra và gỡ; rê lên toast 2 ⇒ chỉ nó ở lại, các cái khác ra, nó trượt lên;
  ✕ hiện khi rê. Tabs: Tab + → → ⇒ `TAB horizontal 1, 2`, End ⇒ 4; thanh dọc ↓ ↓ ↑ ⇒ 1, 2, 1, KHÔNG đổi trang gallery.
  Select: 50 mục Enter End ↑ Enter ⇒ `Item 49`, con trỏ lọt khung; City đóng gõ `h` ⇒ Hà Nội, `hu` ⇒ Huế. Sáng / tối
  đúng màu. RAM gallery 13,7–16 MB ở ba trang. Ảnh đã xoá.
- **Đề xuất đã làm** (D-8): `ToastViewport::inset_top(px)` — chừa header tự vẽ của app; trang toast của gallery chừa
  44 px nên toast không đè nút đổi theme.
- **Chờ kiểm tay** (C5 `[owner-qa]`): `pwsh start.ps1 docs select` / `tabs` / `toast` — so với trang tài liệu web ở
  sáng / tối (nhịp vạch tab, lò xo vào của toast, panel dropdown).

## 10. Đề xuất cải tiến

Soi bốn lăng kính trên diff + luồng người dùng:

- Bảo mật / riêng tư: không áp (không IPC, không tệp, không chụp màn).
- RAM / hiệu năng: hàng đợi toast gỡ khỏi `Global` khi hết toast; lúc toast đứng yên chỉ có MỘT `Timer` hẹn tới mốc
  gần nhất, không xin khung (đã soát: không dòng `FRAMES` nào lúc nghỉ). Không phát hiện vấn đề.
- [ux] Dropdown của Select không lật lên khi gần đáy cửa sổ — bằng chứng: `Popup` chỉ `TopLeft` + snap mép
  (`select.rs`, `Popup::new(..).anchor(Anchor::TopLeft)`) — đề xuất: dùng Popover / định vị lật của gd1_07 — giá trị:
  Select ở cuối form không bị che — S — P1 — **không làm trong lượt**: thuộc làn gd1_07 đang chạy song song, đã ghi
  mục 8 → gd1_10.
- [ux] Toast phủ lên thanh tiêu đề tự vẽ của app (offset 24 px tính từ mép cửa sổ, như web) — bằng chứng: gallery,
  toast đầu đè nút "System" — đề xuất: `ToastViewport::inset_top(px)` cho app có header — giá trị: không che nút
  header — S — P3 — **đã làm** (mục 9).
- [pro] Không áp cho ba component nền.
