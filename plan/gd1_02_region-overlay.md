# gd1_02 — Overlay đóng băng + kéo chọn vùng xuyên nhiều màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~700 dòng |
| Phụ thuộc | gd1_01 · nên có kết quả gd0_07 (overlay trên Wayland) trước khi khoá API overlay |
| Quyết định áp dụng | F-3, F-4, D-3 |
| Phụ thuộc mới | — (`fastcast-capture` đã có) |
| File đụng tới | `crates/ui/src/overlay/mod.rs` MỚI · `crates/ui/src/overlay/selection.rs` MỚI · `crates/ui/src/overlay/view.rs` MỚI · `crates/ui/src/commands.rs` SỬA · `crates/ui/Cargo.toml` SỬA |

## 1. Làm gì

- `capture_region` ⇒ `fastcast_capture::freeze()` rồi mở **mỗi màn một cửa sổ** không viền, toàn màn hình, luôn trên
  cùng; khớp màn của xcap (pixel vật lý) với display của GPUI (gốc logic = gốc vật lý / scale của chính màn đó).
- Vẽ ảnh đóng băng 1:1 pixel vật lý, lớp tối phủ ngoài vùng chọn, vùng chọn sáng + viền + nhãn `W × H` (pixel vật lý).
- Kéo chọn theo **toạ độ toàn cục vật lý**: nhấn ở màn A, kéo sang màn B — mọi cửa sổ vẽ lại phần của mình
  (`Layout::split`). Con trỏ ra khe giữa các màn ⇒ `Layout::clamp`.
- Góc vùng chọn chốt theo vị trí của **sự kiện nhả chuột** (Windows giao nhả chuột trước lần di cuối — bẫy đã gặp ở spike).
- Esc / chuột phải khi chưa chọn ⇒ đóng mọi overlay. Nhả chuột ⇒ giữ vùng chọn (gd1_03 làm chỉnh + thanh công cụ).
- `selection.rs`: máy trạng thái thuần (`Idle → Dragging{start} → Selected(Rect)`), nhận điểm toàn cục — test đơn vị.

## 2. Không làm trong task này

- Chỉnh vùng chọn sau khi nhả (tay nắm, di chuyển, phím mũi tên), thanh công cụ: gd1_03.
- Chế độ overlay nhẹ cho WARP / RDP: gd1_10.

## 3. Kiểu dữ liệu · IPC · cấu hình

`OverlaySession { frozen: Frozen, selection: SelectionState, windows: Vec<WindowHandle<OverlayView>> }` — một phiên
dùng chung cho mọi cửa sổ (Entity), mỗi `OverlayView` biết `monitor: usize`.

## 4. Code

- Mẫu đã chạy: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` — `open_overlays`, `OverlayView`, `to_global`,
  bắt `MouseUpEvent` ở mọi cửa sổ (`window.on_mouse_event`), mẹo kéo xuyên màn bằng `canvas`.
- **Quyết định trong task**: ai đóng băng màn — UI (khuyên: daemon giữ nhẹ, F-4) hay daemon (nhanh hơn khi UI nguội).
  Đo độ trễ mục 5; nguội > 400 ms ⇒ ghi đề xuất mục 10, không tự đổi kiến trúc.

## 5. Đo

- Phím tắt → khung đầu của overlay trên mọi màn: UI nguội / ấm (spike: 324–344 ms nguội gồm chụp ~40–50 ms).
- RAM `fastcast-ui` khi overlay đang mở trên 2 màn 1080p; CPU khi kéo 2 s (spike: 62 ms GPU thật).

## 6. Nghiệm thu

- Kéo chọn vắt hai màn khác Hz (DELL 60 Hz + LG 144 Hz của máy nhà) ⇒ vùng liền mạch, nhãn đúng kích thước vật lý.
- Màn scale 125 % / 150 % (chỉnh trong Windows) ⇒ ảnh nét 1:1, không mờ, không lệch vùng.
- Test đơn vị máy trạng thái: kéo ngược hướng, kéo 0 px, nhả ngoài mọi màn.
- `[owner-qa]`: không có màn đen / nháy khi mở overlay trên 2 màn khác Hz.

## 7. Ghi chú UI

Lớp tối: đen alpha 0,45. Viền vùng chọn 1 px logic màu nhấn của theme. Nhãn `W × H` góc trên trái phía ngoài vùng, lật
vào trong khi sát mép màn. Con trỏ chữ thập.

## 8. Nợ chuyển task khác

- Thanh công cụ + chỉnh vùng: gd1_03. Lưu / chép: gd1_04, gd1_05. Overlay dùng lại cho thước (gd1_08), lấy màu (gd1_09).

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
