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
