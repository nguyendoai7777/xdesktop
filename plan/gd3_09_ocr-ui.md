# gd3_09 — OCR vùng chọn → Ctrl/Cmd+C

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay ở gd3_13 |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd3_08 (`fake_ocr` có từ gd3_01; KHÔNG cần gd3_02, gd3_03) |
| Quyết định áp dụng | F-3, F-4, F-6, D-10 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/ocr/{mod,client}.rs`, `overlay/ocr_panel.rs`; MỚI `crates/ui/tests/ocr.rs` |

## 0. Bàn giao từ gd3_08 (30/10/2026)

<!-- handoff: gd3_08 -->

- **Đã có sẵn để dùng**: `overlay/ocr_panel.rs` đã nối, chỉ điền tệp này. `Tool::Ocr` có tay nắm, thanh Chép + Đóng. Module con đọc được trường riêng của phiên: `session.ocr`, `session.selection`, `session.crop_job(region)`, `session.begin_copy()`, `session.close(cx)`.
- **Đổi so với spec**: `render(visible, widgets, host, window, cx)`, không còn `at`: `view` đã đặt chỗ, `occlude`, chặn chuột. `host.session` là `WeakEntity`, `host.root` là focus gốc. Thêm móc `state`, `size`, `copy` (nút Chép). Gỡ `#[allow(dead_code)]` trên `OverlaySession::ocr`, `PanelHost` khi dùng tới.
- **Bẫy**: `PanelState` sao ở `cx.observe` nên đổi `session.ocr` phải `cx.notify()`, và phải `PartialEq` đúng. `selection_changed` không gọi khi vùng bị bỏ ⇒ hẹn giờ 150 ms xong đọc lại `session.selection`. `size` là chỗ dành sẵn, chữ ngắn thì panel thấp hơn cũng không hở vì thanh nằm trên.
- **Phím**: `on_key` chạy trước mọi phím kể cả Esc, Ctrl+C, Enter; Enter lúc focus ở nút không tới đây. Ctrl+C không có ở `view` cho `Tool::Ocr`: panel không bắt thì không có gì xảy ra.
- **Soát lại khi làm**: `fake_ocr_toolbar_has_copy_and_close_and_no_drawing_keys`, chỉ đợi dòng log `overlay: action copy`. Máy bận thì chạy `--test-threads=1` trước khi kết luận đỏ.

## 0. Bàn giao từ gd3_01 (30/10/2026)

<!-- handoff: gd3_01 -->

- **Đã có sẵn để dùng**: `crates/ui/src/ocr/mod.rs` stub `recognize` (`#![allow(dead_code)]`, gỡ khi nối panel); `worker::exe_path(OCR_EXE_VAR, OCR_EXE)`; `crates/ui/examples/fake_ocr.rs`: `--delay-ms`, `--fail <code>`, `--text ""` (không chữ), `--die-after <n>` (con chết giữa chừng). Mã nạp hỏng ra `Failed { id: None }` rồi thoát, mã còn lại `Ready` rồi hỏng từng ảnh. Xoá tệp ảnh như worker thật.
- **Bẫy**: bật con cần `CREATE_NO_WINDOW`. `ocr.copy_hint` có tham số `{copy}`, như `ruler.copy_hint`.

## 1. Làm gì

- `ocr/client.rs`: bật `fastcast-ocr` cạnh exe (`FASTCAST_OCR_EXE` đè), đọc stdout ở luồng nền, giữ tiến trình giữa các lần đọc. Con chết ⇒ bật lại một lần, vẫn hỏng thì báo lỗi.
- Ảnh đi bằng tệp RGBA trong `paths::ensure_tmp_dir()` như `ClipboardImage`; hỏng trước khi gửi ⇒ tự xoá.
- Nhả chuột / chỉnh vùng xong ⇒ đọc sau 150 ms không đổi nữa. Trả lời có `id` cũ thì bỏ.
- Panel cạnh vùng: đang đọc, chữ kết quả (cuộn được, `cx.floating_surface()` — D-10), không có chữ, lỗi có "thử lại".
- Ctrl/⌘+C, Enter: chép chữ qua `clipboard::copy_text` (async, cần `ipc::Requests`, mẫu ở `overlay/ruler.rs`), đóng overlay, `notice::show` "đã chép {count} ký tự". Bấm lúc đang đọc ⇒ đợi xong rồi chép. Không có chữ ⇒ không đóng.
- UI thoát hoặc giữ ấm hết hạn ⇒ `Shutdown`; không giữ worker quá 60 s rảnh.

## 2. Không làm trong task này

