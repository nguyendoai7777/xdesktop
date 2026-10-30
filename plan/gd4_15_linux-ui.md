# gd4_15 — Ubuntu: UI, overlay, chụp màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 GNOME Wayland |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd4_01, gd0_07 |
| Quyết định áp dụng | D-3, F-3, F-4 |
| Phụ thuộc mới | `ashpd` (MIT) nếu gd0_07 chọn portal |
| File đụng tới | SỬA `crates/ui/src/platform/linux.rs`, `crates/capture/src/lib.rs` (nhánh `cfg`), `crates/capture/Cargo.toml`, `crates/ui/Cargo.toml`; MỚI `crates/capture/src/portal.rs` |

## 1. Làm gì

- Đóng băng từng màn qua portal theo kết luận gd0_07 (hỏi quyền, `restore_token`, hình học output); thiếu thì ghi rõ thứ phải đổi ở F-3 vào `confirm.md`.
- Overlay toàn màn từng output trên GNOME không có layer-shell: phủ thanh trên, không nhảy focus.
- `platform/linux.rs`: `hide` / `show`, `cursor_display` (Wayland không cho đọc con trỏ toàn cục ⇒ dùng màn đang focus), `set_cursor_pos` (Wayland không cho ⇒ mũi tên chỉ dời điểm nhắm), `exclude_from_capture` no-op.
- Soát font `Noto Sans` (nợ gd2_04), IBus / Fcitx gõ tiếng Việt, hộp thoại lưu, chép ảnh.

## 2. Không làm trong task này

Quay (gd4_16). Sửa nhánh Windows.

## 5. Đo

Overlay 2 màn, khung đầu, thời gian chụp qua portal so với 57 ms của Windows.

## 6. Nghiệm thu

- [ ] Trên Ubuntu: bốn lệnh xanh; danh sách kiểm tay `docs/gd1-report.md` mục 4 + `docs/gd2-report.md` mục 4, hai màn khác scale.
- [ ] Bốn lệnh trên Windows vẫn xanh trước khi gộp.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
