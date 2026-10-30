# gd4_04 — Settings: Lưu và quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026), `[owner-qa]` Win+V chờ kiểm tay |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-4, F-7, F-8 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_capture.rs`, `crates/daemon/src/clipboard.rs`; MỚI `crates/ui/tests/settings_capture.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Thư mục ảnh, thư mục video: đường dẫn hiện tại, nút chọn (`cx.prompt_for_paths`), nút về mặc định. Không ghi được ⇒ `settings.dir_unwritable`, giữ giá trị cũ. Thử ghi bằng tệp tạm rồi xoá. F-8, nợ gd1_04, gd3_12.
- Quay mặc định: độ nét 480 / 720, FPS 1–60, âm thanh, con trỏ: cùng khoá `record.*` mà bảng quay đang nhớ (gd3_10).
- Giữ ấm tiến trình UI: `uiProcess.keepWarmMins` 1–60.
- Tuỳ chọn "không đưa ảnh chụp vào lịch sử clipboard" (Windows): daemon đọc `clipboard.excludeFromHistory`, dùng `exclude_from_history` của `arboard`. OS khác ẩn dòng này. Nợ gd1_05 mục 10.
- Dòng khoá: `FileNameTemplates`, `CaptureHistory`, `HighResRecording`.

## 2. Không làm trong task này

Mẫu tên tệp, JPEG / WebP, quay trên 720p. Sửa `save.rs` hay `record/`.

## 4. Code

Hộp thoại chọn thư mục của OS mở ở màn chính ⇒ khi chạy thử luôn đi qua `dev::pick_dir_answer` (`FASTCAST_SETTINGS_PICK_DIR`), không mở hộp thoại thật. `clipboard.rs` đọc cờ từ config daemon đang giữ, không thêm crate.

## 5. Đo

`clipboard.rs` đổi trong daemon, không thêm phụ thuộc ⇒ không đo RAM ở làn; gd4_18 đo daemon lần cuối.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh.
- [ ] Đổi thư mục (giả bằng `FASTCAST_SETTINGS_PICK_DIR`) ⇒ `save.imageDir` đúng, lưu ảnh màn giả rơi vào đó. `cancel` ⇒ không đổi. Thư mục chỉ đọc ⇒ báo lỗi, không đổi.
- [ ] FPS 0 hoặc 61 không ghi vào config; `keepWarmMins` đổi ⇒ log `config reloaded`, hạn giữ ấm mới.
- [ ] `settings-run.ps1 -Page capture` chụp sáng / tối. Chỉ màn DELL.
- [ ] `[owner-qa]` Bật tuỳ chọn, chụp, chép ảnh, mở Win+V: ảnh không có trong lịch sử, vẫn dán được.

## 7. Ghi chú UI

Đường dẫn dài cắt ở giữa, giữ tên thư mục cuối. Log không ghi đường dẫn (luật gd1_04).

## 8. Nợ chuyển task khác

Trang chưa có tiêu đề nhóm (`row::section`): thiếu khoá i18n, nhóm bằng khoảng cách. Thêm khoá thì gd4_18 hoặc task trau chuốt làm, không chặn.

## 9. Bàn giao thực tế

- **Phân vai**: Opus làm hết, không giao Sonnet: trang ~400 dòng gắn chặt ô số + hẹn giờ, không đáng tách.
- **Case**: C1 chọn thư mục ⇒ `save.imageDir` đúng, ảnh màn giả rơi vào đó trong cùng tiến trình · C2 `cancel` không đổi · C3 thư mục ACL chặn ghi ⇒ báo lỗi, giữ cũ · C4 FPS 0 / 61 không ghi, 45 ghi một lần · C5 `keepWarmMins` = 1 ⇒ `config reloaded`, thoát sau 60 s · C6 về mặc định ⇒ `None`, khoá khác giữ nguyên. Tất cả ở `crates/ui/tests/settings_capture.rs`. Cờ clipboard: `exclude_flag_reaches_the_backend_for_image_and_text`.
- **Chạy thật**: `settings-run.ps1 -Page capture` sáng, tối, trạng thái lỗi, cửa sổ cao hơn tạm thời để thấy ba dòng khoá: đúng màn DELL, không giành foreground. Ảnh đã xoá. `arboard` chỉ kiểm qua build: cờ thật trên Win+V chờ chủ dự án.
- **Quyết định**: bốn gạch `[gd4_04]` ở `plan/confirm.md`. Ô số không đặt `range` (NumberField kẹp khi rời ô, F-7 không kẹp), chờ 300 ms mới ghi để hai lần ghi không về sai thứ tự; ghi tách khỏi trang nên đóng cửa sổ ngay vẫn lưu.
- **Ngoài cột sở hữu**: một dòng `daemon.rs`; `dev.rs` chép nguyên bản vá phát `KeyUp` của gd4_02 (Button kích hoạt lúc nhả phím, thiếu thì `tab enter` không bấm được nút).
- **Bẫy**: xung đột `clipboard.rs` với khối `autoreleasepool` của gd4_10 lúc gộp, giữ cả hai. Chạy thử không có `FASTCAST_SETTINGS_PICK_DIR` thì nút chọn chỉ ghi log, không mở hộp thoại thật.
- **Chờ kiểm tay** `[owner-qa]`: `plan/_backlog.md`.

## 10. Đề xuất cải tiến

Soi xong. Bảo mật: tệp thử bị xoá kể cả khi ghi hỏng, log không có đường dẫn. RAM: không thêm phụ thuộc, cờ chỉ là một `bool` trên `Job`. Pro: ba dòng khoá đã đặt.

- [ux] Ô FPS không theo khi bảng quay ghi `record.fps` lúc Settings đang mở — `record_panel.rs::remember` đổi thẳng `config.record`, `number_field` chỉ đặt giá trị lúc tạo — đặt lại ô khi trang vẽ — giá trị thấp, không ghi đè nhầm vì trang chỉ ghi khi người dùng gõ — S — P3. Không làm: hiếm gặp.
- Đã làm trong lượt: chặn bấm "Chọn…" hai lần mở hai hộp thoại (`picking`).