Sửa chữ trong panel, chép một phần. Nút OCR trên thanh chụp. Engine.

## 2b. Phân vai

`[opus]` `client.rs` + luồng hủy / chép chờ + phần vẽ panel (cùng tệp với logic, lời giao dài bằng code — mục 9). `[owner-qa]` kiểm trong gd3_13.

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thêm thông điệp, khoá config, khoá i18n. Trong tiến trình: `ocr::recognize(job, cx, done)`, `ocr::cancel(cx)`. `Phase` trong panel: `Idle | Reading | Text | Empty | Failed(OcrError)`.

## 4. Code

Luồng `ocr-client` sở hữu tiến trình con + hàng đợi một chỗ (mới thay cũ), cắt ảnh + ghi tệp ở đó. Panel giữ vùng, số lần đọc, hẹn 150 ms, cờ chép chờ.

## 5. Đo

**Đo**: RAM giữ ấm của UI không tăng (OCR ở tiến trình khác), độ trễ thả chuột → chữ khi có engine thật. Lấy ở gd3_13 (luật làn: số đo chính thức lúc không làn nào chạy).

## 6. Nghiệm thu

Phủ bởi `crates/ui/tests/ocr.rs` (`FASTCAST_OVERLAY_FAKE=1` + `fake_ocr`) `[opus-unit]`; mọi ca đều soát không còn `ocr-*` trong `tmp/` và log không có chữ / đường dẫn.

| Case | Cho | Khi | Thì | Test |
|---|---|---|---|---|
| C1 | `--text` có dấu | chọn vùng, Enter | chép đúng chữ, đóng, báo | `reads_then_enter_copies_and_closes` |
| C2 | `--text ""` | Ctrl+C, Enter | không gửi gì, không đóng; Esc đóng | `empty_text_does_not_copy_or_close` |
| C3 | `--fail` từng mã; không có exe | chọn vùng, Enter | đúng chữ báo, Enter thử lại | `each_failure_code_shows_its_message`, `missing_worker_exe_reports_reinstall` |
| C4 | đọc 600 ms | đổi vùng lúc đang đọc | trả lời cũ bị bỏ, chép chữ vùng mới | `stale_reply_is_dropped_and_latest_region_wins` |
| C5 | đọc 800 ms | Ctrl+C lúc đang đọc | đọc xong mới chép; Esc thì thôi | `copy_while_reading_waits_for_the_text`, `escape_cancels_a_waiting_copy` |
| C6 | daemon từ chối | Ctrl+C | overlay còn mở, chép lại được | `copy_refused_keeps_overlay_for_another_try` |
| C7 | `--die-after 1` | đọc ảnh thứ hai | bật lại một lần, đọc được | `worker_death_restarts_once_and_recovers` |
| C8 | `--die-after 0` | đọc | chết hai lần ⇒ báo lỗi | `worker_dying_twice_reports_failure` |
| C9 | rảnh quá hạn (đè 1 s) | đợi, chọn lại | con thoát, lần sau bật con mới | `idle_worker_shuts_down_and_comes_back` |
| C10 | con treo (đè hạn 1 s) | đọc | giết, báo lỗi | `hung_worker_is_killed_and_reported` |
| C11 | UI thoát / bị giết | | con thoát, không mồ côi | `worker_exits_with_the_ui`, `worker_exits_when_the_ui_is_killed` |
| C12 | ảnh sót trong `tmp/` | lần đọc đầu | bị dọn | `leftover_images_are_swept_on_first_read` |

- `[owner-qa]` Trong gd3_13: engine thật, ảnh thật, tiếng Việt có dấu, nền tối, chữ 11–12 px, vùng vắt hai màn.

## 7. Ghi chú UI

```
┌ vùng chọn ─────────┐
│                    │
└────────────────────┘
┌ panel ─────────────┐
│ chữ đã đọc…        │  ScrollArea, tối đa 240 px cao
│ ctrl+c để chép     │  khoá `ocr.copy_hint`
└────────────────────┘
```

Khoá `ocr.*` có sẵn từ gd3_01. Sáng / tối, vi / en.

## 8. Nợ chuyển task khác

- gd3_13: số đo RAM giữ ấm + độ trễ thả chuột → chữ với engine thật; soát `fastcast-ocr` thật trả đúng mã khi thiếu model (mục 9).

## 9. Bàn giao thực tế

**Soát** (sau khi gộp `master` vào nhánh, `CARGO_TARGET_DIR=C:/xdesktop-target/gd3_09`): `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test --no-fail-fast -- --test-threads=4`, `cargo deny check licenses` đều xanh; `tests/ocr.rs` 15 ca, ~70 s vì chạy nối tiếp.

