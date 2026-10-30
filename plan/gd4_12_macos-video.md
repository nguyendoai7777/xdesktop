# gd4_12 — macOS: quay vùng + OCR

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ mã — chờ chạy trên Mac (30/10/2026) |
| Máy | Viết + `cargo check --target` được trên máy nhà; ✅ cuối cần chạy trên Mac |
| Repo | fastcast |
| Cỡ | M — ~790 dòng; âm thanh đã tách sang `gd4_19` |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-3, F-6, F-7 |
| Phụ thuộc mới | `objc2-screen-capture-kit`, `objc2-av-foundation`, `objc2-core-media` (MIT, khối macOS của `crates/video/Cargo.toml`); `ort` bản macOS: soát cách nạp `libonnxruntime.dylib` |
| File đụng tới | SỬA `crates/video/src/macos/mod.rs`, `crates/video/src/session.rs` (chỉ nhánh `cfg`), `crates/video/src/audio.rs` (chỉ nhánh `cfg`), `crates/video/src/source/mod.rs` (chỉ khai báo), `crates/video/Cargo.toml`, `crates/ocr/src/main.rs` (đường tìm dylib); MỚI `crates/video/src/macos/{capture,writer}.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- `SCStream` + `sourceRect` → `AVAssetWriter` H.264, cùng giao thức `RecRequest` / `RecEvent` với Windows. Mẫu: `docs/spikes/video.md` mục 8.
- Vùng vắt hai màn: dùng lại `source/compose.rs` nếu nguồn trả được từng màn; không thì `Unsupported` có chữ báo rõ, ghi `confirm.md`.
- `fastcast-ocr` chạy trên Mac: model dùng chung, dylib + sha256.

## 2. Không làm trong task này

Dự phòng OpenH264. Sửa nhánh Windows. `.app` (gd4_13). Âm thanh (gd4_19).

## 5. Đo

720p30: CPU, RAM, tệp mở bằng QuickTime + `mp4_verify` trên Mac. So với 3,9 % / 26,7 MB của Windows.

## 2b. Phân vai

Toàn bộ `[opus]` (FFI theo OS, đa luồng, hình học đa màn); phần chạy trên Mac `[owner-qa]`. Không giao Sonnet.

## 6. Nghiệm thu

- C1 `[opus-run]` ✅ Cho master + mã này; khi `cargo check --locked --target aarch64-apple-darwin -p fastcast-video -p fastcast-ocr --all-targets` và clippy cùng target `-D warnings`; thì xanh.
- C2 `[opus-unit]` ✅ `cargo test -p fastcast-video -p fastcast-ocr` trên Windows: `mac_portable` (validate, mã lỗi writer, `display_rect`, `source_rect`, `scaled_piece`, `blit_bgra`, `Part`), `bundle_models`; test Windows cũ vẫn xanh.
- C3 `[owner-qa]` ☐ Trên Mac: `cargo test -p fastcast-video --test macos` (writer ra MP4 không cần quyền; âm báo `AudioUnavailable`).
- C4 `[owner-qa]` ☐ Trên Mac: `cargo test -p fastcast-video --test macos -- --ignored`, quay vùng thật 3 s; tệp mở bằng QuickTime.
- C5 `[owner-qa]` ☐ Vùng vắt hai màn: ghép đúng chỗ, khe đen; rút màn giữa lúc quay ⇒ `DisplayChanged`, tệp vẫn còn.
- C6 `[owner-qa]` ☐ Thiếu quyền Screen Recording: có hộp thoại OS, `Failed { CaptureLost }`, không treo.
- C7 `[owner-qa]` ☐ OCR: `pwsh tools/fetch-ocr-models.ps1 -Vnocr <vnocr>/models -Out <đích>`, `ocr_bench`, OCR tiếng Việt, `FASTCAST_OCR_MODELS` và `Contents/Resources/models`.
- C8 `[owner-qa]` ☐ Đo 720p30 trên Mac: CPU, RAM (`footprint`), so với 3,9 % / 26,7 MB của Windows.
- Quay kèm tiếng: chuyển sang gd4_19.

## 8. Nợ chuyển task khác

- **gd4_19**: âm thanh. Trong lúc chờ, `run` trả `AudioUnavailable` khi `job.audio` khác `None`.
- **gd4_11**: phải dùng cùng công thức toạ độ màn với `mac_portable::display_rect` (đã ghi vào tệp task đó).
- **gd4_13**: `NSMicrophoneUsageDescription` bắt buộc trước khi gd4_19 xin quyền, model vào `Contents/Resources/models`.
- **gd4_16**: `Part`, `validate`, `pending` đang chép lại vì nằm trong `mod win` của `session.rs` (luật làn không cho sửa nhánh Windows): khi làm Linux nên gom về một module chung.

## 9. Bàn giao thực tế

- **Chưa chạy dòng nào trên Mac.** Chỉ biên dịch chéo + test hàm thuần trên Windows; các giả định về hành vi ScreenCaptureKit, AVAssetWriter chờ C3–C8.
- Soát trên Windows: `cargo check --locked --target aarch64-apple-darwin -p fastcast-video -p fastcast-ocr --all-targets` xanh, clippy hai target `-D warnings` xanh, `cargo test -p fastcast-video -p fastcast-ocr -- --test-threads=4` xanh (lib video 50, encoder 15, session 10; ocr 44 + 1 + 17 + 6), `cargo deny check licenses` ok. Số test `crates/video/tests/macos.rs` trên Windows là 0 vì chỉ biên dịch cho Mac.
- Tách trước khi code (Opus chọn 30/10/2026): ước lượng lại ~1.210 dòng, vượt trần 900 ⇒ âm thanh sang `gd4_19_macos-audio`. Thực tế: 781 dòng không tính dòng trống + comment + test (~950 dòng thô).
- Phụ thuộc: 8 crate `objc2-*`, `block2`, `dispatch2` trong khối macOS (vượt trần 2 crate của khung, task đã liệt kê sẵn ba cái, phần còn lại là cùng họ; chỉ `objc2-screen-capture-kit` là mới với lock). Không vào Windows, daemon.
- Mới: `macos/{capture,writer,portable}.rs`, `tests/macos.rs`. `portable.rs` khai báo ở `source/mod.rs` qua `#[path]` để test chạy được trên Windows. `FASTCAST_REC_WINDOW=<CGWindowID>` quay cửa sổ thử trên Mac.
- `tools/fetch-ocr-models.ps1` thêm nhánh macOS: `onnxruntime-osx-arm64-1.31.1.tgz`, sha256 `2e1344a1…896d6f` đo từ bản phát hành; đã xem danh sách tệp trong gói, chưa nạp thử. Tệp này ngoài danh sách của task, là phần "dylib + sha256" của mục 1.
- **Sửa ngoài phạm vi vì luật màn hình**: `examples/source_probe.rs` mở cửa sổ ở (0, 0), tức màn LG, khi chạy `crates/video/tests`. Đổi sang màn phụ đầu tiên (`test_origin`); máy một màn vẫn (0, 0).
- `mp4_verify`, `source_probe`, `crates/video/tests/{session,encoder}.rs` chỉ có trên Windows ⇒ trên Mac soát bằng `tests/macos.rs` + QuickTime, không theo đúng dòng mục 5 cũ.
- Lăng kính: bảo mật: log chỉ mã lỗi vì mô tả `NSError` có thể chứa đường dẫn. UX: thiếu quyền quay ra `CaptureLost` vì `RecError` chưa có mã riêng (`gd4_11` chặn trước ở UI). RAM: `QUEUE_DEPTH` 5, bộ đệm 720p 3,7 MB; chưa đo. Pro: không áp.

## 10. Đề xuất cải tiến

- [ux] Thiếu quyền Screen Recording báo chung "mất nguồn" — `capture.rs::check_permission` — thêm `RecError::PermissionDenied` + khoá i18n — người dùng biết cách gỡ — S — P2. Đụng `core/worker.rs`, `i18n` (tệp chung) ⇒ ghi vào backlog, làm sau khi các làn gộp.
- [ram] Khung BGRA tốn hơn `420v` khi một màn phủ trọn — `capture.rs::configuration` — đo trên Mac rồi đổi — RAM, CPU — S — P3. Cần Mac.
