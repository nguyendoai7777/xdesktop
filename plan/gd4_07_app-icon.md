# gd4_07 — icon app cho exe + khay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~150 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-10, D-2 |
| Phụ thuộc mới | `build-dependency`: `embed-resource` (MIT, chỉ lúc build); soát `cargo deny`. Icon khay giải mã bằng `resvg` hay PNG sẵn: chọn cách không thêm crate vào daemon lúc chạy |
| File đụng tới | MỚI `assets/icon/app-icon.{ico,icns,png}`, `tools/export-icon.ps1`, `crates/daemon/build.rs`, `crates/ui/build.rs`, `crates/daemon/res/app.rc`, `crates/ui/res/app.rc`; SỬA `crates/daemon/src/tray.rs`, `crates/daemon/Cargo.toml`, `crates/ui/Cargo.toml`, `Cargo.lock` |

## 1. Làm gì

- Xuất từ `design/fastcast-icon/app-icon.svg` (F-10): `.ico` 16–256, `.icns`, PNG 512. Tệp sinh ra commit vào repo, script chỉ chạy lại khi đổi icon.
- Nhúng vào `fst.exe`, `fastcast-ui.exe` qua resource Windows. Hai worker chạy ẩn, không cần.
- Icon khay: đọc từ resource / RGBA nhúng cỡ 16, 20, 24, 32 theo DPI, thay icon tạm hiện tại.

## 2. Không làm trong task này

Bản cài (gd4_09). Icon `.app` (gd4_13), `.desktop` (gd4_17).

## 5. Đo

Icon khay nằm trong daemon: RAM phải giữ ≤ 5 MB. Máy nhà không chạy `fst` thật khi thử ⇒ đo ở gd4_18; ở làn này đo cỡ `fst.exe` trước / sau, tăng không quá 150 KB.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh, `cargo deny` xanh, exe có resource icon (đọc bằng `ExtractIconEx` trong test, không mở cửa sổ).
- [ ] Test `Icon::from_rgba` nhận đúng từng cỡ.
- [ ] Không bật khay trên máy nhà trong làn này (icon khay nằm ở taskbar màn LG).
- [ ] `[owner-qa]` Khay + Explorer + Alt+Tab hiện đúng icon ở 100 %, 125 %, 150 %.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
