# gd1_09 — Lấy màu (HEX / RGB / RGBA / OKLCH)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | gd1_02 · gd1_05 (chép chữ) |
| Quyết định áp dụng | F-1, F-3 |
| Phụ thuộc mới | — (đổi màu tự viết, không thêm crate) |
| File đụng tới | `crates/core/src/color.rs` MỚI · `crates/core/src/lib.rs` SỬA · `crates/ui/src/overlay/picker.rs` MỚI · `crates/ui/src/overlay/mod.rs` SỬA · `crates/ui/src/commands.rs` SỬA · `i18n/{vi,en}.toml` SỬA — thêm so với spec: `overlay/dev.rs`, `platform.rs`, `clipboard.rs`, `tests/{picker,common}` (mục 9) |

## 0. Bàn giao từ gd1_08 (30/10/2026)

<!-- handoff: gd1_08 -->

- **Đã có sẵn để dùng**: `overlay::Tool` + `overlay::open(freezing, tool, cx)` — thêm `Tool::Picker`, một nhánh `open_window` trong `open`; khuôn view một màn: `overlay/ruler.rs::RulerView` (không đọc phiên trong `render`, `Visible` so ở `observe`, `request_frame` theo chế độ nhẹ); `clipboard::copy_text` đã bỏ `expect(dead_code)`, mẫu chép + báo: `ruler.rs::copy_measure`.
- **Đổi so với lúc viết spec này**: `commands.rs` đóng băng theo `matches!(command, CaptureRegion | Ruler)` ⇒ thêm `ColorPicker`; `same_feature` đã coi `ColorPicker` là lệnh overlay (không mở chồng).
- **Bẫy đã gặp**: `tests/ipc.rs` đã thôi dùng `color_picker` — đừng thêm lại, lệnh này sắp mở overlay thật. Gộp master có thể xung đột ở `overlay/mod.rs`, `commands.rs`, i18n: giữ cả hai phía.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test overlay` (mẫu `fake_ruler_*`, kịch bản có thêm `shift on|off`); chi tiết `plan/gd1_08_ruler.md` mục 9.

## 0. Bàn giao từ gd1_05 (30/10/2026)

<!-- handoff: gd1_05 -->

- **Việc của task này**: Enter / nhấn chép mã màu: `crate::clipboard::copy_text(text, &requests).await`, `requests = cx.global::<UiState>().daemon.clone()` (chạy trong `cx.spawn`). Toast "Đã chép #1E90FF" có mã màu ⇒ gọi `notice::show(NoticeKind::Success, chữ, cx)` với khoá i18n riêng, không dùng `clipboard::report`.
- **Đã có sẵn để dùng**: `Message::ClipboardText { text: PrivateText(String) }` tối đa `ipc::MAX_CLIPBOARD_TEXT` (64 KiB), daemon
  giữ clipboard trên luồng riêng; `crates/ui/src/notice.rs` — popup không lấy focus, dùng được sau khi overlay đóng
  (`materiant::toast` thì cần cửa sổ còn mở). Gỡ `#[cfg_attr(not(test), expect(dead_code…))]` của `copy_text` khi dùng.
- **Đổi so với lúc viết spec này**: trường `text` là `PrivateText`, không phải `String` — `Debug` chỉ in độ dài. Đừng log nội dung chép.
- **Chạy thử không đụng clipboard của máy**: `fake_daemon` in `CLIPBOARD_TEXT <chữ>`, trả `Ok`; test tích hợp đọc `Message` từ
  `conn.recv()` — mẫu `fake_overlay_copy_through_the_daemon` ở `tests/overlay.rs`.
- **Bẫy đã gặp**: yêu cầu chép chờ daemon trả lời ⇒ giữ cờ "đang chép" để bấm lặp không gửi hai lần (mẫu `OverlaySession::begin_copy`).
  Máy đang bật lịch sử Win+V ⇒ clipboard thật chỉ thử qua `clipboard_probe`, đừng chạy lặp.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test overlay`; chi tiết `plan/gd1_05_clipboard.md` mục 9.

## 1. Làm gì

- `color_picker` ⇒ đóng băng + overlay chế độ `Picker`: kính lúp theo con trỏ (11 × 11 pixel vật lý phóng ×10, ô giữa
  có viền), dưới kính lúp là mã màu theo định dạng đang chọn.
- Nhấn chuột / Enter ⇒ chép mã theo `color.lastFormat` qua daemon, toast "Đã chép #1E90FF", đóng overlay.
- Tab / 1–4 đổi định dạng: `hex` (`#1E90FF`), `rgb` (`rgb(30 144 255)`), `rgba` (`rgba(30, 144, 255, 1)`), `oklch`
  (`oklch(0.652 0.19 253.2)` — spec cũ ghi `0.172 253.7`, sai; mục 9) — nhớ vào `color.lastFormat` (F-1: "nhớ lựa chọn gần nhất").
