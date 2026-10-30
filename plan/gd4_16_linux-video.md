# gd4_16 — Ubuntu: quay vùng + OCR

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 GNOME Wayland |
| Repo | fastcast |
| Cỡ | M — ~850 dòng; vượt trần ⇒ tách âm thanh trước khi code |
| Phụ thuộc | gd4_01, gd0_07 |
| Quyết định áp dụng | D-2, D-3, F-6, F-7 |
| Phụ thuộc mới | **Dừng phần này chờ chủ dự án**: GStreamer là LGPL, D-2 đòi link động + hỏi trước. Phương án thay: gọi `gst-launch` / exe hệ thống qua tiến trình con, không link |
| File đụng tới | SỬA `crates/video/src/linux/mod.rs`, `crates/video/src/session.rs` (nhánh `cfg`), `crates/video/src/audio.rs` (nhánh `cfg`), `crates/video/src/source/mod.rs` (khai báo), `crates/video/Cargo.toml`, `crates/ocr/src/main.rs` (đường tìm `.so`); MỚI `crates/video/src/linux/{portal,encoder}.rs` |

## 1. Làm gì

- Portal `ScreenCast` → PipeWire → H.264 VAAPI (`vah264enc`), dự phòng OpenH264 tải khi cần (F-7), không x264.
- Âm hệ thống / micro qua PipeWire.
- `fastcast-ocr` chạy trên Ubuntu.

## 2. Không làm trong task này

Sửa nhánh Windows, macOS. Link GStreamer khi chưa có đồng ý: mục cấm của D-2, D-9 không thay luật cứng.

## 5. Đo

720p30: CPU, RAM, tệp mở bằng Totem + trình duyệt + Media Player Windows.

## 6. Nghiệm thu

- [ ] Trên Ubuntu: bốn lệnh xanh, `cargo deny` xanh, quay vùng thật kèm tiếng, OCR tiếng Việt.
- [ ] Chờ quyết định LGPL ⇒ ghi `plan/confirm.md` + `_backlog.md`, làm phần còn lại, không link.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
