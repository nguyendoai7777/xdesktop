# gd4_10 — macOS: daemon `fst`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Viết + `cargo check --target aarch64-apple-darwin` được trên máy nhà; ✅ cuối cần chạy trên Mac |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-3, F-4, F-5, F-9 |
| Phụ thuộc mới | `objc2`, `objc2-foundation`, `objc2-app-kit`, `objc2-service-management` (MIT, chỉ khối `[target.'cfg(target_os = "macos")']`) — `objc2` đã có trong cây; đo RAM |
| File đụng tới | SỬA `crates/daemon/src/platform/macos.rs`, `crates/daemon/src/autostart.rs` (chỉ `mod` macOS), `crates/daemon/src/clipboard.rs` (chỉ nhánh `cfg`), `crates/daemon/Cargo.toml` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Vòng `NSApplication` trên luồng chính, kiểu `Accessory` (không icon Dock), `Waker` đưa `Event` vào vòng.
- `global-hotkey` + `tray-icon` chạy trên macOS: phím mặc định đổi Ctrl sang Cmd nếu trùng hệ thống (`hotkey.rs` có `system_reserved`, soát `default_hotkey`).
- Tự khởi động bằng `SMAppService.mainApp` (F-5); chưa ký thì `register` có thể từ chối ⇒ báo `autostart_failed`, dự phòng LaunchAgent trong `~/Library/LaunchAgents`.
- UI bật cạnh exe; trong `.app` là `Contents/MacOS/`.
- Clipboard ảnh / chữ của `arboard`; `release_clipboard_memory` no-op.

## 2. Không làm trong task này

UI, chụp màn. Ký + notarize (Apple Developer trả phí, chủ dự án quyết). Quyền Screen Recording (gd4_11).

## 5. Đo

RAM nghỉ `phys_footprint` ≤ 5 MB: bản release, để yên ≥ 10 s.

## 6. Nghiệm thu

- [ ] `cargo check --target aarch64-apple-darwin -p fastcast-daemon` + bốn lệnh soát xanh trên Windows (nhánh Windows không đổi).
- [ ] Trên Mac (`[owner-qa]` hoặc session trên Mac): `cargo test -p fastcast-daemon -p fastcast-core`; `fst` chạy, khay, 6 phím tắt, `fst status`, `fst quit`, một instance, autostart on / off + đăng nhập lại.
- Chưa chạy được trên Mac ⇒ ghi `✅ mã — chờ chạy trên Mac`, thêm gạch `_backlog.md`, không tự ghi đạt.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
