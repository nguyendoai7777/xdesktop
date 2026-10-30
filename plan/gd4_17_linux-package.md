# gd4_17 — Ubuntu: gói `.deb`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 |
| Repo | fastcast |
| Cỡ | S — ~150 dòng script |
| Phụ thuộc | gd4_06, gd4_07, gd4_14, gd4_15, gd4_16 |
| Quyết định áp dụng | D-2, F-5 |
| Phụ thuộc mới | — (`dpkg-deb` có sẵn) |
| File đụng tới | MỚI `installer/linux/{control,fastcast.desktop,postrm}`, `tools/build-deb.sh` |

## 0. Bàn giao từ gd4_07 (30/10/2026)

<!-- handoff: gd4_07 -->

- **Đã có sẵn để dùng**: `assets/icon/app-icon.png` (512) cho `/usr/share/icons/hicolor/512x512/apps/`. Cần cỡ khác thì thêm vào `tools/export-icon/src/main.rs`, chạy `pwsh tools/export-icon.ps1`.
- **Soát lại khi làm**: `Icon=` trong `.desktop` khớp tên tệp, GNOME hiện đúng icon. Chi tiết: `plan/gd4_07_app-icon.md` mục 9.

## 1. Làm gì

- `.deb` cho Ubuntu 26.04: exe vào `/opt/fastcast`, `fst` nối vào `/usr/bin`, model, giấy phép, icon, `.desktop`. Khai `Depends` đúng thứ cần lúc chạy.
- Gỡ: tắt daemon, xoá autostart của người dùng lúc chạy kế, giữ cấu hình.

## 2. Không làm trong task này

AppImage, Flatpak (sandbox portal khác), repo apt.

## 6. Nghiệm thu

- [ ] `apt install ./fastcast_*.deb` trên máy sạch: chạy đủ tính năng, trang giấy phép mở được; `apt remove` sạch.
- [ ] `lintian` không có lỗi nghiêm trọng.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
