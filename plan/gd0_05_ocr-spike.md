# gd0_05 — Spike OCR bằng Rust (`ort`)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay ảnh chụp thật (C8) |
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

## 2b. Phân vai

| Phần | Ai |
|---|---|
| Crate spike: manifest, tiền xử lý, det, rec, bench, sinh ảnh, lượng tử hoá, so Python, báo cáo | `[opus]` (spike vứt đi được, phần lớn là chuyển thể thuật toán + đo, không có phần ghép UI) |
| Thử ảnh chụp thật của chủ dự án | `[owner-qa]` — `plan/_backlog.md` |

## 4. Code

- Crate spike riêng `fastcast/spikes/ocr/` có `[workspace]` rỗng (hoặc thêm `exclude = ["spikes"]` vào workspace).
- CLI: `ocr-spike <ảnh|thư mục> [--int8] [--bench chuẩn.tsv]` in chữ + thời gian từng pha.
- Model không commit vào repo: đường dẫn tới thư mục model của vnocr hoặc tải theo `manifest.toml`.

## 5. Đo

Mỗi ảnh và trung vị: thời gian det / rec / tổng (khởi động nguội + ấm), RAM đỉnh + lúc nghỉ sau khi chạy (Task
Manager), cỡ model fp32 / int8, CER so với chữ chuẩn và so với bản Python.

## 6. Nghiệm thu

- **C1** `[opus-unit]` Cho manifest có model sai sha256 / thiếu tệp / giấy phép ngoài danh sách. Khi mở sổ. Thì lỗi, không
  nạp model.
- **C2** `[opus-unit]` Cho hàm thuần (hình chữ nhật bao nhỏ nhất, resize kiểu PIL, cắt dòng rộng, Levenshtein, chọn đảo màu,
  thứ tự đọc). Thì đúng ca biên.
- **C3** `[opus-run]` Cho ≥ 20 ảnh tổng hợp (code, chat, web, dark / light, tiếng Việt có dấu, chữ 11–12 px) + chữ chuẩn.
  Khi `ocr-spike <thư mục> --bench chuẩn.tsv`. Thì in chữ, thời gian det / rec / tổng từng ảnh + trung vị, CER.
- **C4** `[opus-run]` Cho cùng ảnh, cùng tham số. Khi chạy bản Python (Docker) và bản Rust. Thì CER Rust không tệ hơn
  Python quá 1 điểm phần trăm.
- **C5** `[opus-run]` So fp32 / int8: CER, thời gian, RAM đỉnh + lúc nghỉ (Task Manager), cỡ file; kết luận dùng bản nào.
- **C6** `[opus-run]` So có / không tiền xử lý màn hình (đảo màu, phóng chữ nhỏ) trên ảnh tối và chữ nhỏ.
- **C7** `[opus-run]` Báo cáo `fastcast/docs/spikes/ocr.md`: bảng số đo trên, kết luận fp32 / int8, cách phát hành model
  (kèm bản cài hay tải khi cần — tải từ máy chủ là dịch vụ trả phí ⇒ hỏi chủ dự án), rủi ro, giới hạn "ảnh tổng hợp",
  giấy phép model + crate. `cargo deny check licenses` xanh.
- **C8** `[owner-qa]` Thử ảnh chụp thật (backlog).

## 8. Nợ chuyển task khác

- Nối vào tiến trình `fastcast-ocr` + IPC + Ctrl/Cmd+C ở overlay: GĐ3.

## 9. Bàn giao thực tế

Báo cáo: `fastcast/docs/spikes/ocr.md`. Số thô: `fastcast/spikes/ocr/results/` (`final/` = lượt chốt, `prior/` = session trước).

