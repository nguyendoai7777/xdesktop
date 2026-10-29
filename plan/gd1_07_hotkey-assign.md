# gd1_07 — Gán phím tắt từ launcher (Ctrl+K)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd1_06 · materiant-gd1 T7 (`Menu`, `Dialog`) |
| Quyết định áp dụng | F-2, F-4 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/launcher/actions.rs` MỚI · `crates/ui/src/launcher/recorder.rs` MỚI · `crates/core/src/ipc.rs` SỬA · `crates/daemon/src/daemon.rs` SỬA · `crates/daemon/src/hotkeys.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- Chọn lệnh trong launcher, Ctrl+K ⇒ menu: Gán phím tắt · Gỡ phím · Lịch sử… · Về mặc định.
- **Gán**: chế độ ghi phím — bấm tổ hợp mới, Enter xác nhận, Esc huỷ. Trong lúc ghi, daemon **tạm gỡ mọi phím tắt**
  (không thì tổ hợp đang gán cho lệnh khác bị OS nuốt), xong thì đăng ký lại.
- Kiểm trước khi ghi: tổ hợp không hợp lệ (`HotkeyParseError`), trùng lệnh khác (`Hotkeys::set` → `Conflict` ⇒ hỏi
  "Lấy phím của <lệnh>?" ⇒ `set_force`), hệ thống hay giữ (`hotkey::system_reserved` ⇒ cảnh báo, vẫn cho gán).
- Ghi `config.json` (đọc lại ngay trước khi ghi) ⇒ `ReloadConfig` ⇒ hỏi lại `StatusRequest`: OS từ chối tổ hợp ⇒ báo
  "app khác đang giữ" + nút Quay lại (`Hotkeys::rollback`).
- **Lịch sử…**: danh sách tổ hợp cũ (mới nhất trước, thời điểm thay) ⇒ chọn ⇒ `Hotkeys::restore`.
- **Về mặc định**: `Hotkeys::reset`.

## 2. Không làm trong task này

- Trang Settings → Phím tắt (GĐ4) — dùng lại `actions.rs` / `recorder.rs`.

## 3. Kiểu dữ liệu · IPC · cấu hình

```rust
Message::SuspendHotkeys   // UI → daemon: gỡ đăng ký tạm; tự đăng ký lại sau 30 s nếu không có Resume
Message::ResumeHotkeys    // UI → daemon
```

`hotkeys.bindings` / `hotkeys.history` đã có (core GĐ0 T1).

## 4. Code

`[opus]`: Suspend / Resume ở daemon (hẹn giờ tự khôi phục khi UI chết giữa chừng), luồng ghi → kiểm → reload → soát
trạng thái. `recorder.rs`: đổi `KeyDownEvent` của GPUI → `fastcast_core::hotkey::Hotkey` (hàm thuần, test).

## 5. Đo

—

## 6. Nghiệm thu

- Gán Ctrl+Shift+2 (đang của Thước căn) cho Chụp vùng ⇒ hỏi lấy phím ⇒ đồng ý ⇒ Thước căn còn trống, lịch sử của cả
  hai có dòng mới; Quay lại khôi phục được.
- Tổ hợp app khác đang giữ (giả lập như GĐ0 T2) ⇒ báo lỗi, quay lại được.
- UI bị giết khi đang ghi phím ⇒ ≤ 30 s sau phím tắt chạy lại.
- Test đơn vị `recorder` (phím bổ trợ đứng một mình không phải tổ hợp, F13, PrintScreen).

## 7. Ghi chú UI

Khoá i18n: `hotkey_action.assign`, `hotkey_action.remove`, `hotkey_action.history`, `hotkey_action.reset`,
`hotkey.recording`, `hotkey.take_over` (+ `hotkey.conflict_app`, `hotkey.conflict_system`, `hotkey.register_failed` đã có).

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
