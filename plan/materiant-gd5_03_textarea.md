# materiant-gd5_03 — TextArea

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~250 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/field/textarea.rs`, `src/field/mod.rs` (`pub use`), `examples/gallery/pages/input.rs`; MỚI `ui-tests/tests/textarea.rs` |

## 1. Làm gì
- `materiant::field::TextArea`: như `TextField` (`src/field/input.rs`), dùng lại `FieldShell`, cùng `FieldEvent`, trên `InputState` của gpui-base chế độ nhiều dòng (`rows`, `auto_grow(min, max)` — xem `state.rs` của `gpui-base` 0.8.1).
- Số dòng cố định hoặc tự giãn trong khoảng; cuộn khi vượt. Enter xuống dòng; Ctrl+Enter phát `FieldEvent` gửi.
- Dán lời bài hát dài (5.000 dòng) không đơ: đo và ghi ở mục 5.
- Gõ tiếng Việt qua bộ gõ: thêm vào danh sách `[owner-qa]`.
- Thêm phần `TextArea` vào trang gallery `input`, đúng cả sáng / tối. Test bàn phím / focus trong `ui-tests/`.

## 2. Không làm trong task này
- Tô màu cú pháp, đánh số dòng, trình soạn thảo của gpui-base (ROADMAP: không port editor).
