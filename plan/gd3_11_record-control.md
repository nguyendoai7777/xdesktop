# gd3_11 — đang quay: khung viền, đồng hồ, dừng

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay ở gd3_13 |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd3_01 (`fake_rec`; KHÔNG cần overlay, không cần encoder) |
| Quyết định áp dụng | F-3, F-4, F-7, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/record/{mod,client,frame,controls}.rs`; MỚI `crates/ui/tests/record_control.rs` |

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `crates/ui/examples/fake_rec.rs`: `--delay-ms`, `--fail <code>`, `--fail-after <giây>`, `--die-after <giây>` (chết không chốt tệp, thoát 3), `--software`, `--skipped <n>`; ghi `.part` rồi đổi tên thật. `worker::exe_path(REC_EXE_VAR, REC_EXE)`.
- **Đã nối**: lệnh `record_region` + `FASTCAST_OVERLAY_FAKE` + `FASTCAST_RECORD_REGION=x,y,w,h` gọi `record::start` qua `record::dev_hook` (`commands::dispatch`). Stub `start` có hai dòng log: giữ dòng `record: start …` (gd3_10 test), bỏ dòng `not implemented`. Field `output` đang `allow(dead_code)`: gỡ.
- **Bẫy**: bật con cần `CREATE_NO_WINDOW`. `dev_hook` chạy thẳng trong `dispatch`, chưa bọc `with_gpu`: mở cửa sổ phải tự bọc. `RecEvent::Finished` không có đường dẫn: lấy từ `RecordStart.output`.

## 1. Làm gì

- `record/client.rs`: bật `fastcast-rec` (`FASTCAST_REC_EXE` đè), gửi `Start`, đọc `RecEvent` ở luồng nền.
- `record/frame.rs`: viền quanh vùng, mỗi màn vùng chạm một cửa sổ `PopUp` không focus, xuyên chuột. Bật `WDA_EXCLUDEFROMCAPTURE` để viền không lọt vào video (như `notice`). Đổi toạ độ bằng scale của từng màn (F-3).
- `record/controls.rs`: thanh nhỏ ngoài vùng: chấm đỏ, thời gian, nút dừng. Không đủ chỗ ngoài vùng thì đặt góc màn. Rơi về phần mềm ⇒ hiện `record.software_encoder`; ô rớt tăng ⇒ `record.dropped`.
- Dừng: nút, hoặc phím `record_region` lần nữa (`stop_if_recording`, đã nối ở `commands::dispatch`).
- Giữ ấm: cửa sổ đang mở nên không tính giờ; nhả GPU: không đổi. Mở bằng `app::with_gpu`.
- `Failed` ⇒ `notice::show` đúng chữ báo, gỡ khung. `Finished` ⇒ gỡ khung, gọi `finish::show`.
- Đổi bố cục màn lúc quay ⇒ để worker báo `DisplayChanged`.

## 2. Không làm trong task này

Bảng thiết lập (gd3_10). Bảng sau khi dừng (gd3_12). Tạm dừng quay.

## 2b. Phân vai

`[opus]` client + frame + đa màn + `controls.rs` + test (đổi so với plan, lý do ở mục 9).

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thông điệp, không khoá mới. `record::client::ClientEvent { Worker(RecEvent), Gone }`. Biến chạy thử mới, chỉ cùng màn giả: `FASTCAST_RECORD_OUTPUT`, `FASTCAST_RECORD_CLICK_STOP_MS`.

## 4. Code

- `client.rs`: bật worker, luồng đọc `RecEvent`; sau sự kiện cuối / hết stdout chờ 2 s rồi giết, không để tiến trình mồ côi.
- `frame.rs`: `Screen` (bố cục thật hoặc giả, vùng làm việc, đặt đúng pixel), `frame_pieces` (hàm thuần), `FrameView`, `sys` (xuyên chuột, `place`).
- `controls.rs`: `placement` (hàm thuần), `format_elapsed`, `ControlsView`, cú bấm giả.
- `mod.rs`: phiên duy nhất `Active`, vòng sự kiện, `request_stop` + hạn 30 s, xoá `.part` khi lỗi.

**Chạy thử** bằng `FASTCAST_RECORD_REGION=x,y,w,h` (chỉ khi `FASTCAST_OVERLAY_FAKE`) gọi `record::start` thẳng, không qua overlay.

## 5. Đo

RAM UI lúc đang quay, CPU khung viền ≈ 0 khi đứng yên. Số đo ở mục 9; số chính thức lấy ở gd3_13.

## 6. Nghiệm thu

| Case | Cho | Khi | Thì | Ai phủ |
|---|---|---|---|---|
| C1 | Vùng vắt hai màn giả | Bắt đầu quay | Hai cửa sổ khung xuyên chuột + thanh; đồng hồ chạy 00:00, 00:01, 00:02 | `[opus-unit]` hình học, `[opus-run]` `frame_and_bar_…` |
| C2 | Đang quay | Bấm nút dừng | Gửi `Stop`, tệp chốt, không còn `.part`, gỡ 3 cửa sổ, log không lộ đường dẫn | `frame_and_bar_…` |
| C3 | Đang quay | Lệnh `record_region` lặp hai lần | Dừng một lần, không mở overlay; lệnh sau mở phiên mới | `repeated_command_…` |
| C4 | Worker báo `Failed` từng mã trong 8 mã | | Log đúng mã, gỡ khung, báo lỗi; mã nào cũng có chữ | `every_failure_code_…`, `every_error_code_…` |
| C5 | Lỗi giữa chừng (`display_changed`) | | Gỡ khung; hết thông báo thì UI thoát theo giữ ấm = không cửa sổ mồ côi | `failure_midway_…` |
| C6 | Con chết ngang | | Báo lỗi, gỡ khung, xoá `.part`, không cửa sổ mồ côi | `worker_death_…` |
| C7 | Rơi về phần mềm + ô rớt tăng | | Thanh hiện đủ, số rớt tăng | `software_encoder_…` |
| C8 | Worker đang mở encoder | Dừng sớm | Vẫn chốt tệp | `stop_while_starting_…` |
| C9 | Đang quay | UI chết | Worker nhận EOF, tệp còn | `ui_exit_…` |
| C10 | Không có exe worker | Bắt đầu quay | Báo lỗi, gỡ khung, UI thoát được | `missing_worker_exe_…` |
| C11 | Thanh, vùng đủ kiểu, nhiều màn khác scale | Đặt thanh | Dưới, trên, phải, trái, màn khác, cuối cùng góc màn; không đè vùng khi còn chỗ | `[opus-unit]` `controls::tests` |
| C12 | `[owner-qa]` Trong gd3_13 | Quay thật | Viền không lọt video, vùng vắt hai màn khác DPI, thanh không che vùng, bấm được nút dừng bằng chuột thật | chờ kiểm tay |

## 7. Ghi chú UI

```
● 00:42   [dừng]
```

Nền `cx.floating_surface()`; nút dừng vẽ ô vuông, không cần icon mới. Khoá `record.*` có sẵn.

## 8. Nợ chuyển task khác

- gd3_13: C12, số đo chính thức.
- gd3_10: gọi `record::start` sau khi overlay đóng, `output` phải nằm trong `save.videoDir` (gd3_12 cần) và chưa tồn tại (trùng tên ⇒ `OutputUnwritable`).

## 9. Bàn giao thực tế

- **Kết quả**: mọi case trừ C12 xanh. Soát trên nhánh đã gộp `master`: `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test -p fastcast-ui --all-targets` (9/9 `record_control`), `cargo test -p fastcast-core -p fastcast-capture`, `cargo deny check licenses`. Không chạy test của `fastcast-video` / `fastcast-ocr`: làn này không đụng hai crate đó. Lần soát cuối, lúc máy bận, `record_save::images_remember_their_own_dir` (gd3_12, luồng lưu ảnh, không qua `record`) đỏ một lần; chạy lại 3 lần cả tệp + 1 lần riêng đều xanh, đây là cùng kiểu đỏ khi máy bận đã ghi ở `plan/_backlog.md`.
- **Đo, sơ bộ** (bản release, máy đang bận vì các làn khác build, màn giả, ba cửa sổ, 10 s): RAM UI 17,1–18,4 MB. CPU đứng yên, đồng hồ không chạy: 266 ms / 10 s (≈ 2,7 % một nhân). Đồng hồ chạy: 453 ms / 10 s; thêm chữ báo: 656 ms / 10 s. Trên 12 luồng chỉ dưới 0,6 %, nhưng chưa phải 0: chưa tách được phần của khung với phần nền của GPUI. gd3_13 đo lại lúc máy rảnh.
- **Kiểm bằng mắt trên màn giả** (ảnh chụp đúng vùng màn giả, xem xong đã xoá): khung đủ bốn cạnh, thanh hiện đồng hồ và chữ báo, nền trong đúng D-10.
- **Kiểm một lần bằng mã tạm, đã gỡ**: popup thật vẽ đúng; bật cờ chống chụp thì khung + thanh không còn trong ảnh `CopyFromScreen`, kể cả khi cửa sổ layered; tắt cờ xuyên chuột thì `WindowFromPoint` trả chính cửa sổ khung (log `false`), bật lại ra `true`.
- **Chưa kiểm**: hạn 30 s sau `Stop` + nhánh giết worker treo (`fake_rec` không có cờ treo); viền vắt hai màn thật khác DPI; chuột thật (test đưa sự kiện thẳng vào GPUI).
- **Hiện tượng còn lại**: cửa sổ khung có viền DWM 1 px sẫm ở mép, thấy được ở khe nối giữa hai màn (ảnh chụp tại `x=700`). Viền này không vào video. Ghi vào C12 để chủ dự án nhìn trên màn thật.
- **Bẫy**: `SWP_ASYNCWINDOWPOS` gọi cùng luồng vẫn đồng bộ ⇒ "RefCell already borrowed", mất `WM_SIZE`, cửa sổ vẽ trống; test log vẫn xanh, chỉ nhìn ảnh mới thấy. `sys::place` gọi từ luồng khác và bù viền hệ thống để vùng vẽ đúng pixel. `hwnd` chép từ `platform.rs` vì tệp đó không thuộc làn này.
- **Opus chọn 30/10/2026** (đã ghi `plan/confirm.md`): tự làm `controls.rs` thay vì giao Sonnet; một cửa sổ nền trong cho mỗi màn thay vì bốn thanh; viền vẽ ngoài vùng, sát mép màn thì vào trong; hạn dừng 30 s; xoá `.part` khi lỗi.
- **Sự cố khi chạy thử**: `Get-Process fake_rec | Stop-Process -Force` đã giết cả `fake_rec` của các làn khác lúc khoảng 20:03. Test của làn khác đỏ đúng lúc đó thì chạy lại; đã báo ở thư mục ghi chú chung.

## 10. Đề xuất cải tiến

- [ux] Bấm nút dừng vẫn kích hoạt thanh, focus rời app đang dùng — `gpui-pre-windows/src/events.rs:95` luôn trả `MA_ACTIVATE` — sửa cần vá GPUI (D-6 đóng băng); sau khi dừng bảng gd3_12 cũng lấy focus nên giá trị thấp — S — P3. Không làm.
- [ux] `Screen::read` gọi `fastcast_capture::layout()` trên luồng UI lúc bắt đầu quay — `record/frame.rs` `Screen::read` — chưa đo; nếu gd3_13 thấy phím → khung chậm thì chuyển sang luồng nền như `overlay::freeze` — S — P3. Chờ số đo.
- [pro] Tạm dừng quay, vẽ chú thích trong lúc quay — phạm vi gd3_11 mục 2 đã loại — ghi để đặt chỗ huy hiệu Pro ở GĐ4 (D-4) — M — P3.
