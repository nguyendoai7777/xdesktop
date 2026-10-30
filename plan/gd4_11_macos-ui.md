# gd4_11 — macOS: UI, overlay, chụp màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Mac. Máy nhà không biên dịch chéo được `fastcast-ui`: `gpui-pre-apple` chỉ dựng shader Metal trên Mac (đã thử 30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~500 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-3, F-3, F-4 |
| Phụ thuộc mới | `objc2-*` (MIT, khối macOS của `crates/ui/Cargo.toml`, `crates/capture/Cargo.toml`) |
| File đụng tới | SỬA `crates/ui/src/platform/macos.rs`, `crates/capture/src/lib.rs` (nhánh macOS + báo thiếu quyền), `crates/ui/Cargo.toml`, `crates/capture/Cargo.toml`; MỚI `crates/capture/src/macos.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- `platform/macos.rs`: `hide` / `show`, `cursor_display`, `set_cursor_pos` (nợ gd1_09), `exclude_from_capture` (`NSWindow.sharingType`), `exit_now`.
- Quyền Screen Recording: `CGPreflightScreenCaptureAccess`; thiếu ⇒ thông báo + mở System Settings đúng trang, không chụp ảnh nền trống.
- Overlay: cửa sổ phủ thanh menu + Dock trên từng màn, pixel vật lý = điểm × `backingScaleFactor`, gốc toạ độ macOS lật trục Y (F-3: chỉ đổi ở lớp `capture` / vẽ).
- Soát trên Mac: `xcap` CoreGraphics chụp nhiều màn, font chữ chú thích `Helvetica Neue` (nợ gd2_04), chép ảnh, Cmd+S, hộp thoại lưu.

## 2. Không làm trong task này

Quay (gd4_12). `.app` (gd4_13). Sửa nhánh Windows.

## 5. Đo

Overlay 2 màn, khung đầu, RAM giữ ấm so với số GĐ1 (`docs/gd1-report.md`).

## 6. Nghiệm thu

- [ ] Trên Mac: bốn lệnh soát xanh, `cargo test -p fastcast-capture`, test UI màn giả; danh sách kiểm tay `docs/gd1-report.md` mục 4 + `docs/gd2-report.md` mục 4 bản Cmd, hai màn khác scale.
- [ ] Bốn lệnh trên Windows vẫn xanh trước khi gộp.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
