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
