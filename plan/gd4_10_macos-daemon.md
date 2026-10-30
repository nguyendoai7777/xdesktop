# gd4_10 — macOS: daemon `fst`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ mã — chờ chạy trên Mac (30/10/2026) |
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

## 2b. Phân vai

| Phần việc | Vai |
|---|---|
| Vòng sự kiện, FFI, autostart, nhánh clipboard | `[opus]` |
| Chạy trên Mac | `[owner-qa]` hoặc session trên Mac |

## 5. Đo

RAM nghỉ `phys_footprint` ≤ 5 MB: bản release, để yên ≥ 10 s.

## 6. Nghiệm thu

- C1 `[opus-run]` ✅ Cho nhánh này, khi `cargo check --locked --target aarch64-apple-darwin -p fastcast-daemon` (+ clippy `--all-targets -D warnings` cùng target, biên dịch cả test macOS), thì xanh.
- C2 `[opus-run]` ✅ Cho Windows, khi build, clippy, test `-p fastcast-daemon -p fastcast-core` + `cargo deny check licenses`, thì xanh (lý do `-p`: mục 9).
- C3 `[opus-unit]` ✅ `launch_agent_has_args_and_escaped_path`, `app_bundle_is_recognised` chạy trên Windows.
- C4 `[owner-qa]` ☐ **Chưa chạy.** Cho Mac, khi `cargo test -p fastcast-daemon -p fastcast-core`, thì xanh, gồm `default_hotkeys_are_free_on_macos`.
- C5 `[owner-qa]` ☐ **Chưa chạy.** Cho Mac, khi chạy `fst`, thì không icon Dock, có khay, menu mở được, 6 phím tắt bắn lệnh, `fst status` đúng, `fst quit` thoát hẳn, `fst` lần hai mở launcher rồi thoát.
- C6 `[owner-qa]` ☐ **Chưa chạy.** Exe rời: `fst autostart on` ghi plist, đăng nhập lại daemon lên sau độ trễ, `off` xoá tệp. Trong `.app` (sau gd4_13): `on` qua `SMAppService` hoặc dự phòng, không bật hai lần.
- C7 `[owner-qa]` ☐ **Chưa đo.** RAM nghỉ `phys_footprint` ≤ 5 MB (`footprint <pid>`, release, ≥ 10 s).

## 8. Nợ chuyển task khác

- `gd4_18`: lấy số RAM macOS, gộp C4–C7 vào danh sách kiểm tay.
- `gd4_11`: UI tự kích hoạt cửa sổ; daemon không có `allow_foreground` trên macOS.

## 9. Bàn giao thực tế

**Đã làm**: `platform/macos.rs` (vòng `NSApplication` `Accessory`, đánh thức qua hàng đợi chính libdispatch, `init` chạy sau khi vòng đã vào `run`, `stop` kèm sự kiện giả); `autostart.rs` (`SMAppService.mainApp` trong `.app` macOS 13+, dự phòng + exe rời: `~/Library/LaunchAgents/com.fastcast.daemon.plist`); `clipboard.rs` (pool autorelease trên luồng clipboard, vì `arboard` không bọc khi ghi). UI bật cạnh exe: `ui_process.rs` đã đúng cho `Contents/MacOS/`, không sửa. Không có dòng nào đã chạy trên Mac.

**Soát**: C1–C3 xanh sau khi gộp `master` (`383876e`): core 70 + 5, daemon 27 + 2 test. Bốn lệnh Windows chạy bằng `-p`, chưa chạy toàn workspace: luật làn cho tối đa ba làn build GPUI, ba làn Settings đang chạy; thay đổi chỉ trong daemon + khối macOS của lock, `--locked` xanh. Không chạy `fst` thật trên máy nhà (luật làn).

**Opus chọn 30/10/2026** (đều ở `plan/confirm.md`): giữ Ctrl mặc định; `SMAppService` không có độ trễ; không hạ ưu tiên trên macOS; thêm `dispatch2`.

**Ngoài danh sách tệp, chỉ thêm thuộc tính cho OS khác**: `daemon.rs` + `autostart.rs::entry_name` có `cfg_attr(not(windows), allow(dead_code))`, thiếu thì clippy macOS đỏ. Hàm thuần `launchd` đặt ngoài `cfg` theo mẫu `task` / `xdg` để test chạy trên Windows.

**`autostart_failed`**: daemon chỉ log `warn` và trả `Err` cho `fst autostart`; chữ i18n hiện ở UI do làn `gd4_02`. Dự phòng thành công thì không báo lỗi.

## 10. Đề xuất cải tiến

Bảo mật: plist nằm trong thư mục người dùng, không chứa dữ liệu nhạy cảm. UI/UX: chờ duyệt Login Items được báo trong `fst autostart on`; nút mở System Settings là việc của UI, chưa làm. RAM: chưa đo được, C7. Pro: không áp. Không có đề xuất phải làm thêm trong lượt.
