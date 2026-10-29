# gd1_05 — Chép ảnh / chữ qua daemon (Ctrl/Cmd+C)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~400 dòng |
| Phụ thuộc | gd1_03 |
| Quyết định áp dụng | F-4 (clipboard ở daemon), D-2 |
| Phụ thuộc mới | `arboard` (MIT / Apache-2.0) vào **daemon** ⇒ đo RAM daemon trước / sau |
| File đụng tới | `crates/core/src/ipc.rs` SỬA · `crates/daemon/src/clipboard.rs` MỚI · `crates/daemon/src/daemon.rs` SỬA · `crates/daemon/Cargo.toml` SỬA · `crates/ui/src/clipboard.rs` MỚI · `crates/ui/src/overlay/view.rs` SỬA |

## 1. Làm gì

- Ctrl/Cmd+C, Enter, nút Chép ở overlay ⇒ ảnh vùng chọn vào clipboard, đóng overlay, toast "Đã chép".
- Clipboard do **daemon** giữ (F-4): trên Linux bên giữ clipboard phải sống, UI thì tự thoát sau khi giữ ấm.
- Ảnh không đi qua JSON: UI ghi RGBA thô vào tệp tạm trong `<data_dir>/tmp/` (tên ngẫu nhiên), gửi đường dẫn + cỡ;
  daemon đọc, đặt clipboard, **xoá tệp ngay**.
- Daemon chỉ nhận đường dẫn nằm trong `<data_dir>/tmp/` của chính nó, cỡ khớp `w × h × 4`, trần 16 384 × 16 384 ⇒
  không đọc được tệp tuỳ ý dù pipe bị tiến trình khác của cùng người dùng gọi.
- Chép chữ (`ClipboardText`) cho thước (gd1_08) + lấy màu (gd1_09).
- Daemon khởi động thì dọn tệp sót trong `tmp/`.

## 2. Không làm trong task này

- Lịch sử clipboard. Chép nhiều định dạng (HTML…).

## 3. Kiểu dữ liệu · IPC · cấu hình

```rust
Message::ClipboardImage { path: PathBuf, width: u32, height: u32 }   // UI → daemon; trả Ok | Error
Message::ClipboardText { text: String }                              // UI → daemon; trần 64 KiB
```

## 4. Code

`[opus]`: hai thông điệp + kiểm đường dẫn / cỡ (ca biên: `..`, symlink, đường dẫn tuyệt đối khác thư mục, cỡ lệch).
`arboard` đặt clipboard trên luồng riêng của daemon, không chặn vòng sự kiện.

## 5. Đo

RAM daemon lúc nghỉ trước / sau `arboard` (hiện 1,1 MB) và sau một lần chép ảnh 3840 × 1080 (bộ nhớ phải nhả về gần
mức nghỉ). Thời gian Ctrl+C → dán được.

## 6. Nghiệm thu

- Chép rồi dán vào Paint / Word / trình duyệt: đúng ảnh, đúng cỡ vật lý.
- UI thoát (hết giữ ấm) ⇒ vẫn dán được.
- Test tích hợp IPC: đường dẫn ngoài `tmp/` bị từ chối, tệp tạm bị xoá sau khi đặt.
- `[owner-qa]`: dán được sau khi UI thoát.

## 7. Ghi chú UI

Khoá i18n: `clipboard.copied`, `clipboard.failed`.

## 8. Nợ chuyển task khác

- Linux / macOS: kiểm lại sau gd0_07 và GĐ4.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
