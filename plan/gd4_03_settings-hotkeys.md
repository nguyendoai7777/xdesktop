# gd4_03 — Settings: Phím tắt

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-2, D-4 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_hotkeys.rs`, `crates/ui/src/launcher/{view,actions,mod}.rs`, `crates/ui/src/settings/store.rs`, `crates/ui/src/dev.rs`; MỚI `crates/ui/src/hotkey_dialog.rs`, `crates/ui/tests/settings_hotkeys.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Bảng mọi lệnh: icon, tên, chip phím hiện tại, trạng thái `FAILED` từ `StatusRequest`; ô lọc không dấu (dùng lại `launcher/filter.rs`, chỉ đọc).
- Mỗi dòng: Đổi · Gỡ · Lịch sử (menu, Quay lại tổ hợp cũ) · Về mặc định. Nút "về mặc định tất cả" có hộp thoại xác nhận.
- **Báo trùng trước khi ghi**: trùng lệnh khác ⇒ "Lấy phím"; `system_reserved` ⇒ cảnh báo + "Vẫn gán"; OS từ chối sau khi ghi ⇒ báo + Quay lại. Toàn bộ logic đã có ở `launcher/actions.rs` (`check`, `commit`, `Change`).
- Tách hộp thoại ghi phím khỏi `LauncherView` (`Panel`) thành `hotkey_dialog.rs`, launcher và Settings cùng dùng (nợ gd1_07 mục 8). Hành vi launcher không đổi.
- Có cả phím mở launcher (`OpenLauncher`) trong bảng, đúng spec "phím để mở panel nhanh".

## 2. Không làm trong task này

Hồ sơ phím theo app (Pro, chỉ có dòng khoá `AppHotkeyProfiles`). PrintScreen từ launcher (backlog gd1_07, cần phím thật). Sửa `launcher/filter.rs`.

## 2b. Phân vai

`[opus]` tách `hotkey_dialog.rs` (pha capture, `cx.intercept_keystrokes`, cờ `swallow_key`), bảng + menu dòng, test. Không giao Sonnet (lý do ở mục 9).

## 4. Code

`SuspendHotkeys` gửi lại định kỳ như `launcher/mod.rs::suspend_hotkeys`; đóng Settings giữa lúc ghi ⇒ `ResumeHotkeys`. UI chết ⇒ daemon tự đăng ký lại (đã có).

## 5. Đo

Mở trang dưới 30 ms sau khi cửa sổ đã có (đọc từ log); danh sách ít dòng nên không cần ảo hoá.

## 6. Nghiệm thu

Test tích hợp ở `crates/ui/tests/settings_hotkeys.rs`: test đóng vai daemon theo đúng hành vi `fake_daemon`, phím đưa bằng `FASTCAST_SETTINGS_KEYS`.

- [x] C1 `[opus-unit]` Cho bảng lệnh. Khi lọc rỗng / `thuoc` / `ruler` / `zzz`. Thì đủ mọi lệnh kể cả `OpenLauncher` / Thước căn / Thước căn / rỗng.
- [x] C2 `[opus-test]` Khi gán tổ hợp mới. Thì SUSPEND, RESUME, RELOAD đúng thứ tự, tệp cấu hình đổi.
- [x] C3 `[opus-test]` Khi ghi phím của lệnh khác. Thì hỏi trước khi ghi, Enter lấy phím, lệnh kia mất phím.
- [x] C4 `[opus-test]` Cho `taken <tổ hợp>`. Khi gán tổ hợp đó. Thì báo, Enter Quay lại, về tổ hợp cũ.
- [x] C5 `[opus-test]` Khi gỡ, khôi phục từ lịch sử, về mặc định từ menu ⋯. Thì mỗi lần có RELOAD, bảng cuối đúng.
- [x] C6 `[opus-test]` Về mặc định tất cả: Esc không đổi gì, Enter đổi. `[opus-unit]` hoán đổi phím vẫn về đúng mặc định.
- [x] C7 `[opus-test]` Esc lúc đang ghi ⇒ RESUME, không ghi gì.
- [x] C8 `[opus-test]` `WM_CLOSE` lúc đang ghi ⇒ RESUME. Daemon không kẹt trạng thái tạm gỡ.
- [ ] C9 `[owner-qa]` Gán thật với `fst` thật: bước C7 của `plan/gd1_07_hotkey-assign.md`, làm từ Settings.
- [x] C10 `[opus-run]` `settings-run.ps1 -Page hotkeys`: đã soi ảnh bảng (sáng, vi), hộp ghi phím (tối, vi), hộp lấy phím (sáng, en), menu ⋯ (tối, en). Chỉ màn DELL, không giành foreground. Chưa soi đủ cả bốn tổ hợp cho từng trạng thái.
- [x] C11 Bốn lệnh soát xanh; test launcher / gd1_07 cũ giữ nguyên ý, chỉ đổi chỗ đọc trạng thái sang entity mới.

