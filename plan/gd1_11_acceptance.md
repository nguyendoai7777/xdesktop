# gd1_11 — Nghiệm thu GĐ1 (Windows)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — đo + báo cáo, sửa lỗi nhỏ phát hiện được |
| Phụ thuộc | gd1_01 → gd1_10 |
| Quyết định áp dụng | F-1 → F-5, F-8, D-3 |
| Phụ thuộc mới | — |
| File đụng tới | `fastcast/docs/gd1-report.md` MỚI · `fastcast/ROADMAP.md` SỬA (mục bàn giao GĐ1) |

## 1. Làm gì

- Chạy lại toàn bộ luồng GĐ1 trên bản release, máy nhà Windows 2 màn (DELL 60 Hz + LG 144 Hz), thêm một lượt đặt một
  màn scale 125 % hoặc 150 %.
- Bảng số đo: RAM daemon nghỉ, RAM UI giữ ấm không cửa sổ, RAM UI khi overlay mở / launcher mở; độ trễ phím tắt →
  overlay và Alt+Space → launcher (nguội / ấm); CPU khi kéo (GPU thật / WARP).
- Danh sách kiểm tay cho chủ dự án (`[owner-qa]`) gom từ mục 6 các task GĐ1, kèm bước làm.
- Kiểm `fst autostart on` + khởi động lại máy (GĐ0 T3 còn treo) cùng lượt này.

## 2. Không làm trong task này

- macOS / Ubuntu (GĐ4, sau gd0_07).

## 5. Đo

Như mục 1 — so với spike (`materiant/docs/spikes/ui-foundation.md` mục 2) và với GĐ0 (daemon 1,1 MB).

## 6. Nghiệm thu

- Báo cáo `fastcast/docs/gd1-report.md`: bảng số đo, kết quả kiểm tay, lỗi còn lại (đã ghi `plan/_backlog.md`).
- Không lỗi chặn nào ở luồng chụp → lưu / chép trên 2 màn khác Hz và khác scale.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
