# gd1_10 — Overlay nhẹ cho máy không GPU / phiên RDP

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast (có thể chạm `materiant/spikes/ui-foundation` để thử nhanh) |
| Cỡ | M — gồm đo + một hướng sửa |
| Phụ thuộc | gd1_02, gd1_03 |
| Quyết định áp dụng | F-3, D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/overlay/render_mode.rs` MỚI · `crates/ui/src/overlay/view.rs` SỬA · `crates/capture/src/lib.rs` SỬA (nếu cần ảnh thu nhỏ) |

## 1. Làm gì

- Phát hiện khi GPUI vẽ bằng **WARP** (adapter "Microsoft Basic Render Driver") hoặc đang trong **phiên RDP**
  (`GetSystemMetrics(SM_REMOTESESSION)`) ⇒ bật chế độ nhẹ.
- Tái hiện trước khi sửa: spike đo overlay trên WARP ngốn ~9 nhân CPU khi kéo (23–29 s CPU cho 1,75 s kéo — báo cáo
  `materiant/docs/spikes/ui-foundation.md` mục 4b); ép WARP bằng bản vá `materiant/spikes/ui-foundation/vendor/gpui-pre-windows`
  (`GPUI_FORCE_WARP=1`).
- Thử theo thứ tự rẻ → đắt, dừng ở cách đầu tiên đạt mục 5: (a) chỉ vẽ lại khi vùng chọn đổi, gộp mouse-move theo khung;
  (b) lớp tối + ảnh nền vẽ một lần thành texture, mỗi khung chỉ vẽ viền + nhãn; (c) giảm độ phân giải ảnh nền trong khi
  kéo, vẽ lại nét khi nhả.
- Ghi số đo từng cách vào mục 9.

## 2. Không làm trong task này

- Renderer CPU riêng ngoài GPUI — nếu (a)–(c) không đạt thì dừng, ghi đề xuất, hỏi chủ dự án.

## 5. Đo

CPU (tổng thời gian CPU của tiến trình) khi kéo 2 s trên WARP và trên RDP thật: mục tiêu ≤ 1 nhân trung bình; GPU thật
không tệ hơn gd1_02.

## 6. Nghiệm thu

- WARP ép: kéo chọn mượt (không trễ quá 1 khung so với con trỏ), CPU đạt mục 5.
- `[owner-qa]`: RDP vào máy nhà từ máy khác, chụp vùng dùng được.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
