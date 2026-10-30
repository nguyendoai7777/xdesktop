# gd4_02 — Settings: Chung (ngôn ngữ, giao diện, cỡ chữ, tự khởi động)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-2, F-5, D-4, D-9 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_general.rs`, `crates/ui/src/app.rs` (`apply_general`); MỚI `crates/ui/tests/settings_general.rs` |

## 1. Làm gì

- Ngôn ngữ (`Select`), giao diện sáng / tối / hệ thống (`RadioGroup`), preset màu (`Select`), dòng khoá `CustomTheme`.
- Cỡ chữ 12–20 (`NumberField`), áp ngay; `app.rs` đang kẹp 10–32 cho file sửa tay, giữ nguyên.
- Tự khởi động: `Switch` + trễ 0–120 giây; daemon áp qua `ReloadConfig`. Đọc trạng thái thật qua `StatusRequest` nếu đã có trường, không thì theo config.
- Đổi là có tác dụng ngay ở mọi cửa sổ đang mở, không có nút Lưu. `apply_general` áp thêm `themePreset`; đổi preset về `Default` phải trả được màu (`reset_theme` rồi áp lại).
- Ngôn ngữ đổi ⇒ chữ trong Settings đổi ngay; tên lệnh ở launcher đọc lại lúc mở (đã có).

## 2. Không làm trong task này

Theme tuỳ biến thật (chỉ dòng khoá). Nhãn thước theo cỡ chữ lớn (`gd1_08` mục 10): soát ở gd4_18.

## 5. Đo

Đổi cỡ chữ 14 ⇒ 20: một lần vẽ lại dưới 50 ms từ log; không tăng RAM sau 10 lần đổi.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh.
- [ ] Mỗi điều khiển ghi đúng khoá vào `FASTCAST_CONFIG_FILE`, không đụng khoá khác (test).
- [ ] Ghi hỏng (tệp chỉ đọc) ⇒ toast `settings.save_failed`, điều khiển trả về giá trị cũ.
- [ ] `settings-run.ps1 -Page general` chụp vi / en × sáng / tối × cỡ 12 / 20: không tràn, không cắt chữ. Chỉ màn DELL.
- [ ] `[owner-qa]` Bật tự khởi động, khởi động lại máy: daemon lên sau đúng độ trễ.

## 7. Ghi chú UI

Dùng hết bằng bàn phím: Tab qua từng điều khiển, Space / Enter đổi. Khoá i18n có sẵn từ gd4_01.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
