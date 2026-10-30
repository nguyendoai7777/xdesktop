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

## 0. Bàn giao từ gd3_12 (30/10/2026)

<!-- handoff: gd3_12 -->

- **Đã có sẵn để dùng**: `record::finish::show`; `FASTCAST_RECORD_FINISH_KEYS="tab enter wait@300 ctrl-s"` đưa phím vào bảng (chỉ cùng `FASTCAST_OVERLAY_FAKE`, chi tiết `plan/gd3_12_record-save.md` mục 9).
- **Nợ chuyển sang đây** (`[owner-qa]`, cho vào danh sách kiểm tay): hộp thoại Lưu thành… nổi đúng trên bảng; popup thật ở đáy màn có con trỏ, thông báo lỗi nằm ngay dưới bảng, không đè; chép video lớn sang ổ khác, ổ mạng; Tab / Enter trên từng nút.
- **Bẫy đã gặp**: lúc nhiều làn build, `tests/overlay.rs` đỏ hàng loạt ở `wait_exit` 5 s (`common/mod.rs:115`) dù `ui stopped` đã ghi. Đây là tiến trình thoát chậm khi máy bận, không phải lỗi logic: chạy lại riêng thì 32/32 xanh. Lượt này máy rảnh thì không nên gặp; còn đỏ thì mới là lỗi thật.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test record_save`.

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Soát lại khi làm**: `cargo tree -p fastcast-daemon` không đổi ở gd3_01 (đã so `master`), không đo lại RAM daemon vì hợp đồng. Trên `master` hậu GĐ3: `cargo tree -p fastcast-ui` vẫn không có `fastcast-video`, `fastcast-ocr`. Nhánh OS khác chưa biên dịch thử (máy thiếu target): soát ở GĐ4.

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
