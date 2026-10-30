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

## 0. Bàn giao từ gd4_03 (30/10/2026)

<!-- handoff: gd4_03 -->

- **Đã có sẵn**: trang Phím tắt, `hotkey_dialog.rs` dùng chung launcher; log `settings: hotkeys page in <ms>` để đo.
- **Soát lại**: đổi trang sang Phím tắt ở bản release, chuẩn dưới 30 ms (`FASTCAST_SETTINGS_PAGE=general`, `-Keys "wait@500 down"`); bản debug đo được 35,3 ms, chưa có số release.
- **Kiểm tay**: C9 của `gd4_03`, gán thật với `fst` thật, gạch ở `_backlog.md`.

## 0. Bàn giao từ gd4_04 (30/10/2026)

<!-- handoff: gd4_04 -->

- **Đã có sẵn**: trang Lưu và quay; `clipboard.excludeFromHistory` chặn cả Win+V lẫn clipboard đám mây trên Windows.
- **Nợ**: chưa có tiêu đề nhóm trên trang (thiếu khoá i18n, `gd4_04` mục 8).
- **Soát lại**: daemon đổi `clipboard.rs` không thêm phụ thuộc, tính vào lần đo RAM daemon cuối; kiểm tay Win+V ở `_backlog.md`.

## 0. Bàn giao từ gd4_02 (30/10/2026)

<!-- handoff: gd4_02 -->

- **Đã có sẵn để dùng**: log `settings: general applied in <ms>` để đo độ trễ đổi cài đặt, chạy `pwsh tools/settings-run.ps1 -Page general -Keys "wait@300 tab tab tab tab up up up up up up"`.
- **Số đo chính thức cần lấy**: trần 50 ms khi đổi cỡ chữ. Số ở `plan/gd4_02_settings-general.md` mục 9 đo trên bản debug lúc máy bận.
- **Kiểm tay thêm vào danh sách**: tắt / bật tự khởi động, khởi động lại máy, daemon lên sau đúng độ trễ; tệp cấu hình chỉ đọc ⇒ thấy toast `settings.save_failed`.
- **Soát**: sidebar Settings không theo cỡ chữ (mục 10 của gd4_02).
- **Nợ**: lỗi `autostart::apply` không tới UI, khoá `settings.autostart_failed` chưa dùng.

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
