# gd2_06 — nghiệm thu GĐ2

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ |
| Repo | fastcast |
| Cỡ | S — ~120 dòng test |
| Phụ thuộc | gd2_01 → gd2_05 |
| Quyết định áp dụng | D-9, F-3 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `docs/gd2-report.md`; SỬA `tests/{measure,overlay}.rs`, `CLAUDE.md`, `ROADMAP.md` |


## 0. Bàn giao từ gd2_05 (30/10/2026)

<!-- handoff: gd2_05 -->

- **Đã có sẵn để dùng**: `wheel`, `wheelpx`, `text` trong `FASTCAST_OVERLAY_SCRIPT`; `Sandbox::spawn(script, extra)` để không lưu vào Pictures thật.
- **Bẫy đã gặp**: `FASTCAST_OVERLAY_FAKE` chỉ nhận `1`, `1080p`, `1080p-offscreen`; màn giả theo scale màn chính, không ép được 150 %. Lúc nhiều session build, khung đầu lên tới 10 s và test báo "still running after 5s": soát với `--test-threads=4`, số đo ghi rõ tải máy.

## 1. Làm gì

- Ảnh chứng thực trên màn giả (PrintWindow, xem xong xoá): mọi công cụ, xuất ảnh đúng pixel.
- Đo RAM + CPU kéo (GPU + WARP) có chú thích, so với gd1_11; ghi vào `docs/gd2-report.md`.
- Danh sách kiểm tay `[owner-qa]` + lệnh chạy; gạch `plan/_backlog.md`.

## 2. Không làm trong task này

`close-phase`: GĐ1 còn chờ kiểm tay.

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Báo cáo có số đo, danh sách kiểm tay.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

CPU WARP lúc vẽ nét: `plan/_backlog.md`. Không có task GĐ2 nào nhận.

## 9. Bàn giao thực tế

Gộp `master` ở `747f90d`. Bài đo `measure_annotated_{stress,typical}`; báo cáo `fastcast/docs/gd2-report.md`; bàn giao GĐ2 ở `fastcast/ROADMAP.md`.

- Máy bận suốt buổi đo (tải 51–100 %), đã ghi trong báo cáo.
- GĐ2 **chưa đóng**: chờ chủ dự án kiểm tay; không chạy `close-phase`.

## 10. Đề xuất cải tiến
