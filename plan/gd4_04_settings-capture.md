# gd4_04 — Settings: Lưu và quay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-4, F-7, F-8 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_capture.rs`, `crates/daemon/src/clipboard.rs`; MỚI `crates/ui/tests/settings_capture.rs` |

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

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
