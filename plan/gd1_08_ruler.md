# gd1_08 — Thước căn trên màn đóng băng

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~350 dòng |
| Phụ thuộc | gd1_02 · gd1_05 (chép chữ) |
| Quyết định áp dụng | F-1, F-3 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/ruler.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA · `crates/ui/src/commands.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

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

## 4. Code

Dùng `selection.rs` của gd1_02 (cùng máy trạng thái kéo) nhưng không có tay nắm / thanh công cụ. Nhãn `px` là pixel
**vật lý** — dev FE cần cả CSS px ⇒ hiện thêm `(@1.5x: 213×32)` khi màn có scale ≠ 1.

## 6. Nghiệm thu

- Kéo 100 px logic trên màn 150 % ⇒ nhãn 150 px vật lý + `@1.5x: 100`.
- Trục vẽ trên đúng màn chứa con trỏ khi con trỏ đi qua màn khác.
- `[owner-qa]`: đo một nút trên trang web đã biết cỡ CSS ⇒ khớp.

## 7. Ghi chú UI

Trục 1 px logic màu nhấn, nhãn nền tối chữ sáng. Khoá i18n: `ruler.copy_hint`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
