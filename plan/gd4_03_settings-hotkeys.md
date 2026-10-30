# gd4_03 — Settings: Phím tắt

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-2, D-4 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_hotkeys.rs`, `crates/ui/src/launcher/{view,recorder,actions}.rs`; MỚI `crates/ui/src/hotkey_dialog.rs`, `crates/ui/tests/settings_hotkeys.rs` |

## 1. Làm gì

- Bảng mọi lệnh: icon, tên, chip phím hiện tại, trạng thái `FAILED` từ `StatusRequest`; ô lọc không dấu (dùng lại `launcher/filter.rs`, chỉ đọc).
- Mỗi dòng: Đổi · Gỡ · Lịch sử (menu, Quay lại tổ hợp cũ) · Về mặc định. Nút "về mặc định tất cả" có hộp thoại xác nhận.
- **Báo trùng trước khi ghi**: trùng lệnh khác ⇒ "Lấy phím"; `system_reserved` ⇒ cảnh báo + "Vẫn gán"; OS từ chối sau khi ghi ⇒ báo + Quay lại. Toàn bộ logic đã có ở `launcher/actions.rs` (`check`, `commit`, `Change`).
- Tách hộp thoại ghi phím khỏi `LauncherView` (`Panel`) thành `hotkey_dialog.rs`, launcher và Settings cùng dùng (nợ gd1_07 mục 8). Hành vi launcher không đổi.
- Có cả phím mở launcher (`OpenLauncher`) trong bảng, đúng spec "phím để mở panel nhanh".

## 2. Không làm trong task này

Hồ sơ phím theo app (Pro, chỉ có dòng khoá `AppHotkeyProfiles`). PrintScreen từ launcher (backlog gd1_07, cần phím thật). Sửa `launcher/filter.rs`.

## 2b. Phân vai

`[opus]` tách `hotkey_dialog.rs` (pha capture, `cx.intercept_keystrokes`, cờ `swallow_key`). `[sonnet]` bảng + menu dòng sau khi interface đã chốt.

## 4. Code

`SuspendHotkeys` gửi lại định kỳ như `launcher/mod.rs::suspend_hotkeys`; đóng Settings giữa lúc ghi ⇒ `ResumeHotkeys`. UI chết ⇒ daemon tự đăng ký lại (đã có).

## 5. Đo

Mở trang dưới 30 ms sau khi cửa sổ đã có (đọc từ log); danh sách ít dòng nên không cần ảo hoá.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh; toàn bộ test launcher / gd1_07 cũ vẫn xanh.
- [ ] Qua `fake_daemon`, phím đưa bằng `FASTCAST_SETTINGS_KEYS`: gán mới, lấy phím của lệnh khác, `taken <tổ hợp>` ⇒ báo + Quay lại, khôi phục từ lịch sử, về mặc định, gỡ. Log `fake_daemon` thấy đúng SUSPEND / RESUME / RELOAD.
- [ ] Không bao giờ để daemon ở trạng thái tạm gỡ khi đóng cửa sổ, kể cả đóng lúc đang ghi.
- [ ] `settings-run.ps1 -Page hotkeys` chụp sáng / tối, vi / en. Chỉ màn DELL.
- [ ] `[owner-qa]` Gán thật với `fst` thật: bước C7 của `plan/gd1_07_hotkey-assign.md`, làm từ Settings.

## 7. Ghi chú UI

```
[ô lọc]                               [về mặc định tất cả]
icon  Chụp vùng      [Ctrl] [Shift] [1]     Đổi   ⋯
icon  Thước căn      chưa gán               Đổi   ⋯
icon  Lấy màu        [Ctrl] [Shift] [3] ! không đăng ký được
```

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
