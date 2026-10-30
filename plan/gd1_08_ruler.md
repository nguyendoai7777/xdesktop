# gd1_08 — Thước căn trên màn đóng băng

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | S — ~520 dòng + 190 dòng test (ước lượng cũ ~350) |
| Phụ thuộc | gd1_02 · gd1_05 (chép chữ) |
| Quyết định áp dụng | F-1, F-3 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/ruler.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA · `crates/ui/src/commands.rs` SỬA · `i18n/{vi,en}.toml` SỬA · thêm: `overlay/view.rs` (2 `pub(super)`), `overlay/dev.rs` (bước `shift`), `clipboard.rs`, `tests/{ipc,overlay}.rs`, `CLAUDE.md` |

## 0. Bàn giao từ gd1_05 (30/10/2026)

<!-- handoff: gd1_05 -->

- **Việc của task này**: Ctrl/Cmd+C chép `W×H`: `crate::clipboard::copy_text(text, &requests).await`, `requests = cx.global::<UiState>().daemon.clone()` (không chặn vòng GPUI: chạy trong `cx.spawn`). Thông báo chung `clipboard::report(ok, cx)` ("Đã chép" / lỗi).
- **Đã có sẵn để dùng**: `Message::ClipboardText { text: PrivateText(String) }` tối đa `ipc::MAX_CLIPBOARD_TEXT` (64 KiB), daemon
  giữ clipboard trên luồng riêng; `crates/ui/src/notice.rs` — popup không lấy focus, dùng được sau khi overlay đóng
  (`materiant::toast` thì cần cửa sổ còn mở). Gỡ `#[cfg_attr(not(test), expect(dead_code…))]` của `copy_text` khi dùng.
- **Đổi so với lúc viết spec này**: trường `text` là `PrivateText`, không phải `String` — `Debug` chỉ in độ dài. Đừng log nội dung chép.
- **Chạy thử không đụng clipboard của máy**: `fake_daemon` in `CLIPBOARD_TEXT <chữ>`, trả `Ok`; test tích hợp đọc `Message` từ
  `conn.recv()` — mẫu `fake_overlay_copy_through_the_daemon` ở `tests/overlay.rs`.
- **Bẫy đã gặp**: yêu cầu chép chờ daemon trả lời ⇒ giữ cờ "đang chép" để bấm lặp không gửi hai lần (mẫu `OverlaySession::begin_copy`).
  Máy đang bật lịch sử Win+V ⇒ clipboard thật chỉ thử qua `clipboard_probe`, đừng chạy lặp.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test overlay`; chi tiết `plan/gd1_05_clipboard.md` mục 9.

## 0. Bàn giao từ gd1_07 (30/10/2026)

<!-- handoff: gd1_07 -->

- **Đã có sẵn để dùng**: UI gửi được yêu cầu tới daemon và chờ trả lời — `cx.global::<UiState>().daemon` (`ipc::Requests`):
  `requests.request(Message::…)` trả future (`io::Result<Message>`), `requests.notify(msg, cx)` khi không cần trả lời.
  Chạy trên chính kết nối nhận lệnh, trả lời ghép FIFO; chưa nối daemon ⇒ lỗi `NotConnected` ngay. Ctrl+C chép `W×H`
  "qua daemon" đi đường này (thông điệp chép chữ do gd1_05 thêm vào `Message`).
- `fake_daemon` trả lời yêu cầu của UI: thông điệp nó chưa biết ⇒ `Error { "fake daemon: unexpected …" }` — thêm nhánh
  in ra (như `SUSPEND` / `RELOAD`) khi thử chép chữ bằng daemon giả.
- **Bẫy đã gặp**: GPUI chạy action gán phím TRƯỚC `capture_key_down` (Enter / Esc của component có thể nuốt trước) —
  phím cần chặn chắc thì `cx.intercept_keystrokes` (mẫu `launcher/view.rs::start_recording`); interceptor đã
  `stop_propagation` thì key listener VẪN chạy ⇒ cần cờ bỏ qua một lần (`swallow_key`).
- `Keystroke::parse` của gpui-pre đòi `&'static str` (test / kịch bản phím).
- Phím chạy thử không đụng bàn phím thật: overlay đã có `FASTCAST_OVERLAY_SCRIPT`; launcher có `FASTCAST_LAUNCHER_KEYS`.
- **Soát lại khi làm**: `cargo test -p fastcast-ui` (bin 87 test sau gd1_03 + gd1_07); `tests/overlay.rs` chập chờn khi
  máy đang build song song — đỏ thì chạy lại riêng trước khi nghi code. Chi tiết gd1_07: `plan/gd1_07_hotkey-assign.md`
  mục 9.

