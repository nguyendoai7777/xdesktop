# materiant-gd1_06 — Vùng cuộn + danh sách ảo

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- `ScrollArea` kiểu `scroll` của materiant trên `gpui_base::Scrollbar`: thanh mảnh, hiện khi rê / khi đang cuộn rồi ẩn
  sau trễ, kéo thumb được, dọc + ngang.
- `VirtualList` trên `gpui_base::VirtualList` (hoặc `uniform_list` của gpui-pre nếu gọn hơn — ghi lý do mục 9): dòng
  cùng cao, chọn dòng bằng ↑ ↓ / PageUp / PageDown / Home / End, cuộn để dòng chọn luôn trong khung, `on_activate`
  (Enter / nhấp đúp).
- `scroll_to(ix, Align)` cho app (launcher lọc xong nhảy về đầu).

## 2. Không làm trong task này

- Dòng khác cao nhau (`virtual-row-measure`) — chỉ ghi nợ nếu GĐ2 cần (lịch sử ảnh). Không sửa `style.rs`.

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

- C1 `[opus-unit]` `ListNav`: ↓ ở cuối đứng yên, PageDown nhảy đúng `page`, Home / End, `count = 0` không chọn gì.
- C2 `[opus-unit]` vị trí cuộn để dòng chọn hiện (trên / dưới khung / đã trong khung) theo `virtual-target.util.spec`.
- C3 `[opus-run]` gallery 10 000 dòng: số RAM mục 5; thanh cuộn hiện khi rê, ẩn sau trễ, kéo thumb được.
- C4 `[owner-qa]` cuộn bằng touchpad + bánh xe trên màn 144 Hz mượt.

## 7. Ghi chú UI

Trang `scroll`: trái — ScrollArea chứa đoạn văn dài + bảng rộng (cuộn ngang); phải — VirtualList 10 000 dòng có ô
nhập số "nhảy tới dòng".

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