- Mũi tên dời con trỏ 1 px vật lý để nhắm chính xác.
- `color.rs` (core): sRGB → OKLab → OKLCH + định dạng chuỗi — hàm thuần, test với giá trị chuẩn.

## 2. Không làm trong task này

- Bảng màu đã lấy, lấy màu trung bình vùng.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `color.rs`, `picker.rs` (toạ độ vật lý, phiên, view), nối `commands` / `dev`, i18n, test | `[opus]` — task nhỏ, cùng một phiên, không tách Sonnet |
| So màu thật trên màn HDR / khác DPI, mũi tên kéo con trỏ thật, focus khi đổi màn | `[owner-qa]` |

## 3. Kiểu dữ liệu · IPC · cấu hình

`color.lastFormat` đã có (`ColorFormat::{Hex, Rgb, Rgba, Oklch}`). Màu đọc từ `Frozen::pixel(Point)`.

## 4. Code

`[opus]`: `color.rs` (công thức OKLab của Björn Ottosson, làm tròn: L 3 chữ số, C 3, H 1; xám ⇒ H = 0). Chuỗi `rgb`
theo cú pháp CSS Color 4 có khoảng trắng — xác nhận với chủ dự án nếu muốn dạng có dấu phẩy.

## 6. Nghiệm thu

| Case | Cho / Khi / Thì | Phủ |
| --- | --- | --- |
| C1 | Trắng, đen, xám ⇒ `oklch(1 0 0)`, `oklch(0 0 0)`, C = H = 0; `#ff0000` ⇒ `oklch(0.628 0.258 29.2)`; `#1e90ff`, lục, lam, vàng khớp bảng (sai ≤ 0,001) | `[opus-unit]` `color.rs` |
| C2 | Con trỏ ở điểm logic (100, 100) màn giả, Enter ⇒ daemon nhận mã HEX của đúng pixel vật lý trong ảnh | `[opus-run]` `tests/picker.rs` |
| C3 | Daemon từ chối ⇒ overlay còn mở, thử lại được; đồng ý ⇒ đóng + thông báo Success | `[opus-run]` |
| C4 | Màn thứ hai: mã đọc từ ảnh màn đó; Shift+mũi tên 10 px; mũi tên 1 px | `[opus-run]` |
| C5 | Phím 1–4, Tab, Shift+Tab đổi định dạng (Tab không bị `Root` nuốt) | `[opus-run]` |
| C6 | Đổi định dạng rồi đóng, khởi động lại UI ⇒ mở đúng định dạng cũ (`color.lastFormat`) | `[opus-run]` |
| C7 | Không đổi định dạng ⇒ không ghi cấu hình | `[opus-run]` |
| C8 | Enter lặp / nhấn chuột lúc đang chép ⇒ chỉ gửi một lần | `[opus-run]` |
| C9 | Nhấn chuột chép đúng điểm nhấn | `[opus-run]` |
| C10 | Mũi tên ở góc màn: con trỏ không ra ngoài; kẹp vào màn | `[opus-run]` |
| C11 | Esc / chuột phải đóng, không chép; lệnh lặp mở lại ấm | `[opus-run]` |
| C12 | Di chuột trên màn 0 không vẽ lại màn 1 | `[opus-run]` |
| C13 | Màn 150 %: toạ độ logic ↔ pixel vật lý khớp từng pixel; ảnh đọc đúng pixel vật lý, cả màn toạ độ âm | `[opus-unit]` `picker.rs` |
| C14 | Màn HDR / khác DPI thật: so mã với màu thật, mũi tên kéo con trỏ thật, kính lúp đổi màn | `[owner-qa]` — chờ kiểm tay |
## 7. Ghi chú UI

