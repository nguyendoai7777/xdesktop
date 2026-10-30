# gd2_03 — vẽ tự do

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | S — ~200 dòng |
| Phụ thuộc | gd2_02 |
| Quyết định áp dụng | D-9, F-11 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `overlay/annotate/{model,shape,export,paint}.rs`, `overlay/toolbar.rs`, `tests/overlay.rs` |


## 0. Bàn giao từ gd2_02 (30/10/2026)

<!-- handoff: gd2_02 -->

- **Đã có sẵn để dùng**: `InkStyle`, `Pen`, `PathCache` theo màn; `Shape::drag_to` trả phần đổi để chỉ đánh dấu màn bị đụng.
- **Soát lại khi làm**: `fake_ink_stroke_on_one_monitor_does_not_repaint_the_other`.

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

Gộp `master` ở `c47a367`.

- Có: `Shape::Freehand`, tessellate theo khúc 128 đoạn (khúc đủ không đổi nữa ⇒ giữ cache), bỏ điểm cách nhau dưới 2 px, click tại chỗ ra chấm.
- Đo màn giả `1080p-offscreen`, GPU, `measure_freehand_long_stroke` (bỏ qua mặc định): 150 lần di mỗi quãng, 0,03–0,10 nhân, không chậm dần; RAM +~1 MB mỗi 150 điểm (47 → 57 MB ở 1 500 điểm), sau nét 39 MB.

## 10. Đề xuất cải tiến
