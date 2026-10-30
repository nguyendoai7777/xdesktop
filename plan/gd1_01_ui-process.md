# gd1_01 — Tiến trình UI trên GPUI: nhận lệnh, giữ ấm

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | GĐ0 T2 ✅ (daemon + khung `fastcast-ui`) · materiant-gd1_01 (theme; kéo theo gd0_01 crate) |
| Quyết định áp dụng | F-4, D-6, F-2 |
| Phụ thuộc mới | `gpui-kit` =0.8.1 (không bật `gpui-component`) qua `materiant` |
| File đụng tới | `crates/ui/Cargo.toml` SỬA · `crates/ui/src/main.rs` SỬA · `crates/ui/src/app.rs` MỚI · `crates/ui/src/ipc.rs` MỚI · `crates/ui/src/keep_warm.rs` MỚI · `crates/ui/src/commands.rs` MỚI |

## 1. Làm gì

- `fastcast-ui` thành app GPUI: `Application::new().run`, `materiant::init(cx)`, theme / ngôn ngữ / cỡ chữ đọc từ
  `config.json` (`general.*`). Không mở cửa sổ khi chưa có lệnh — tiến trình sống không cửa sổ để giữ ấm.
- Luồng IPC nền (thay vòng `recv_timeout` của khung GĐ0): nhận `Message` từ daemon, đẩy vào vòng GPUI
  (`cx.spawn` + channel / `AsyncApp::update`), không chặn luồng UI.
- `commands.rs`: bảng `Command` → hàm mở tính năng (GĐ1 mới có stub log, các task sau gắn vào). Lệnh lặp khi tính năng
  đang mở ⇒ đưa cửa sổ lên trước, không mở thêm.
- `keep_warm.rs`: hàm thuần — mốc dùng cuối, còn cửa sổ mở thì không tính giờ; hết `keepWarmMins` ⇒ thoát êm. Lệnh
  `Quit` của daemon ⇒ đóng hết rồi thoát.
- `--command <id>` lúc khởi động chạy như một lệnh đến qua IPC.

## 2. Không làm trong task này

- Chưa có cửa sổ tính năng nào (overlay gd1_02, launcher gd1_06).
- Không đổi giao thức IPC.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `ipc.rs` (luồng IPC nền → kênh → vòng GPUI), `app.rs` (`UiState`, khởi động, thoát), `keep_warm.rs`, `commands.rs` (bảng lệnh + sổ cửa sổ theo tính năng), `main.rs` (tham số) | [opus] — đa luồng + vòng sự kiện + IPC |
| Test đơn vị `keep_warm`, `commands`, tham số; test tích hợp exe + daemon giả (`crates/ui/tests/ipc.rs`) | [opus-unit] / [opus-run] |
| Nhìn Task Manager khi dùng thật cùng daemon | [owner-qa] |

Không giao Sonnet: cả task là luồng sự kiện + IPC (nhãn `[opus]` theo khung mục 8), không có phần ghép UI.

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thông điệp mới. Đọc `uiProcess.keepWarmMins`, `general.{language, theme, fontSize}`.

## 4. Code

