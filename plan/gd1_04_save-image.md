# gd1_04 — Lưu ảnh: Ctrl/Cmd+S và Ctrl/Cmd+Shift+S

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd1_03 · materiant-gd1 T8 (`Toast` — chưa có thì log + bỏ toast, ghi nợ) |
| Quyết định áp dụng | F-8 |
| Phụ thuộc mới | `image` (MIT / Apache-2.0, chỉ PNG) — đã có trong cây qua xcap |
| File đụng tới | `crates/ui/src/save.rs` MỚI · `crates/core/src/naming.rs` MỚI · `crates/core/src/lib.rs` SỬA · `crates/ui/src/overlay/view.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- **Ctrl/Cmd+S** (và nút Lưu): cắt `Frozen::crop(vùng)` → PNG vào `save.imageDir` (mặc định Pictures của OS) tên
  `fastcast_YYYY-MM-DD_HH-mm-ss.png` giờ địa phương; trùng tên ⇒ `_2`, `_3`… (không bao giờ ghi đè). Đóng overlay.
- **Ctrl/Cmd+Shift+S** (và nút Lưu thành…): hộp thoại lưu của hệ thống (`cx.prompt_for_new_path`) mở ở
  `save.lastImageDialogDir` (chưa có ⇒ `imageDir`), nhớ thư mục vừa chọn. Huỷ hộp thoại ⇒ quay lại overlay.
- Mã hoá PNG + ghi file ngoài luồng UI; ghi qua file tạm cùng thư mục rồi đổi tên.
- Thư mục không còn / không ghi được ⇒ thông báo lỗi có đường dẫn, gợi ý Lưu thành…; không mất vùng chọn.
- Toast "Đã lưu <tên tệp>" (bấm ⇒ mở thư mục chứa).
- `naming.rs` (core): tên tệp theo giờ + tìm hậu tố không trùng — hàm thuần, video ở GĐ3 dùng lại.

## 2. Không làm trong task này

- Lưu video (GĐ3). Chọn định dạng khác PNG.

## 3. Kiểu dữ liệu · IPC · cấu hình

Đọc `save.imageDir`, ghi `save.lastImageDialogDir`. **Ghi cấu hình**: đọc lại `config.json` ngay trước khi ghi rồi
chỉ đổi trường của mình (tránh đè thay đổi của `fst autostart` / Settings), ghi qua `config::save`.

## 4. Code

Phím Ctrl/Cmd: dùng `secondary` của GPUI (Cmd trên macOS, Ctrl nơi khác).

## 5. Đo

Thời gian từ Ctrl+S tới file nằm trên đĩa với vùng 3840 × 1080.

## 6. Nghiệm thu

- Ảnh lưu đúng pixel vật lý của vùng (so `Frozen::crop`), kể cả vùng vắt hai màn.
- Lưu hai lần trong cùng một giây ⇒ hai tệp, không ghi đè.
- `lastImageDialogDir` nhớ qua lần khởi động sau.
- Test đơn vị `naming` (đổi ngày, hậu tố, ký tự tiếng Việt trong đường dẫn).

## 7. Ghi chú UI

Khoá i18n: `save.saved`, `save.failed`, `save.open_folder`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
