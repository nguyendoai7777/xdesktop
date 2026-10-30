# gd4_08 — siết IPC + lối vào dev trước khi phát hành

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~350 dòng |
| Phụ thuộc | — (không đụng tệp của gd4_01, chạy cùng đợt 0). Phần chặn biến dev ở bản release gộp SAU gd3_13: nó đang đo bản release bằng `FASTCAST_REC_WINDOW` (backlog gd3_05 giao nó xử lý biến này); gd3_13 chưa gộp thì gộp phần pipe trước |
| Quyết định áp dụng | F-4, D-9 |
| Phụ thuộc mới | — (thêm feature của `windows-sys` có sẵn) |
| File đụng tới | SỬA `crates/core/src/ipc.rs`, `crates/daemon/src/ipc_server.rs`, `crates/ui/src/ipc.rs`, `crates/ui/src/{ocr,record}/client.rs`, `crates/video/src/source/mod.rs`, `crates/ocr/src/main.rs` (biến `FASTCAST_OCR_MODELS`), `crates/{core,ui,video,ocr}/Cargo.toml` (feature `dev-env`); MỚI `crates/core/tests/ipc_security.rs` |

## 1. Làm gì

- Pipe `fastcast-<user>` tạo với `FILE_FLAG_FIRST_PIPE_INSTANCE` + DACL chỉ người dùng hiện tại. Tiến trình khác giành tên trước ⇒ daemon báo lỗi rõ, không chạy mù. Unix: socket quyền 0600 trong thư mục riêng.
- Client (UI, CLI) kiểm `GetNamedPipeServerProcessId`: exe của server cùng thư mục với mình, không thì từ chối. Nợ `gd1_01` mục 10.
- Bản release bỏ qua biến chạy thử nguy hiểm (`FASTCAST_OCR_EXE`, `FASTCAST_REC_EXE`, `FASTCAST_REC_WINDOW`, `FASTCAST_OCR_MODELS`): chỉ có hiệu lực khi `cfg!(debug_assertions)` hoặc feature `dev-env`. `tests/measure.rs` đo bản release ⇒ build đo bật `dev-env`. Soát xem gd3_13 đã làm phần nào.
- Bản phát hành (gd4_09) build không có `dev-env`, script soát bằng `strings` / tìm chuỗi tên biến.

## 2. Không làm trong task này

Mã hoá IPC, xác thực theo chữ ký exe (cần chứng chỉ). `FASTCAST_CONFIG_FILE`, `FASTCAST_OVERLAY_FAKE`: cùng người dùng đặt, không mở thêm quyền, giữ nguyên.

## 2b. Phân vai

Toàn bộ `[opus]`: FFI + giao thức.

## 5. Đo

Không thêm crate vào daemon. Độ trễ nối: `tests/ipc.rs` dòng `MEASURE`, không tăng quá 1 ms.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh; `cargo check --locked --target aarch64-apple-darwin -p fastcast-core -p fastcast-daemon` xanh.
- [ ] `Endpoint::custom` (không đụng pipe thật): tiến trình thứ hai giành tên ⇒ lỗi; tiến trình con đổi SID thử được thì đọc pipe bị từ chối, không thì kiểm DACL bằng `GetSecurityInfo`.
- [ ] Client từ chối server có exe khác thư mục (test với exe giả).
- [ ] Không chạy `fst` thật, không chạy bản `isolated` (có khay) trên máy nhà trong làn này.
- [ ] `[owner-qa]` `fst` thật + UI thật vẫn nối được sau khi cài vào `%LOCALAPPDATA%`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
