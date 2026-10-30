# gd4_18 — nghiệm thu GĐ4

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~100 dòng test + báo cáo |
| Phụ thuộc | gd4_02 → gd4_09 (phần Windows); gd4_10 → gd4_17 (phần macOS, Ubuntu, báo cáo ghi rõ phần chưa chạy) |
| Quyết định áp dụng | D-2, D-9, F-4 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `docs/gd4-report.md`; SỬA `crates/ui/tests/measure.rs`, `CLAUDE.md`, `ROADMAP.md` |

## 1. Làm gì

- Số đo lúc không làn nào chạy: RAM cửa sổ Settings, UI giữ ấm sau khi đóng Settings ≥ 10 s, khung đầu, cỡ exe, cỡ `setup.exe`.
- RAM daemon thật: danh sách kiểm tay, vì máy nhà không tự bật `fst` thật khi chạy thử.
- `docs/gd4-report.md`: bảng theo từng OS: đạt / chưa chạy; **một** danh sách kiểm tay theo thứ tự chạy, gom `[owner-qa]` của gd4_02 → gd4_17, kèm mục tay còn treo của GĐ1, GĐ2, GĐ3.
- Soát nợ: nhãn thước với cỡ chữ lớn (`gd1_08` mục 10), các gạch backlog đã làm xong thì xoá.
- `ROADMAP.md`: mục "Bàn giao GĐ4", đóng câu hỏi mở về công cụ bản cài. `docs/decisions.md` chỉ ghi điều chủ dự án đã chốt.

## 2. Không làm trong task này

Tự ghi đạt cho phần macOS, Ubuntu chưa chạy. `close-phase`: chờ chủ dự án kiểm tay.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh trên `master`; `cargo check --locked --target aarch64-apple-darwin -p fastcast-daemon -p fastcast-video -p fastcast-capture -p fastcast-ocr` xanh.
- [ ] Bảng số có cách đo; thử Settings chỉ ở màn DELL.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
