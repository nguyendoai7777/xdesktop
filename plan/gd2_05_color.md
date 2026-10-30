# gd2_05 — chọn màu cho mọi công cụ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~250 dòng |
| Phụ thuộc | gd2_04, materiant-gd2_01 |
| Quyết định áp dụng | D-9, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/annotate/{options,model}.rs`, `overlay/{mod,view,toolbar}.rs`, `crates/core/src/config.rs`, `i18n/{vi,en}.toml` |


## 0. Bàn giao từ gd2_04 (30/10/2026)

<!-- handoff: gd2_04 -->

- **Đã có sẵn để dùng**: `OverlaySession::change_font`, `relayout_text`; `Ink.style` (`InkStyle { color, width, font: TextFont }`) là kiểu hiện tại, ô đang soạn đọc `style` lúc vẽ nên đổi màu áp ngay; `options::Labels`.
- **Bẫy đã gặp**: khi có ô soạn, `on_key` để phím thường rơi tới input handler. Ô hex của bảng màu có focus riêng, phải kiểm phím tắt công cụ không chạy. `Shape::Text` lưu màu lúc chốt, `TextEditing` thì chưa có màu.

## 1. Làm gì

- Nút màu trên bảng tuỳ chọn mở `materiant::color_picker`, đổi màu áp cho nét sau, cho cả ô chữ đang soạn. Phím `c` mở / đóng.
- Hàng màu mẫu; nhớ màu + độ dày + cỡ chữ gần nhất (`config.annotate`, có `#[serde(default)]`, ghi lúc đóng overlay).
- Gõ hex trong bảng không kích hoạt phím tắt công cụ.

## 2. Không làm trong task này

Lấy màu từ ảnh đóng băng ngay trong bảng.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Đổi màu xong vẽ ra đúng màu, ảnh xuất đúng mã màu.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