- Mẫu khởi động + đo khung đầu: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` (`main`, `on_next_frame`).
- Trạng thái app là một `Global` (`UiState`: config, i18n, cửa sổ đang mở theo tính năng).

## 5. Đo

- RAM `fastcast-ui` giữ ấm không cửa sổ (Task Manager, `tools/measure-ram.ps1 -Exe target/release/fastcast-ui.exe`).
- Thời gian từ `fst run capture_region` (UI chưa chạy) tới lúc UI nhận lệnh: nguội và ấm.

## 6. Nghiệm thu — Case test

| Case | Cho / Khi / Thì | Phủ |
| --- | --- | --- |
| C1 | Cho UI đang ấm, nối daemon (giả) · Khi daemon gửi `Run { capture_region }` · Thì UI ghi log `run capture_region` trong ≤ 50 ms | [opus-run] test tích hợp |
| C2 | Cho UI bật bằng `--command capture_region` · Khi khởi động · Thì lệnh chạy qua cùng đường `commands::dispatch` như lệnh IPC, UI nối daemon bằng `Hello { role: ui }` | [opus-run] |
| C3 | Cho giữ ấm T, không cửa sổ · Khi hết T không lệnh nào · Thì tiến trình thoát mã 0 | [opus-unit] + [opus-run] |
| C4 | Cho còn cửa sổ mở · Khi quá T · Thì không thoát; đóng cửa sổ cuối ⇒ đếm lại từ lúc đóng | [opus-unit] |
| C5 | Cho lệnh đến khi T chưa hết · Thì mốc dùng cuối dời theo lệnh | [opus-unit] |
| C6 | Cho UI đang chạy · Khi daemon gửi `Quit` (`fst quit`) · Thì đóng hết cửa sổ, thoát mã 0 | [opus-run] |
| C7 | Cho tính năng đã có cửa sổ mở · Khi lệnh đó tới lần nữa · Thì đưa cửa sổ đó lên trước, không mở thêm | [opus-unit] (sổ cửa sổ) |
| C8 | Cho daemon mất kết nối · Khi không còn cửa sổ · Thì UI thoát (không treo mồ côi) | [opus-run] |
| C9 | RAM `fastcast-ui` giữ ấm không cửa sổ — ghi số, so khung GĐ0 | [opus-run] |
| C10 | Cho không cửa sổ quá `--gpu-idle-secs` · Thì nhả GPU (headless); lệnh sau gắn lại GPU rồi mới mở tính năng | [opus-run] (thêm — đề xuất RAM) |

## 8. Nợ chuyển task khác

- Gắn tính năng vào `commands.rs`: gd1_02 (capture_region), gd1_06 (open_launcher), gd1_08 (ruler), gd1_09 (color_picker).

## 9. Bàn giao thực tế

Xong 30/10/2026 — fastcast `claude/gd1_01` (3 commit, gộp `master`). Case C1–C10 xanh (C4, C5, C7 bằng test đơn vị —
GĐ1 chưa có cửa sổ tính năng nào).

- **Code** (`crates/ui/src/`): `main.rs` tham số (`--command`, `--keep-warm-mins` của daemon; dev / test:
  `--keep-warm-secs`, `--gpu-idle-secs`, `--endpoint <tag>` ⇒ `Endpoint::custom`). `app.rs` — `UiState` (global: config,
  i18n, `KeepWarm`, sổ cửa sổ), `run`, `handle(Incoming)`, vòng hẹn giờ `watch_keep_warm`, `quit`, `with_gpu`.
  `ipc.rs` — luồng `ipc` đọc chặn → `futures::channel::mpsc::unbounded` → task `pump` trên vòng GPUI; `Ping` ⇒ `Pong`
  ngay ở luồng nền. `commands.rs` — `dispatch` (chung cho IPC và `--command`), `OpenWindows<H>` + `Route::{Focus, Open}`,
  `open` (stub — chỗ các task sau gắn). `keep_warm.rs` — `KeepWarm::{tick, touch, gpu_release_in}`, `timeout_from_mins`.
- **Ngoài danh sách tệp**: `Cargo.toml` (workspace dep `materiant = { path = "../materiant" }`), `deny.toml` thêm
  `CC0-1.0` (tiny-keccak, chỉ build Linux — đã chốt bên materiant), `core/src/logging.rs` thêm `FASTCAST_LOG_STDERR`
  (bản release ghi cả stderr — test đọc log exe con), `crates/ui/tests/ipc.rs` (exe thật + daemon giả),
  `crates/ui/examples/fake_daemon.rs`, `CLAUDE.md` (lệnh + bẫy). Phụ thuộc mới của `fastcast-ui`: `materiant`, `futures`
  0.3 (đã có trong cây qua gpui-pre); dev: `interprocess`. Mọi crate GPUI trong `Cargo.lock` cùng phiên bản với lock
  của materiant; không crate nào của daemon đổi phiên bản.
- **Đo** (release, máy nhà, GTX 1650, daemon giả):

  | Đo | Số |
  | --- | --- |
  | RAM giữ ấm, khung GĐ0 (không GPUI) | 0,94 MB (Task Manager), 5 luồng |
  | RAM giữ ấm GPUI, còn GPU | 9,67 MB · private bytes 51,7 MB · 25 luồng |
  | RAM giữ ấm GPUI, đã nhả GPU (mặc định sau 10 s) | **4,21 MB** · private bytes 12,5 MB · 8 luồng |
  | Spawn → lệnh `--command` chạy (nguội) | 320–370 ms (có lần 625–665 ms khi máy bận); `ui ready` ~300 ms là khởi động GPUI |
  | Lệnh IPC → log (ấm) | trung vị 0,05–0,13 ms, tối đa 0,30 ms (≤ 50 ms ✓) |
  | Lệnh khi đã nhả GPU → mở tính năng | 17–26 ms (gắn lại DirectX device) |

  "`fst run` → UI nhận lệnh" đo bằng daemon giả, không bật `fst` thật (sẽ đăng ký phím tắt toàn cục trên máy chủ dự án);
  phần daemon (`ui_process::spawn`) chỉ cộng thời gian `CreateProcess`.
- **Quyết định trong task** (chủ dự án vắng ⇒ tự chọn, đã ghi `plan/confirm.md`): nối materiant bằng đường dẫn
  `../materiant` (worktree cần junction `.claude/worktrees/materiant`); UI chỉ **đọc** `config.json` (daemon là bên tạo);
  `keepWarmMins: 0` ⇒ 1 phút như GĐ0; mất daemon ⇒ thoát khi đóng cửa sổ cuối (không cắt ngang việc đang làm);
  `general.fontSize` kẹp 10–32; nhả GPU sau 10 s rảnh.
- **Lỗi GPUI tìm ra**: gpui-pre-windows 0.3.10 `run_foreground_task` lố 10 ms thì vét hàng đợi bằng
  `PeekMessageW(PM_REMOVE)` ⇒ nuốt `WM_QUIT` ⇒ `cx.quit()` lúc vừa khởi động không có tác dụng (tái hiện: daemon không
  có ⇒ UI treo mãi). Né ở `app::quit`: gửi lại `quit` mỗi 100 ms tới khi vòng dừng.
- **Đề xuất đã làm** (D-8, mục 5 run-task): `[ram]` nhả GPU khi rảnh (`App::request_windowing(Headless)`), gắn lại trong
  `app::with_gpu` trước khi `commands::open` — giữ ấm 9,67 → 4,21 MB.
- Soát xanh trên nhánh: `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test` (74 test), `cargo deny
  check licenses`, `cargo fmt --check`.
- **Chờ kiểm tay** `[owner-qa]`: bật `fst` thật, `fst run capture_region` (log `ui.log` có `run capture_region`), để yên
  > 10 s xem Task Manager `fastcast-ui` ~4 MB, đợi hết `keepWarmMins` ⇒ tiến trình biến mất; `fst quit` ⇒ UI tắt theo.

## 10. Đề xuất cải tiến

- `[ram]` Giữ ấm GPUI 9,7 MB, phần lớn là DirectX device + vsync — bằng chứng: bảng đo mục 9 — nhả GPU sau 10 s rảnh,
  gắn lại khi có lệnh (17–26 ms) — giữ ấm còn 4,2 MB — S — P1 — **đã làm**.
- `[bảo mật]` Pipe `fastcast-<user>` đoán được tên; tiến trình khác tạo pipe trước daemon thì UI / CLI nối nhầm và nhận
  lệnh giả (mở overlay, `Quit`) — bằng chứng: `core/src/ipc.rs` `Endpoint::daemon` + `listen` không cờ
  `FILE_FLAG_FIRST_PIPE_INSTANCE`, không ACL — daemon tạo pipe với first-instance + DACL chỉ người dùng hiện tại, client
  kiểm `GetNamedPipeServerProcessId` là `fst` — chặn giả mạo cục bộ — M — P2 — backlog (cần chạy daemon thật để kiểm).
- `[ux]` Khởi động nguội ~300 ms trước khi UI nhận lệnh đầu (phím tắt → khung đầu của overlay sẽ ≥ 300 ms khi UI chưa
  ấm) — bằng chứng: `ui ready in 300–345 ms` (release) — đo từng bước khởi động GPUI (DirectWrite, DirectX, theme) xem có
  phần nào hoãn được; hoặc daemon bật sẵn UI headless (~4,2 MB) sau khi đăng nhập — M — P3 — backlog (đánh đổi RAM ⇒ chờ
  chủ dự án chọn).