## 1. Làm gì

- `ruler` ⇒ đóng băng + overlay (dùng lại gd1_02, chế độ `Ruler`): hai trục x / y mảnh đi qua con trỏ, kéo hết màn
  đang chứa con trỏ; nhãn toạ độ con trỏ (pixel vật lý, cục bộ của màn).
- Nhấn – kéo – nhả ⇒ hình chữ nhật từ điểm đầu tới điểm cuối, nhãn `W × H px` (pixel vật lý). Kéo lại ⇒ đo mới.
- Ctrl/Cmd+C chép `W×H` (vd `320×48`) qua daemon; Esc thoát.
- Shift khi kéo ⇒ khoá một trục (đo thuần ngang / dọc).

## 2. Không làm trong task này

- Đo nhiều hình cùng lúc, tự bắt cạnh phần tử (snap to edges) — ghi đề xuất nếu thấy đáng.

## 2b. Phân vai

| Phần việc | Vai |
| --- | --- |
| Toàn bộ `ruler.rs` (hình học đa màn, khoá trục, view), nối `mod.rs` / `commands.rs`, test, i18n | `[opus]` — không giao Sonnet: i18n chỉ 2 dòng, dính interface đang chốt |
| Đo trên nút web thật, màn khác DPI thật | `[owner-qa]` |

## 4. Code

Dùng `selection.rs` của gd1_02 (cùng máy trạng thái kéo) nhưng không có tay nắm / thanh công cụ. Nhãn `px` là pixel
**vật lý** — dev FE cần cả CSS px ⇒ hiện thêm `(@1.5x: 213×32)` khi màn có scale ≠ 1.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ bởi | KQ |
| --- | --- | --- | --- |
| C1 | Màn 150 %, kéo 100 px logic (pixel 300 → 449) ⇒ nhãn `150 × 150 px (@1.5x: 100×100)`; `320×48` ⇒ `(@1.5x: 213×32)`; màn 100 % không có phần `@` | `[opus-unit]` `hundred_logical_px…`, `label_matches…` | ✅ |
| C2 | Con trỏ qua màn khác ⇒ trục + toạ độ cục bộ chỉ ở màn chứa con trỏ; di ở màn 0 không vẽ lại màn 1 (30 lần di: màn 1 vẽ 7 lần) | `[opus-unit]` `axes_are_drawn_only…` + `[opus-run]` `fake_ruler_axes…` | ✅ |
| C3 | Ctrl+C khi chưa đo ⇒ không gửi; đã đo ⇒ `ClipboardText` đúng `W×H`, daemon từ chối ⇒ giữ số đo + báo lỗi, chép lại ⇒ đóng + báo | `[opus-run]` `fake_ruler_measures…`, `fake_daemon` in `CLIPBOARD_TEXT 201×81` | ✅ |
| C4 | Shift khi kéo ⇒ khoá trục lệch ít (cả lúc đứng yên, cả khe giữa màn so le) | `[opus-unit]` `shift_*`, `pressing_shift…` + `[opus-run]` | ✅ |
| C5 | Kéo lại ⇒ đo mới; Esc thoát ngay | `[opus-unit]` `dragging_again…` + `[opus-run]` | ✅ |
| C6 | Đo một nút trên trang web đã biết cỡ CSS ⇒ khớp; đo trên hai màn khác DPI thật | `[owner-qa]` — `plan/_backlog.md` | chờ kiểm tay |

## 7. Ghi chú UI

Trục 1 px logic màu nhấn, nhãn nền tối chữ sáng. Khoá i18n: `ruler.copy_hint`.

## 8. Nợ chuyển task khác

- gd1_11 (nghiệm thu, phụ thuộc cả dải): đưa C6 vào bước kiểm tay.

## 9. Bàn giao thực tế