## 7. Ghi chú UI

```
[ô lọc]                               [về mặc định tất cả]
icon  Chụp vùng      [Ctrl] [Shift] [1]     Đổi   ⋯
icon  Thước căn      chưa gán               Đổi   ⋯
icon  Lấy màu        [Ctrl] [Shift] [3] ! không đăng ký được
```

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

- **Thiết kế**: `HotkeyDialog` là entity, chủ nhà vẽ nó làm con, chuyển phím pha capture, nghe `HotkeyDialogEvent`. `suspend_hotkeys`, `commit_outcome`, `hotkey_label` chuyển sang `hotkey_dialog.rs`, launcher gọi lại.
- **Lỗi thật đã sửa**: cờ `swallow_key` bị kẹt khi Enter đóng hộp thoại và trả focus về nút Đổi, phím kế bị nuốt (Enter ở hộp báo lỗi không Quay lại). Cờ giờ chỉ sống một lượt phím (`cx.defer`). Launcher không thấy lỗi này vì focus về ô tìm.
- **Ngoài cột sở hữu, cần thiết**: `launcher/mod.rs` (mở module, dùng hàm chung); `settings/store.rs` (`save` thành `pub`, để `actions::save` cùng khoá `WRITING` với các trang, tránh hai lần ghi đè nhau); `dev.rs` (phát cả KeyUp, trùng từng dòng với gd4_02, gd4_04).
- **Đổi so với spec**: không sửa `recorder.rs`; trạng thái lỗi là câu đầy đủ `settings.hotkeys_register_failed` dưới tên lệnh, không phải nhãn ngắn. Nút ⋯ dùng ký tự vì materiant chưa có icon, nhãn trợ năng `launcher.actions`.
- **Opus chọn 30/10/2026**: tự làm phần `[sonnet]` — bảng dính chặt interface vừa tách và test tích hợp, giao đi phải chép lại gần hết ngữ cảnh. Về mặc định tất cả dùng `set_force` từng lệnh, không qua `Change` — một `Change` chỉ cho một lệnh, trạng thái lỗi hiện ngay trên bảng.
- **Đo**: đổi trang sang Phím tắt 35,3 ms ở bản **debug**, sát trên chuẩn 30 ms; chưa đo release, để gd4_18. RAM khi hộp thoại mở 19–20 MB (debug, không phải số chính thức).
- **Soát**: build, clippy, deny xanh. `cargo test` toàn workspace có một test đỏ khi máy bận (`fake_wheel_needs_a_tool_and_adds_up_touchpad_deltas` của overlay), chạy lại riêng thì xanh; các tệp test sau overlay chạy lại riêng, xanh.
- **Chờ kiểm tay**: C9, ghi `_backlog.md`.

## 10. Đề xuất cải tiến

- [ux] Nút về mặc định tất cả vẫn bấm được khi mọi lệnh đã mặc định — `page_hotkeys.rs` — tắt nút — nhỏ — S — P3. Chưa làm: P3.
- [ux] Trạng thái FAILED không tự cập nhật khi daemon đọc lại cấu hình từ nơi khác — `page_hotkeys.rs::sync` chỉ dựng lại bảng phím, không hỏi lại `StatusRequest` — hỏi lại khi bảng đổi — vừa — S — P3. Chưa làm: P3.
- Bảo mật, RAM: không áp (không thêm IPC, phụ thuộc, tiến trình nền). Pro: hồ sơ phím theo app đã có dòng khoá ở trang Pro.