**Chạy thử** chỉ trên màn giả + `fake_ocr`, chụp bằng `PrintWindow` rồi xoá ảnh: chữ dài cuộn được, cao tối đa 240 px, gợi ý nằm dưới; sáng / tối đúng; chữ có dấu đúng; lỗi có nút thử lại.

**Chưa đo**: RAM, độ trễ (mục 5, chuyển gd3_13). Chưa chạy với engine thật. Phụ thuộc mới: không; thêm một luồng chờ + một global, sống tới khi UI thoát.

**Opus chọn 30/10/2026** (D-9, cũng ở `plan/confirm.md`):
- Tự làm phần vẽ panel thay vì giao Sonnet: cùng tệp với logic chép / huỷ.
- Hàng đợi một chỗ, mới thay cũ, thay vì gửi hết cho con: chỉnh vùng liên tục không dồn ảnh cũ.
- Không có exe ⇒ `RuntimeMissing` ("hãy cài lại"), không phải lỗi chung: thử lại không giúp được gì.
- Enter khi đang báo lỗi = thử lại; đang hiện chữ = chép.
- Thêm hạn 60 s cho con không trả lời (`FASTCAST_OCR_REPLY_SECS`), ngoài spec: không có thì panel kẹt "đang đọc".
- `SIZE` cao 300 thay vì 280: khối chữ tối đa cần ~294 px, 280 thì tràn ở mép màn.
- Không dùng khoá `ocr.result_title`: bố cục mục 7 không có tiêu đề.

**Sửa ngoài tệp sở hữu**, có lý do:
- `overlay/mod.rs`: gỡ `#[allow(dead_code)]` trên `ocr`, `PanelHost` (bàn giao gd3_08 yêu cầu).
- `tests/overlay.rs`: `spawn_panel_tool` trỏ `FASTCAST_OCR_EXE` vào exe không có. Test `fake_ocr_toolbar_…` đỏ vì hai điều: nút thử lại thêm một điểm dừng Tab, và `target/` đã có `fastcast-ocr` thật nên kết quả phụ thuộc engine. Giờ panel luôn ra lỗi, thứ tự Shift+Tab: thử lại, Đóng, Chép.

**Bẫy**:
- `fake_ocr` nhận cờ qua dòng lệnh ⇒ test bọc bằng `.cmd`, cần `chcp 65001` thì chữ có dấu trong `--text` mới đúng. Pid trong log là của script.
- `dirs::data_local_dir` trên Windows không theo biến môi trường ⇒ test không tách được `tmp/`: mọi ca trong `tests/ocr.rs` chạy nối tiếp.
- `cargo test --test ocr` không build example; chạy riêng thì `cargo build -p fastcast-ui --example fake_ocr` trước.
- Soát sơ `fastcast-ocr` thật lúc chưa có engine: log `ocr: worker failed: Internal`, panel báo lỗi chung thay vì "thiếu model". Chưa điều tra; gd3_13 soát lại khi đủ engine.

## 10. Đề xuất cải tiến

Soi bốn lăng kính:

- **Bảo mật / riêng tư**: tệp tên ngẫu nhiên, `create_new`, xoá ở mọi nhánh; log chỉ có số ký tự + khoá i18n (test soát). Một lỗ đã vá: UI và con cùng chết thì ảnh nằm lại ⇒ dọn ở lần đọc đầu (C12, đã làm).
- **UI/UX**: dùng hết bằng bàn phím (Tab tới nút thử lại, Enter, Esc). Nhiều màn khác DPI: chưa kiểm được, ở `[owner-qa]`.
- **RAM**: không phụ thuộc mới; yêu cầu chờ thả ảnh đóng băng khi đóng overlay (`on_release` → `cancel`, cả ảnh đang ở con); số đo ở gd3_13.
- **Pro (D-4)**: không có gì đáng đặt chỗ trong task này.

Còn lại:

- `[ux]` Bấm Chép khi không có chữ không có phản hồi — `ocr_panel::copy` bỏ qua, đúng spec, panel đang ghi rõ "không thấy chữ" nên ít gây nhầm — làm mờ nút Chép theo trạng thái — nhỏ — S — P3. Không làm: nút ở `toolbar.rs` của gd3_08, cần đường dữ liệu mới từ panel sang thanh, giá trị thấp.
- `[ux]` Chữ dài hơn 64 KB chép ra "chép lỗi" chung — `clipboard::copy_text` từ chối, chưa gặp với ảnh chụp màn hình — S — P3. Không làm: chưa có ca thật.
