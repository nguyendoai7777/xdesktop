# gd4_08 — siết IPC + lối vào dev trước khi phát hành

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (31/10/2026) — chờ kiểm tay C6, C11 |
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

- [x] C1 `[opus-unit]` Cho tiến trình con giữ tên `Endpoint::custom` / Khi `listen` / Thì `AddrInUse`, chữ "another process"; con thoát thì mở lại được.
- [x] C2 `[opus-unit]` Cho pipe vừa mở / Khi đọc DACL bằng `GetSecurityInfo` / Thì đúng một ACE cho phép, đúng SID hiện tại. Không thử đổi SID (không có tài khoản thứ hai).
- [x] C3 `[opus-unit]` Cho server là exe giả chép sang thư mục tạm / Khi `Endpoint::guarded(..).connect()` / Thì `PermissionDenied`, lỗi không có đường dẫn; `custom` vẫn nối được.
- [x] C4 `[opus-unit]` Cho server cùng thư mục / Khi nối `guarded` / Thì nhận được thông điệp.
- [x] C5 `[opus-unit]` Nối `guarded` chậm hơn `custom` dưới 1 ms: 37,7 µs → 460 µs (debug, 200 lần).
- [ ] C6 `[owner-qa]` Socket 0600 trong thư mục 0700: test `guarded_socket_is_private` có sẵn, chạy trên Mac / Ubuntu (gd4_10, gd4_12). Trên Windows chỉ `cargo check` macOS.
- [x] C7 `[opus-run]` Bản release không `dev-env` ⇒ `tools/check-no-dev-env.ps1` báo sạch cả bốn exe; bản có `dev-env` ⇒ báo có tên biến (script bắt được thật).
- [x] C8 `[opus-unit]` `dev_env` đi theo bản build: `cargo test -p fastcast-core --lib worker` cả debug lẫn `--release`.
- [x] C9 Bốn lệnh soát xanh, trừ `fake_wheel_needs_a_tool_and_adds_up_touchpad_deltas` đỏ sẵn trên `master` (ghi backlog); `cargo check --locked --target aarch64-apple-darwin -p fastcast-core -p fastcast-daemon` xanh.
- [x] C10 Không chạy `fst` thật, không chạy bản `isolated` trên máy nhà trong làn này.
- [ ] C11 `[owner-qa]` `fst` thật + UI thật vẫn nối được sau khi cài vào `%LOCALAPPDATA%`.

## 8. Nợ chuyển task khác

- `gd4_09`: `build-installer.ps1` gọi `tools/check-no-dev-env.ps1 -Dir <target>/release` sau bước build, mã thoát khác 0 thì dừng.
- `gd4_18`: đo RAM `fst` trước / sau (`core` thêm `windows-sys`, chỉ là binding), task này không được chạy `fst` thật.

## 9. Bàn giao thực tế

- **Pipe, đã gộp `master` (7352dc9)**: `Endpoint::listen` đặt DACL một người (`D:P(A;;GA;;;<SID>)`); `interprocess` vốn đặt `FILE_FLAG_FIRST_PIPE_INSTANCE` cho instance đầu nên chỉ đổi lỗi thành `AddrInUse`. `Endpoint::connect` của endpoint thật kiểm exe của server qua `peer_creds` (bên trong là `GetNamedPipeServerProcessId`).
- **Opus chọn 30/10/2026**: thêm `Endpoint::guarded(tag)` để test đường kiểm; `custom` không kiểm vì `fake_daemon`, exe test nằm khác thư mục với UI — vì không thì mọi test tích hợp đều đỏ. Hệ quả: `fake_daemon --real` chỉ nối được UI cùng thư mục.
- **Khác file task**: `crates/daemon/src/ipc_server.rs`, `crates/ui/src/ipc.rs`, `{ocr,record}/client.rs`, `crates/ocr/src/main.rs` không cần sửa. Sửa thay: `crates/core/src/worker.rs` (`DEV_ENV`, `dev_env`, `exe_path`), `crates/ocr/src/worker.rs`, `crates/daemon/src/cli.rs` (lỗi "cannot reach daemon", vì giờ có thể là bị từ chối chứ không chỉ daemon tắt). Thêm `tools/check-no-dev-env.ps1`.
- **Biến dev**: `dev_env` + `exe_path` là `inline(always)`, đã kiểm bằng script: tên biến không còn trong exe. Test tích hợp + `source_probe` panic nếu build release thiếu `dev-env`, vì không thì `FASTCAST_REC_WINDOW` bị bỏ qua và quay màn thật.
- **Soát**: test đỏ khi máy bận `fake_overlay_drag_on_one_monitor_does_not_repaint_the_other`, `unwritable_dir_keeps_the_old_file_and_reports` ("still running after 30s"), chạy lại riêng đều xanh.
- **Biến dev, gộp sau gd3_13**: gd3_13 yêu cầu chặn `FASTCAST_REC_WINDOW` phải báo lỗi ⇒ `worker::refuse_window_override`, so theo đuôi `_REC_WINDOW` để tên đầy đủ không vào exe. Sau khi gộp gd4_12 còn hai chỗ đọc trực tiếp (`ocr/src/main.rs`, `video/src/macos/capture.rs`), đã chặn nốt; nhánh macOS mới `cargo check`. Lệnh đo ở `docs/gd3-report.md`, `measure.rs`, `ocr-e2e.ps1` đã thêm `dev-env`.
- **Chờ kiểm tay**: C6, C11.

## 10. Đề xuất cải tiến

- `[bảo mật]` Bản release còn các biến dev khác (`FASTCAST_RECORD_OUTPUT`, `FASTCAST_OVERLAY_SCRIPT`…) — bằng chứng: `CLAUDE.md` mục Lệnh — cùng người dùng đặt, không mở thêm quyền; đưa qua `dev_env` nếu muốn exe gọn — thấp — S — P3. Không làm: mục 2 chỉ định bốn biến.
- `[bảo mật]` `fastcast-ui --endpoint <tag>` ở release bỏ qua kiểm exe — bằng chứng: `crates/ui/src/app.rs:65` — kẻ truyền được đối số đã chạy được mã, không mở thêm quyền — thấp — S — P3. Không làm.
- UI/UX: lỗi bị từ chối chỉ vào log + `fst` in ra; không áp thêm. RAM: không crate mới, không cấp phát lúc nghỉ. Pro: không áp.