- **Đã có**: `Command::Ruler` mở `overlay::open(f, Tool::Ruler, cx)`; `RulerView` chạy trên `OverlaySession` (dùng lại `SelectionState`, `to_global`, `close`, `copy_finished`), không tay nắm / thanh công cụ / lớp tối. Thêm `RulerState` + `Tool` ở `overlay/mod.rs`.
- **Quyết định (Opus chọn 30/10/2026, gạch ở `confirm.md`)**: số đo gồm cả pixel đầu và cuối; Esc thoát ngay; chép xong đóng overlay; vắt qua hai màn khác scale thì không hiện phần `@`.
- **Lỗi an toàn đã chặn**: `tests/ipc.rs` dùng `ruler` / `color_picker` làm lệnh "chưa có cửa sổ" ⇒ khi thước thành overlay, test sẽ chụp + phủ màn thật. Đã đổi sang `ocr_region` / `record_region`, sửa `CLAUDE.md`.
- **Plan lệch code**: spec không ghi `view.rs` / `dev.rs`; đã thêm `pub(super)` cho `piece_of`, `rect_div` và bước kịch bản `shift on|off`. `ruler.rs` dài hơn ước lượng, vẫn dưới trần.
- **Gộp master**: xung đột với gd1_10 ở `CLAUDE.md`, `overlay/mod.rs`, `tests/overlay.rs`, giữ cả hai phía, soát xanh lại. Thước dùng luôn nhịp khung chế độ nhẹ (`RenderMode::frame_wait`).
- **Soát** (worktree, sau gộp gd1_10): `cargo build`, `clippy -D warnings`, `cargo test` (bin UI 121 ✅, overlay 14 ✅ + 4 đo ignored), `cargo deny check licenses` ✅; `FASTCAST_OVERLAY_RENDER=light` hai test thước ✅.
- **`[opus-run]`**: màn giả + `FASTCAST_OVERLAY_SCRIPT` + `fake_daemon`: `CLIPBOARD_TEXT 201×81`, focus máy không đổi (`foreground_unchanged=True`). Ảnh `PrintWindow` hai cửa sổ của app, đã xem rồi xoá: trục, nhãn, viền đúng; đọc pixel viền nằm ngoài vùng đo.
- **Chưa kiểm**: overlay thật, màn khác DPI thật (màn giả cùng scale với màn chính, số @ phủ bằng unit test), bản dịch `vi` chưa nhìn trên màn (ảnh chạy cấu hình `en`), RAM không đo vì dùng chung phiên overlay với gd1_02. Chờ kiểm tay: C6.
- **Đề xuất đã làm** (mục 10): (1), (2), (3).

## 10. Đề xuất cải tiến

1. ✅ `[ux]` Bấm lệnh overlay khác khi đang có overlay ⇒ mở chồng, ảnh đóng băng dính overlay cũ — `commands.rs` `route` so từng lệnh — lệnh overlay loại trừ nhau, đưa cửa sổ đang mở lên — tránh kẹt phiên dưới — S — P1. Đã làm (`same_feature`).
2. ✅ `[ux]` Kéo chuột khó trúng pixel trên màn scale cao — Alt + mũi tên chỉnh cạnh phải / dưới 1 px (Shift: 10), dùng lại `OverlaySession::arrow` — đo chính xác, dùng được bằng phím — S — P2. Đã làm.
3. ✅ `[ux]` "Đã chép" không nói chép gì — khoá `ruler.copied` "Đã chép 320×48" — S — P2. Đã làm.
4. `[ux]` Trước lần đo đầu không có gợi ý nào (Esc, kéo để đo) — `ruler.rs` chỉ hiện gợi ý khi `finished` — thêm dòng "Kéo để đo · Esc thoát" tự ẩn sau lần di đầu — S — P3. Vào backlog: chờ chủ dự án xem tay có thấy cần.
5. `[ux]` `MEASURE_ROOM` / `POINTER_ROOM` là số cố định, cỡ chữ lớn thì nhãn có thể tràn mép phải — `ruler.rs` — đo chữ thật khi có Settings → Cỡ chữ (GĐ4) — S — P3. Vào backlog: chờ GĐ4.
6. `[pro]` Tự bắt cạnh phần tử, đo nhiều hình cùng lúc — mục 2 của task — huy hiệu "Pro" — M — P3. Đã ghi `fastcast/ROADMAP.md` GĐ4.
- Bảo mật: không log nội dung chép (chỉ log cỡ đo, không nhạy cảm), ảnh nhả cùng phiên, không IPC mới. RAM: không phụ thuộc mới, không thêm bản sao ảnh.
