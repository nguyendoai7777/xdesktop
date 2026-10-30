# gd2_04 — chữ tại đúng điểm click

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~850 dòng |
| Phụ thuộc | gd2_02 |
| Quyết định áp dụng | D-2, D-9, F-3, F-11 |
| Phụ thuộc mới | `fontdb` 0.23 (MIT), `ttf-parser` 0.25 (MIT / Apache-2.0), đều đã có trong cây qua usvg của GPUI |
| File đụng tới | MỚI `overlay/annotate/{text_edit,text_export}.rs`; SỬA `overlay/annotate/{model,paint,export,options}.rs`, `overlay/{mod,view,toolbar,dev}.rs`, `i18n/{vi,en}.toml` |

## 1. Làm gì

- Công cụ `text` (phím `t`): click đâu, con trỏ chữ nằm đúng đó (không lưới), gõ ngay. Enter xuống dòng; Ctrl+Enter, Esc hoặc click nơi khác thì chốt; xuống dòng tự động ở mép phải vùng chọn.
- Đậm / nghiêng / gạch chân (Ctrl+B / I / U + nút), tăng / giảm cỡ (Ctrl+= / Ctrl+− + nút).
- Ô soạn tự viết (`EntityInputHandler`): IME, dán, chọn chữ, undo trong ô. Soạn và lúc đã chốt vẽ cùng một mã ⇒ chữ không nhảy.
- Ảnh xuất có chữ đúng chỗ: bố cục glyph lấy từ GPUI, hình glyph lấy từ tệp font hệ thống (`fontdb` + `ttf-parser`), nạp ở luồng nền chỉ khi có chữ, nhả ngay.

## 2. Không làm trong task này

Sửa chữ đã chốt, nền chữ, chữ nhiều kiểu trong một ô.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

`[owner-qa]`: gõ Telex / VNI qua Unikey / EVKey vào ô chữ, không mất / nhân đôi chữ; ô ứng viên IME đúng chỗ.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
