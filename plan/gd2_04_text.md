# gd2_04 — chữ tại đúng điểm click

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | M — ~850 dòng |
| Phụ thuộc | gd2_02 |
| Quyết định áp dụng | D-2, D-9, F-3, F-11 |
| Phụ thuộc mới | `fontdb` 0.23 (MIT), `ttf-parser` 0.25 (MIT / Apache-2.0), đều đã có trong cây qua usvg của GPUI |
| File đụng tới | MỚI `overlay/annotate/{text_edit,text_export}.rs`; SỬA `overlay/annotate/{model,paint,export,options}.rs`, `overlay/{mod,view,toolbar,dev}.rs`, `i18n/{vi,en}.toml` |


## 0. Bàn giao từ gd2_03 (30/10/2026)

<!-- handoff: gd2_03 -->

- **Bẫy đã gặp**: nhấn ngoài cửa sổ thu nhỏ của `=1080p` không trúng hitbox nên không vẽ; đo CPU dùng `=1080p-offscreen`.

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

Gộp `master` ở `f722b85`.

- Có: công cụ `text` (phím `t`), `annotate/text_edit.rs` (ô soạn thuần, có test), `annotate/text.rs` (bố cục + vẽ), `annotate/text_export.rs` (ảnh xuất), nút B / I / U + cỡ chữ trên bảng tuỳ chọn, icon `bold italic underline plus minus`.
- Thêm ngoài spec: bước `text <màn> <chữ>` ở `dev.rs`; `FASTCAST_OVERLAY_FAKE` giá trị lạ giờ rơi về màn giả nhỏ thay vì chụp màn thật (xem dưới).
- Phụ thuộc thêm so với bảng: `unicode-segmentation` (MIT / Apache-2.0, đã có trong cây).
- Kiểm: unit `text_edit`, `model`, `text_export`; `fake_ink_text_*`; ảnh màn giả scale 1: chữ Việt có dấu, B / I / U, xuống dòng ở mép vùng, click dời con trỏ, nền chọn, ảnh lưu khớp vị trí trên màn.
- **Chưa kiểm**: màn scale khác 1 trên màn thật (màn giả luôn theo scale màn chính của máy, ở đây 1), IME thật.
- **Sự cố lúc chạy thử (30/10/2026)**: truyền `FASTCAST_OVERLAY_FAKE=1.5` (giá trị không hợp lệ) ⇒ hai lần mở overlay thật, chụp + phủ hai màn thật vài giây, giành foreground; ảnh xoá chưa xem. Một lần khác lưu nhầm ảnh giả vào `OneDrive/Pictures`, đã dời đi. Đã vá `fake_mode`; script thử giờ bắt buộc thư mục lưu riêng.

## 10. Đề xuất cải tiến