```
 ┌───────────┐
 │  ▦▦▦▦▦▦▦  │  kính lúp 110 × 110 logic, lưới mảnh, ô giữa viền trắng + đen
 │  ▦▦▦■▦▦▦  │
 └───────────┘
  ■ #1E90FF   HEX · RGB · RGBA · OKLCH   (Tab)
```

Khoá i18n: `picker.hint`, `picker.copied` (`{code}`). Tên định dạng `hex` / `rgb` / `rgba` / `oklch` là thuật ngữ, không dịch; viết thường (chủ dự án yêu cầu 30/10/2026).

## 8. Nợ chuyển task khác

- Không.

## 9. Bàn giao thực tế

- **Kết quả**: lấy màu chạy trên màn giả: 6 test `tests/picker.rs` + `fake_daemon` in `CLIPBOARD_TEXT oklch(0.427 0.151 265.8)`.
  Soát xanh sau khi gộp master (gd1_08, gd1_10): build, clippy, test (core 54, ui 128 + ipc 5 + overlay 14 + picker 6), `deny` licenses ok.
  Lần chạy đầu `tests/overlay.rs` đỏ 3 test (hết thời gian chờ log, lúc máy build song song); chạy lại đều xanh.
- **Spec sai, đã sửa**: `#1E90FF` là `oklch(0.652 0.19 253.2)`, không phải `0.172 253.7`. Kiểm hai đường độc lập (ma trận
  sRGB → LMS trong code; sRGB → XYZ → OKLab bằng script ngoài); đỏ / lục / lam / vàng khớp bảng CSS.
- **Opus chọn 30/10/2026** (đều ở `plan/confirm.md`): `rgb` giữ cú pháp có khoảng trắng; phiên `PickerSession` + view riêng
  thay chế độ trong `OverlaySession`; mũi tên kéo cả con trỏ thật; nhớ định dạng lúc đóng; số 0 thừa bị bỏ (`0.19`, `1`).
- **Thêm ngoài spec**: Shift+mũi tên 10 px, Ctrl+C, chuột phải đóng — cùng phím với chọn vùng.
- **Ngoài dòng "File đụng tới"**: `overlay/dev.rs` (`run_script` nhận hàm lấy cửa sổ, dùng chung hai phiên), `platform.rs`
  (`set_cursor_pos`), `clipboard.rs` (gỡ `expect(dead_code)`), `tests/common` (`has_log`); `tests/ipc.rs` lấy bản gd1_08 (đã thôi dùng
  `color_picker`).
- **Đo**: không đo RAM / độ trễ riêng; cùng đường ảnh đóng băng với overlay, gom vào lượt đo gd1_11. Khung đầu bản debug màn giả
  1,2–1,7 s lúc máy bận build, không phải số tham chiếu.
- **Chờ kiểm tay** (C14, `plan/_backlog.md`). macOS / Ubuntu: `set_cursor_pos` chưa làm, mũi tên chỉ dời điểm nhắm, di chuột nhẹ là về con trỏ thật.
- **Khác khuôn gd1_08**: không thêm `Tool::Picker`; `OverlaySession` mang vùng chọn + thanh công cụ mà lấy màu không dùng, `PickerSession` đủ. View theo đúng luật `RulerView` (`render` không đọc phiên, `request_frame`).
- **Đề xuất đã làm**: chế độ nhẹ WARP / RDP cho lấy màu (`request_frame`, cùng nhịp với overlay); chỗ Pro ghi ở `ROADMAP.md` GĐ4.
- **Soi không ra lỗi**: log chỉ ghi toạ độ + định dạng, không ghi mã màu; chép đi qua `PrivateText`; không tệp tạm.

## 10. Đề xuất cải tiến

- [ram] Lấy màu vẽ lại toàn màn mỗi lần di chuột, trên WARP / RDP tốn CPU — `render_mode.rs` chỉ áp cho `OverlayView` — chặn nhịp khung bằng `RenderMode::frame_wait` — dùng được qua RDP — S — P2 — **đã làm**.
- [pro] Bảng màu đã lấy + thêm định dạng (HSL, Tailwind, SwiftUI) — mục 2 loại khỏi task — huy hiệu "Pro" ở GĐ4 — dev trả tiền cho quy trình — M — P3 — **đã ghi `ROADMAP.md`**.
