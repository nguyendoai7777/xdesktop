# gd2_03 — vẽ tự do

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~200 dòng |
| Phụ thuộc | gd2_02 |
| Quyết định áp dụng | D-9, F-11 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/annotate/{model,shape,export,paint}.rs`, `overlay/toolbar.rs`, `tests/overlay.rs` |

## 1. Làm gì

- Công cụ `pen` (phím `p`). Bỏ điểm sát nhau, nối cong qua trung điểm cho mượt.
- Nét dài không làm khung vẽ chậm dần: tessellate theo đoạn, cache đoạn đã xong (kiểm bằng số đo).
- RAM + CPU khi vẽ nét dài trong `tests/overlay.rs` / `tests/measure.rs`.

## 2. Không làm trong task này

Nét theo áp lực bút, làm mịn theo thời gian.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Nét 5 000 điểm vẫn vẽ được; ảnh xuất khớp màn.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
