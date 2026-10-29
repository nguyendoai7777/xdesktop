# gd0_05 — Spike OCR bằng Rust (`ort`)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast (spike ở `fastcast/spikes/ocr/`, ngoài cargo workspace) |
| Cỡ | M — spike, ~600 dòng vứt đi được |
| Phụ thuộc | — (độc lập; T0–T4 của GĐ0 đã xong) |
| Quyết định áp dụng | F-6, F-4 (OCR là tiến trình riêng), D-2 (giấy phép model + crate) |
| Phụ thuộc mới | `ort` (MIT / Apache-2.0) + ONNX Runtime (MIT) — soát cách tải binary của `ort` (tải lúc build ⇒ ghi lại, cân nhắc `load-dynamic`) |
| File đụng tới | `fastcast/spikes/ocr/` MỚI · `fastcast/docs/spikes/ocr.md` MỚI · `fastcast/Cargo.toml` SỬA (`exclude = ["spikes"]`) |

## 1. Làm gì

- Viết lại đường `scene` của vnocr (`E:\codex\xbds\bds-service\ocr` — PP-OCRv6 small det + VietOCR, giải mã tham lam)
  bằng `ort`: tiền xử lý → det → cắt dòng → rec → ghép chữ.
- Dùng lại model ONNX + `manifest.toml` (sha256, cổng giấy phép) của vnocr — đọc manifest, kiểm sha256 trước khi nạp.
- Tiền xử lý riêng cho ảnh chụp màn hình: đảo màu khi nền tối, phóng chữ nhỏ (ngưỡng theo chiều cao dòng).
- Thử model int8 (lượng tử hoá động) so với fp32: độ chính xác, thời gian, RAM, cỡ file.
- Bộ bench ảnh chụp màn hình (≥ 20 ảnh: code, chat, web, dark / light, tiếng Việt có dấu, chữ nhỏ 11–12 px) kèm chữ
  chuẩn để tính CER.
- So với bản Python gốc trên cùng bộ ảnh (máy nhà chưa có Python ⇒ chạy bản gốc bằng Docker).

## 2. Không làm trong task này

- Chưa nối vào `fastcast-ocr` / IPC / overlay (GĐ3).
- Không huấn luyện / tinh chỉnh model.

## 4. Code

- Crate spike riêng `fastcast/spikes/ocr/` có `[workspace]` rỗng (hoặc thêm `exclude = ["spikes"]` vào workspace).
- CLI: `ocr-spike <ảnh|thư mục> [--int8] [--bench chuẩn.tsv]` in chữ + thời gian từng pha.
- Model không commit vào repo: đường dẫn tới thư mục model của vnocr hoặc tải theo `manifest.toml`.

## 5. Đo

Mỗi ảnh và trung vị: thời gian det / rec / tổng (khởi động nguội + ấm), RAM đỉnh + lúc nghỉ sau khi chạy (Task
Manager), cỡ model fp32 / int8, CER so với chữ chuẩn và so với bản Python.

## 6. Nghiệm thu

- Báo cáo `fastcast/docs/spikes/ocr.md`: bảng số đo trên, kết luận dùng fp32 hay int8, cách phát hành model (kèm bản cài
  hay tải khi cần — tải từ máy chủ là dịch vụ trả phí ⇒ hỏi chủ dự án), rủi ro.
- CER của bản Rust không tệ hơn bản Python quá 1 điểm phần trăm trên bộ bench.

## 8. Nợ chuyển task khác

- Nối vào tiến trình `fastcast-ocr` + IPC + Ctrl/Cmd+C ở overlay: GĐ3.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
