# materiant-gd5_02 — Progress

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | — |
| Quyết định áp dụng | D-6, D-9, D-11, D-13 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `src/progress.rs`, `examples/gallery/pages/progress.rs` |

## 1. Làm gì
- `materiant::progress`: thanh ngang và vòng tròn, mỗi loại có xác định (`value`) và không xác định. Nguồn: `E:\codex\xbds\materiant\projects\progress\src\lib` (`progress.component.ts`, `progress-circular.component.ts`, `progress-indeterminate.component.ts`).
- `gpui_kit::base` `Progress` chỉ có dạng thanh; dạng tròn tự vẽ (`canvas` + path, hoặc SVG xoay nếu đủ đẹp) và ghi lý do chọn ở mục 9.
- Hoạt ảnh chỉ chạy khi component đang hiện; dừng thì không xin vẽ khung mới (đo bằng `FRAMES`).
- Trang gallery `progress`: đúng cả sáng / tối. Test logic thuần (kẹp giá trị, góc cung).

## 2. Không làm trong task này
- Biến thể iOS (`progress-ios`), nhãn phần trăm.
