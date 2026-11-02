# materiant-gd5_04 — VirtualGrid

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/virtual_grid.rs`, `examples/gallery/pages/virtual_grid.rs`; MỚI `ui-tests/tests/virtual_grid.rs` |

## 1. Làm gì
- `materiant::virtual_grid::VirtualGrid`: ô cùng cỡ, số cột tự tính theo bề ngang + cỡ ô tối thiểu + `gap`, chỉ dựng hàng trong khung. Dựa trên `uniform_list` như `src/list.rs` (mỗi hàng ảo là một dòng), dùng lại scrollbar `scrollbar_styles`.
- Đổi cỡ cửa sổ thì tính lại số cột, giữ ô đang chọn trong khung.
- Bàn phím: ← → ↑ ↓, PageUp / PageDown, Home / End; Enter / nhấp đúp ⇒ `on_activate`. Handle `scroll_to(index, Align)`.
- Trang gallery `virtual_grid`: 10.000 ô có ảnh giữ chỗ. Đo RAM và khung hình khi cuộn so với 100 ô, ghi ở mục 5: RAM không được tăng theo số ô.
- Ảnh bìa: tìm hiểu cache `img()` của GPUI có nhả ảnh ra khỏi khung không; ghi kết quả + cách app nên dùng ở mục 9 (groove có lưới album lớn).
- Test logic thuần (số cột, ô → hàng, điều hướng ở biên) trong module; test bàn phím trong `ui-tests/`.

## 2. Không làm trong task này
- Ô khác cỡ (masonry), kéo thả. Không sửa `src/list.rs` trừ khi dùng lại được mà không đổi API.
