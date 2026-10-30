# gd3_03 — tiến trình `fastcast-ocr`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd3_01, gd0_05 (kết luận cách phát hành model) |
| Quyết định áp dụng | F-4, F-6, D-2 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ocr/src/{main,worker}.rs`; MỚI `crates/ocr/tests/worker.rs`, `tools/fetch-ocr-models.ps1` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `fastcast_core::worker::{OcrRequest, OcrReply, OcrError, send, recv}`; stub `crates/ocr/src/worker.rs` (chữ ký `run`), `crates/ocr/src/main.rs` (đã có `windows_subsystem`, `IDLE` 60 s).
- **Nợ chuyển sang đây**: `main.rs` đang truyền `"models"` tương đối, chỉ để biên dịch ⇒ đổi sang `<thư mục exe>/models/` + `FASTCAST_OCR_MODELS`.
- **Đã chốt trong giao thức**: nạp hỏng ⇒ `Failed { id: None }` rồi thoát, `fake_ocr` thoát mã 1 ⇒ worker thật giữ cùng mã. JSON lạ ⇒ `Failed { id: None, code: Internal }`, đọc tiếp.
- **Bẫy**: stdout chỉ để nói giao thức, không `println!`. Cả dòng `Text` phải vừa `ipc::MAX_LINE` (1 MiB), `worker::recv` bên UI từ chối dòng dài hơn ⇒ chữ quá dài trả `Internal`.

## 1. Làm gì

- `worker::run`: gửi `Ready` sau khi nạp model; nhận `Recognize`, đọc tệp RGBA, **xoá tệp ngay cả khi lỗi**, trả `Text` / `Failed`.
- Kiểm cỡ tệp đúng `width × height × 4`, đường dẫn nằm trong `<data_dir>/tmp/`, cạnh ≤ `MAX_CLIPBOARD_EDGE`; sai ⇒ `ImageUnreadable`.
- Stdin đóng hoặc `Shutdown` ⇒ thoát. Rảnh 60 s ⇒ thoát, nhả toàn bộ RAM model (F-4).
- Tìm model + `onnxruntime.dll` ở `<thư mục exe>/models/`; `FASTCAST_OCR_MODELS` đè khi chạy thử. Thiếu ⇒ `ModelMissing` / `RuntimeMissing`, không panic.
- `tools/fetch-ocr-models.ps1`: dev lấy model từ thư mục vnocr (đường dẫn truyền vào) hoặc theo `manifest.toml`; model không commit.

## 2. Không làm trong task này

Thuật toán OCR (gd3_02). Client phía UI (gd3_09). Bản cài kèm model (GĐ4).

## 2b–5

Viết lúc bắt đầu task. Test bằng `Recognizer` giả, không cần model. **Đo** `[opus-run]`: RAM đỉnh + sau khi thoát, thời gian `Ready` nguội, khi gd3_02 đã gộp (ai gộp sau chạy).

## 6. Nghiệm thu

- Test: thứ tự trả lời; tệp ảnh luôn bị xoá, kể cả lỗi; đường dẫn ngoài `tmp/` bị từ chối; stdin đóng ⇒ thoát mã 0; hết hạn rảnh ⇒ thoát.
- `[opus-run]` Engine thật trên ảnh tổng hợp của spike: chữ khớp, không sót tệp trong `tmp/`.

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

Thêm `models/` vào bản cài + trang giấy phép: GĐ4.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
