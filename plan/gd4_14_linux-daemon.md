# gd4_14 — Ubuntu: daemon `fst`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 GNOME Wayland (máy công ty). Máy nhà không biên dịch chéo được: `wayland-sys` đòi sysroot `pkg-config` |
| Repo | fastcast |
| Cỡ | M — ~500 dòng |
| Phụ thuộc | gd4_01, gd0_07 |
| Quyết định áp dụng | D-2, D-3, F-4, F-5 |
| Phụ thuộc mới | Theo báo cáo gd0_07: `ashpd` (MIT), `ksni`; soát `cargo deny`, đo RAM. `libappindicator` là LGPL: chỉ dùng khi chủ dự án đồng ý |
| File đụng tới | SỬA `crates/daemon/src/platform/linux.rs`, `crates/daemon/src/hotkeys.rs` (nhánh `cfg`), `crates/daemon/src/tray.rs` (nhánh `cfg`), `crates/daemon/src/clipboard.rs` (nhánh `cfg`), `crates/daemon/Cargo.toml` |

## 1. Làm gì

- Vòng sự kiện theo kết luận gd0_07.
- Phím tắt qua portal `GlobalShortcuts`: báo được khi không đăng ký nổi; đổi phím theo cách portal cho phép.
- Khay `ksni`, không có khay ⇒ daemon vẫn chạy, mở launcher bằng phím.
- `arboard` bật `wayland-data-control` (nợ gd1_05).
- Kiểm `.desktop` autostart, `X-GNOME-Autostart-Delay` + khởi động lại máy (nợ T3).

## 2. Không làm trong task này

UI, chụp (gd4_15). Làm cho X11.

## 5. Đo

`RssAnon` lúc nghỉ ≤ 5 MB.

## 6. Nghiệm thu

- [ ] Trên Ubuntu: bốn lệnh soát xanh; `fst` chạy, khay, phím, `fst status`, `fst quit`, clipboard Wayland, autostart + khởi động lại.
- [ ] Bốn lệnh trên Windows vẫn xanh trước khi gộp.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
