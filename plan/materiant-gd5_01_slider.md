# materiant-gd5_01 — Slider

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-10, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/slider.rs`, `examples/gallery/pages/slider.rs`; MỚI `ui-tests/tests/slider.rs` |

## 1. Làm gì
- `materiant::slider::Slider` dựng trên `gpui_kit::base` slider (`SliderState`, `Slider`, `SliderTrack`, `SliderIndicator`, `SliderThumb`), diện mạo lấy từ `E:\codex\xbds\materiant\projects\form\ui\src\lib\slider` (`slider.css`, `slider.const.ts`).
- Ngang và dọc (dọc cho 10 băng EQ của groove). `min` / `max` / `step`, `disabled`, `on_change` khi kéo, `on_commit` khi thả.
- Tua bài của groove: app đặt được giá trị từ ngoài lúc đang phát mà không cắt ngang thao tác kéo của người dùng.
- Bàn phím: mũi tên, PageUp / PageDown, Home / End. Nhấp vào track nhảy tới vị trí đó.
- Trang gallery `slider`: đúng cả sáng / tối. Test logic thuần (làm tròn step, kẹp biên), test bàn phím trong `ui-tests/`.
- Phím mặc định tự gán ở lần vẽ đầu (`bind_keys`, như `list.rs`); không sửa `lib.rs`.

## 2. Không làm trong task này
- Hai thumb (khoảng giá trị), nhãn giá trị nổi. Không viết UI của groove.
