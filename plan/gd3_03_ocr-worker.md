# gd3_03 — tiến trình `fastcast-ocr`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — C13 (engine thật) do gd3_02 chạy lúc gộp, theo luật làn |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd3_01, gd0_05 (kết luận cách phát hành model) |
| Quyết định áp dụng | F-4, F-6, D-2 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ocr/src/{main,worker}.rs`, `CLAUDE.md`; MỚI `crates/ocr/tests/worker.rs`, `tools/fetch-ocr-models.ps1`, `tools/ocr-e2e.ps1` |

## 0. Bàn giao từ gd0_05 (30/10/2026)

<!-- handoff: gd0_05 -->

- **Kết luận phát hành**: model **kèm bản cài** (78 MB + `onnxruntime.dll` 17 MB), không tải khi cần — vì tải cần máy chủ trả phí (`plan/confirm.md`).
- **Bộ model thư mục `models/`**: det + VietOCR int8, Paddle fp32. `tools/fetch-ocr-models.ps1` **không chép thẳng được từ vnocr**, vì vnocr chỉ có fp32 (và cả chục biến thể): phải chạy `spikes/ocr/tools/quantize.py <models> <đích> mix` qua Docker (`python:3.12-slim`, cần mạng lần đầu cho `pip`), rồi soát với `spikes/ocr/results/manifest.int8-mix.toml`. Sổ đó thay cho `manifest.toml` của vnocr; thư mục spike bị xoá, không có sẵn bản đã sinh.
- **`onnxruntime.dll`**: bản đã thử là 1.31.1 x64 chính thức của Microsoft, không còn sẵn trên máy (đã xoá theo target spike): tải từ release GitHub của `microsoft/onnxruntime` trong script dev, kèm `ThirdPartyNotices.txt` để GĐ4 đưa vào bản cài.
- **Số để đặt kỳ vọng khi đo**: nguội ~1 s đến `Ready` (dll 50 ms, sha256 400 ms, dựng phiên 550 ms) · RAM giữ phiên ~105 MB · đỉnh 113 MB (một dòng), ~260 MB (đoạn 22 dòng), ~450 MB (cả màn) · sau khi nhả phiên còn ~19 MB, nên rảnh 60 s là thoát hẳn thì mới về 0.
- **Bẫy**: một ca đọc có thể ~10 s (đoạn chữ nhỏ) tới ~11 s (cả màn), lúc máy bận còn lâu hơn: đừng đặt hạn đọc ngắn ở worker, và đếm rảnh 60 s tính từ lúc **xong** ca đọc.

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

## 2b. Phân vai

Toàn bộ `[opus]`: đa luồng + giao thức + kiểm đường dẫn, không có phần UI / catalog để giao.

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thêm thông điệp, dùng nguyên `fastcast_core::worker`. Biến môi trường `FASTCAST_OCR_MODELS`. Thêm `worker::{serve, models_dir, check_models, MODELS_VAR}`.

## 4. Code

Luồng đọc stdin đẩy vào `mpsc`, luồng chính `recv_timeout(idle)` rồi đọc ảnh tuần tự ⇒ rảnh tính từ lúc xong ca đọc, ca dài không bị hết hạn. Kiểm đường dẫn cùng cách `daemon/clipboard.rs`.

## 5. Đo

Khi gd3_02 đã gộp, `[opus-run]` ai gộp sau chạy: `tools/ocr-e2e.ps1` in thời gian `Ready` nguội, RAM đỉnh, thời gian từng ảnh. Kỳ vọng: `Ready` ~1 s; đỉnh ~450 MB cả màn; sau khi thoát tiến trình đã mất.

## 6. Nghiệm thu

| Case | Cho | Khi | Thì | Phủ |
|---|---|---|---|---|
| C1 | Worker đã nạp | Gửi 3 ảnh liền | `Ready` trước, rồi đúng thứ tự id | `[opus-unit]` ✅ |
| C2 | Tệp trong `tmp/`, sai cỡ / cạnh 0 / vượt `MAX_CLIPBOARD_EDGE` / `u32::MAX` | Recognize | `ImageUnreadable`, tệp đã xoá | `[opus-unit]` ✅ |
| C3 | Engine trả lỗi | Recognize | `Failed` đúng mã, tệp đã xoá | `[opus-unit]` ✅ |
| C4 | Đường dẫn ngoài `tmp/`, có `..`, tương đối, thư mục con | Recognize | `ImageUnreadable`, tệp **không** bị xoá | `[opus-unit]` ✅ |
| C5 | Không có thư mục tạm | Recognize | `ImageUnreadable` | `[opus-unit]` ✅ |
| C6 | Đang đọc một ảnh | Stdin đóng | Trả nốt, thoát 0 | `[opus-unit]` ✅ |
| C7 | Ảnh xếp hàng sau `Shutdown`, hoặc UI đóng stdout | Worker thoát | Thoát 0, ảnh trong `tmp/` đã xoá, ngoài `tmp/` còn nguyên | `[opus-unit]` ✅ |
| C8 | Hạn rảnh 300 ms, ca đọc 600 ms | Một ảnh rồi để yên | Vẫn có trả lời; thoát 0 sau ≥ hạn tính từ lúc trả lời | `[opus-unit]` ✅ |
| C9 | Nạp hỏng | Bật | `Failed { id: None }`, không `Ready`, thoát 1 | `[opus-unit]` ✅ |
| C10 | JSON lạ | Gửi rồi gửi ảnh | `Failed { id: None, Internal }`, ảnh sau vẫn đọc | `[opus-unit]` ✅ |
| C11 | Chữ không vừa `MAX_LINE`, kể cả do escape | Recognize | `Internal`; chữ vừa thì qua được `recv` | `[opus-unit]` ✅ |
| C12 | Exe thật, thiếu manifest / dll; tiến trình thật stdin mở | Bật | `ModelMissing` / `RuntimeMissing`, thoát 1; hết hạn rảnh thoát 0 dù luồng đọc đang chặn; đóng stdin thoát 0 | `[opus-unit]` ✅ |
| C13 | Engine thật, ảnh tổng hợp của spike | `tools/ocr-e2e.ps1` | ≥ 90 % từ khớp, không sót tệp trong `tmp/`, thoát 0 | `[opus-run]` gd3_02 |

## 7. Ghi chú UI

—

## 8. Nợ chuyển task khác

Thêm `models/` vào bản cài + trang giấy phép: GĐ4. C13 + số đo: gd3_02 (gộp sau).

## 9. Bàn giao thực tế

- **Kết quả**: C1–C12 xanh, 17 test, chạy lặp 5 lần không chập chờn. `cargo clippy -p fastcast-ocr --all-targets -- -D warnings`, `cargo fmt --check`, `cargo deny check licenses` xanh. Soát theo luật làn engine, không build GPUI.
- **C13 xanh, gd3_02 chạy lúc gộp sau (30/10/2026)**: `tools/ocr-e2e.ps1` bản release với engine thật, cả `-IdleExit`, không phải sửa script. `Ready` 942 ms (lần đầu khi model chưa vào cache đĩa 5982 ms) · RAM đỉnh 343–365 MB · ba ảnh 4,9 / 8,5–8,7 / 8,0 s · khớp từ 91,6 / 100 / 99,6 % · thoát mã 0 sau 31 ms khi đóng stdin, sau 60034 ms khi rảnh · không sót tệp trong `tmp/`.
- **`tools/fetch-ocr-models.ps1` đã chạy thật**: Docker + ONNX Runtime 1.31.1, mọi tệp khớp sổ `manifest.int8-mix.toml`, chạy lại không làm gì thêm. Kết quả ở `C:/xdesktop-target/ocr-models` (95 MB, ngoài git). Sha256 zip ONNX Runtime ghim theo lần tải này, tức tin lần tải đầu; chưa đối chiếu với nguồn độc lập.
- **Opus chọn 30/10/2026** (`plan/confirm.md`):
  - Dll ở `<models>/onnxruntime.dll`, không cạnh exe như spike: task ghi vậy, và bộ model gọn một thư mục.
  - Thêm `tools/ocr-e2e.ps1` ngoài danh sách tệp: mục 6 cần chạy thật mà làn gộp sau mới có engine, phải có lệnh sẵn.
  - Đường dẫn ngoài `tmp/` không xoá dù "luôn xoá tệp": xoá theo đường dẫn tuỳ ý là lỗ hổng, cùng cách daemon.
  - Tệp xoá trước khi nhận dạng, không phải sau: ảnh ở trên đĩa ngắn nhất, và engine chết ngang vẫn không sót.
  - Stdin đóng thì trả nốt ảnh đã nhận rồi mới thoát; `Shutdown` hoặc mất stdout thì bỏ ảnh còn xếp hàng, chỉ xoá tệp.
- **Sửa khi soi**: ảnh xếp hàng sau `Shutdown` / khi UI chết sẽ sót tệp tới lần daemon dọn ⇒ thêm `discard_queued` + C7.
- **Soi 4 lăng kính**: bảo mật — đã xử lý ở trên, log không có đường dẫn / chữ (`worker.rs` chỉ ghi cỡ ảnh, mã lỗi, ms). UI/UX — không áp, panel ở gd3_09. RAM — ảnh nhả ngay sau `engine.read`, thoát là về 0 (C12); số thật chờ C13. Pro — không áp.

## 10. Đề xuất cải tiến

- `[bảo mật]` `core::worker::recv` đọc dòng quá dài chỉ cắt `MAX_LINE + 1` byte, phần đuôi thành một dòng hỏng nữa ⇒ nhiều `Failed` cho một dòng — `core/worker.rs` `recv` — bỏ hết tới `\n` — thấp, chỉ UI gửi được stdin, không hại — S — P3. Chưa làm: tệp chung của gd3_01.