- **Kết luận cho GĐ3**: lai — det + VietOCR `vn8a30` int8, Paddle small fp32 đọc trước, dòng không có dấu hiệu code thì VietOCR đọc lại; không arena, 4 luồng, batch 16, preset `screen`. CER 2,45 % (26 ảnh) · 0,86 % (ca khó). RAM giữ phiên ~105 MB, đỉnh 113 / 260 / 450 MB (dòng / đoạn / cả màn). Model 78 MB + dll 17 MB. Nguội ~1 s, dòng 0,1–0,45 s, đoạn 22 dòng chữ nhỏ ~10 s, cả màn ~8–11 s.
- **Case**: C1, C2 xanh (42 test) · C3 xanh (26 + 12 ảnh, in từng ảnh + trung vị) · C4 đạt (Rust 60,36 so với Python 59,70 ở `scene`, lệch +0,66 điểm; 29,28 so với 31,47 khi giữ nguyên ảnh) · C5, C6 xong · C7 xong. C8 chờ kiểm tay.
- **Soát**: trong `spikes/ocr`: `cargo build --release`, `cargo clippy --all-targets -- -D warnings` (sửa 4 cảnh báo cũ, không đổi hành vi), `cargo test` 42 / 42, `cargo deny --config ../../deny.toml check licenses` xanh.
- **Nhận lại phần dở**: session trước biến mất giữa chừng, đã đo gần đủ nhưng chưa ghi RAM Task Manager, chưa có báo cáo. Giữ log cũ ở `results/prior/`, đo lại mọi ca chính bằng exe cuối.
- **Đo**: `BelowNormal`, các session GĐ2 / GĐ3 / materiant build song song ⇒ thời gian nhiễu 2–5 lần, chỉ xem độ lớn; CER và RAM ổn định. Không chụp màn hình thật. `spikes/ocr/results/` ~1 MB, không có model, không có ảnh.
- **Opus chọn 30/10/2026** (`plan/confirm.md`): cấu hình lai (F-6 chỉ nêu VietOCR); model kèm bản cài; không chờ máy rảnh để đo lại thời gian.
- **Phát sinh so với plan**: biến thể `mix` (Paddle fp32) không có trong plan, thêm sau khi thấy int8 của Paddle làm hỏng ký hiệu code; đã đo, có ở `tools/quantize.py`, chạy lại ra giống từng byte. gd3_02 mục 1 từng ghi bỏ `paddle` ⇒ đã sửa, kèm bàn giao.
- **Cho gd3_09 (đang 🔄 ở session khác, không chèn khối)**: một ca đọc có thể ~10 s trở lên, UI cần trạng thái đang đọc + huỷ.
- **Chờ kiểm tay**: C8, `plan/_backlog.md`.

## 10. Đề xuất cải tiến

Bảo mật / riêng tư: đã xử lý trong spike (telemetry tắt, dll theo đường dẫn tuyệt đối, sha256 + giấy phép fail-closed), cần giữ khi chuyển: gd3_02 mục 0. Pro: không có đề xuất có bằng chứng.

1. `[ux]` Đoạn 22 dòng chữ nhỏ ~10 s — `results/final/one-para-mix-noarena.log` — trả từng dòng dần thay vì đợi hết, cần đổi giao thức `fastcast_core::worker` — người dùng thấy chữ sớm — M — P2. Không làm ở đây: spike chưa nối IPC, giao thức đã chốt ở gd3_01 ⇒ ghi lại đây để xét sau gd3_13, khi có số thời gian lúc máy rảnh.
2. `[ram]` Phóng ×2 đẩy đỉnh đoạn nhỏ 113 ⇒ 263 MB và là phần lớn thời gian dò (~1,5 s so với ~20 ms) — `results/final/hard-mix-noarena.log` — thử cắt vùng thành dải trước khi phóng — vừa nhanh vừa nhẹ — M — P3. Không làm: chưa có số trên ảnh thật để biết đáng công không, xét sau C8.
3. `[ux]` Thứ tự đọc bố cục nhiều cột: `mixed` CER 10,28 %, WER 0,2 % — `results/final/full-mix-noarena.log` — gom cột trước khi xếp hàng — chữ chép ra đọc đúng mạch — M — P3. Không làm: cần ảnh thật để biết bố cục nào hay gặp, xét sau C8.
