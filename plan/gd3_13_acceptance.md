# gd3_13 — nghiệm thu GĐ3

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~150 dòng test |
| Phụ thuộc | gd3_01 → gd3_12 |
| Quyết định áp dụng | D-9, F-4, F-6, F-7, F-8 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `docs/gd3-report.md`; SỬA `tests/measure.rs`, `CLAUDE.md`, `ROADMAP.md` |

## 1. Làm gì

- **Chạy một mình, máy rảnh**: mọi số đo độ trễ / CPU của lượt này, không làn nào build song song.
- Nối đủ exe thật trên màn giả: OCR engine thật đọc ảnh hoạ tiết; `fastcast-rec` thật quay cửa sổ thử.
- Đo: RAM UI trước / trong / sau OCR và quay; RAM + thời gian của `fastcast-ocr`, `fastcast-rec`; sau khi xong hai tiến trình đã thoát; daemon vẫn 1,1 MB.
- Gom mọi gạch `[owner-qa]` GĐ3 + C8–C11 của gd0_06 thành một danh sách theo thứ tự chạy, có lệnh; gạch `plan/_backlog.md`.

## 2. Không làm trong task này

`close-phase`: GĐ1, GĐ2 còn chờ kiểm tay. macOS / Ubuntu (GĐ4).

## 2b–5

Viết lúc bắt đầu task.

## 6. Nghiệm thu

Báo cáo có số đo + danh sách kiểm tay; bốn lệnh soát xanh trên `master`; không còn tệp trong `tmp/`; `tests/` không có lệnh nào chụp màn thật.

## 7. Ghi chú UI

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
