# gd1_09 — Lấy màu (HEX / RGB / RGBA / OKLCH)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | gd1_02 · gd1_05 (chép chữ) |
| Quyết định áp dụng | F-1, F-3 |
| Phụ thuộc mới | — (đổi màu tự viết, không thêm crate) |
| File đụng tới | `crates/core/src/color.rs` MỚI · `crates/core/src/lib.rs` SỬA · `crates/ui/src/overlay/picker.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA · `crates/ui/src/commands.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- `color_picker` ⇒ đóng băng + overlay chế độ `Picker`: kính lúp theo con trỏ (11 × 11 pixel vật lý phóng ×10, ô giữa
  có viền), dưới kính lúp là mã màu theo định dạng đang chọn.
- Nhấn chuột / Enter ⇒ chép mã theo `color.lastFormat` qua daemon, toast "Đã chép #1E90FF", đóng overlay.
- Tab / 1–4 đổi định dạng: `hex` (`#1E90FF`), `rgb` (`rgb(30 144 255)`), `rgba` (`rgba(30, 144, 255, 1)`), `oklch`
  (`oklch(0.652 0.172 253.7)`) — nhớ vào `color.lastFormat` (F-1: "nhớ lựa chọn gần nhất").
- Mũi tên dời con trỏ 1 px vật lý để nhắm chính xác.
- `color.rs` (core): sRGB → OKLab → OKLCH + định dạng chuỗi — hàm thuần, test với giá trị chuẩn.

## 2. Không làm trong task này

- Bảng màu đã lấy, lấy màu trung bình vùng.

## 3. Kiểu dữ liệu · IPC · cấu hình

`color.lastFormat` đã có (`ColorFormat::{Hex, Rgb, Rgba, Oklch}`). Màu đọc từ `Frozen::pixel(Point)`.

## 4. Code

`[opus]`: `color.rs` (công thức OKLab của Björn Ottosson, làm tròn: L 3 chữ số, C 3, H 1; xám ⇒ H = 0). Chuỗi `rgb`
theo cú pháp CSS Color 4 có khoảng trắng — xác nhận với chủ dự án nếu muốn dạng có dấu phẩy.

## 6. Nghiệm thu

- Test đơn vị: trắng `oklch(1 0 0)`, đen `oklch(0 0 0)`, `#ff0000` ⇒ `oklch(0.628 0.258 29.2)`, `#1e90ff` khớp bảng
  tham chiếu (sai ≤ 0,001).
- Định dạng đổi lần trước được giữ sau khi khởi động lại.
- Màu lấy ở màn scale 150 % là đúng pixel vật lý dưới con trỏ (so ảnh đóng băng).

## 7. Ghi chú UI

```
 ┌───────────┐
 │  ▦▦▦▦▦▦▦  │  kính lúp 110 × 110 logic, lưới mảnh, ô giữa viền trắng + đen
 │  ▦▦▦■▦▦▦  │
 └───────────┘
  ■ #1E90FF   HEX · RGB · RGBA · OKLCH   (Tab)
```

Khoá i18n: `picker.hint`, `picker.copied`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
