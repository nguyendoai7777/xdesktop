# materiant-gd2_01 — bảng chọn màu

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | materiant GĐ1 |
| Quyết định áp dụng | D-6, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `src/color_picker.rs`, `examples/gallery/pages/color_picker.rs`; SỬA `src/lib.rs`, `examples/gallery/{main,pages/mod}.rs` |

## 1. Làm gì

- `ColorPicker` có state: ô bão hoà / độ sáng (HSV), thanh sắc độ, ô hex, hàng màu mẫu do app truyền, phát `ColorPickerEvent::Change`.
- Kéo ra ngoài ô vẫn bám; bàn phím: mũi tên chỉnh ô đang focus; không chữ cố định (app truyền nhãn).
- Đổi HSV ↔ RGB ↔ hex là hàm thuần có test. Trang gallery, sáng / tối.

## 2. Không làm trong task này

Kênh alpha, OKLCH, lưu bảng màu.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

`cargo clippy`, `cargo test`, `cargo deny check licenses` xanh; trang gallery đúng cả sáng / tối.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
