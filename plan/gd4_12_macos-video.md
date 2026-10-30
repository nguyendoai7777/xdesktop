# gd4_12 — macOS: quay vùng + OCR

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Viết + `cargo check --target` được trên máy nhà; ✅ cuối cần chạy trên Mac |
| Repo | fastcast |
| Cỡ | M — ~850 dòng; vượt trần ⇒ tách âm thanh ra task riêng trước khi code |
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

- `SCStream` + `sourceRect` → `AVAssetWriter` H.264 + AAC, cùng giao thức `RecRequest` / `RecEvent` với Windows. Mẫu: `docs/spikes/video.md` mục 8.
- Vùng vắt hai màn: dùng lại `source/compose.rs` nếu nguồn trả được từng màn; không thì `Unsupported` có chữ báo rõ, ghi `confirm.md`.
- Âm hệ thống qua ScreenCaptureKit, micro qua `AVCaptureDevice` (có hộp thoại xin quyền).
- `fastcast-ocr` chạy trên Mac: model dùng chung, dylib + sha256.

## 2. Không làm trong task này

Dự phòng OpenH264. Sửa nhánh Windows. `.app` (gd4_13).

## 5. Đo

720p30: CPU, RAM, tệp mở bằng QuickTime + `mp4_verify` trên Mac. So với 3,9 % / 26,7 MB của Windows.

## 6. Nghiệm thu

- [ ] `cargo check --target aarch64-apple-darwin -p fastcast-video -p fastcast-ocr` + `cargo test -p fastcast-video` trên Windows.
- [ ] Trên Mac: `crates/video/tests` qua cửa sổ thử, `ocr_bench`, quay vùng thật kèm tiếng, OCR tiếng Việt.
- Chưa chạy được trên Mac ⇒ ghi `✅ mã — chờ chạy trên Mac`, gạch `_backlog.md`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
