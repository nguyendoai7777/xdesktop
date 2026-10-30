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

## 0. Bàn giao từ gd3_06 (30/10/2026)

<!-- handoff: gd3_06 -->

- **Đã có sẵn để dùng**: `fastcast-rec` thật. Chạy thử không quay màn: `source_probe --serve --size 1280x720` in `hwnd=<số>`, đặt `FASTCAST_REC_WINDOW=<số>`. Mẫu đo một lượt 60 s: `plan/gd3_06_rec-worker.md` mục 5 (3,9 %, 26,7 MB, 0 ô rớt, máy bận 61 %) ⇒ lấy số chính thức ở đây, lúc không làn nào chạy.
- **Nợ chuyển sang đây** (`[owner-qa]`, C15): vùng thật trên một màn, vắt hai màn khác DPI, tiếng khớp hình bằng tai. Đường theo màn chưa chạy lần nào.
- **Nợ chuyển sang đây** (`[ux]`, P2): `DisplayChanged`, `CaptureLost` giữa chừng ⇒ worker vẫn chốt tệp đích rồi `Failed`, nhưng UI chỉ báo lỗi, không nói video còn. Soát `record/mod.rs` của gd3_11 khi đã gộp; `fake_rec --fail-after` hiện xoá `.part` nên không tái hiện được ca này.
- **Nợ chuyển sang đây** (`[bảo mật]`, P3): rec bị giết cứng để lại `.mp4.part` không phát được. Dọn ở UI khi bắt đầu quay, trong `save.videoDir`.
- **Đối chiếu**: gạch backlog `[gd3_04 → gd3_13]` ghi RAM quay 44–53 MB qua `Encoder`; lượt 60 s của `fastcast-rec` đọc 26,7 MB ở cùng cách đo (`WorkingSetPrivate`). Đo lại rồi xoá gạch đó nếu vẫn dưới 35 MB.
- **Bẫy đã gặp**: `Finished.secs` là số giây tròn xuống (60,9 s báo 60). Chạy `cargo test -p fastcast-video`, không `--test session` một mình: thiếu `source_probe`.
- **Soát lại khi làm**: bật UI thật với `FASTCAST_REC_EXE` bỏ trống, `FASTCAST_REC_WINDOW` đặt sẵn, `FASTCAST_OVERLAY_FAKE=1` ⇒ chuỗi UI ↔ worker thật chưa ai chạy (gd3_11 chỉ thử bằng `fake_rec`).

## 0. Bàn giao từ gd3_07 (30/10/2026)

<!-- handoff: gd3_07 -->

- **Đã có sẵn để dùng**: `audio_probe [--source system|mic] [--secs N] [--tone HZ] <tệp>`, rồi `mp4_verify <tệp>`. `--tone` tự phát sóng −46 dB từ giây 0,5 tới 1,5 nên máy im vẫn có gói; tệp chứa âm thật của máy ⇒ xem xong xoá.
- **Nợ chuyển sang đây** (`[owner-qa]`, cho vào danh sách kiểm tay, `plan/gd3_07_rec-audio.md` C6): micro + âm hệ thống 60 s cùng video, tiếng khớp hình; rút tai nghe giữa chừng không treo; đổi thiết bị mặc định giữa chừng thì tiếng theo sang; micro bị tắt trong Privacy ⇒ `AudioUnavailable` hoặc im lặng (ghi lại ca nào). Máy khác 48 kHz (44,1 kHz) nên có trong lượt kiểm: nhánh đổi tần số mới phủ bằng unit test.
- **Bẫy đã gặp**: không mở micro trên máy chủ dự án khi tự chạy; loopback chỉ 2 s. Máy im thì `packets=0` là đúng, không phải lỗi, đừng đọc nhầm thành hỏng.
- **Soát lại khi làm**: mốc `pts` 0 của `audio::start` là lúc gọi hàm, `session.rs` trừ khoảng tới khung đầu; `audio_probe --tone` cho `first_pts_ms` sau `tone_start_ms` 5–7 ms, nhưng chuỗi `fastcast-rec` có âm chưa chạy thật. `audio_hz` của `mp4_verify` tính trên cả track, có khoảng lặng thì ra thấp hơn tần số thật.

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
