# gd0_06 — Spike quay video vùng (Windows)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast (spike ở `fastcast/spikes/video/`, ngoài cargo workspace) |
| Cỡ | M — spike, ~700 dòng vứt đi được |
| Phụ thuộc | — (độc lập) |
| Quyết định áp dụng | F-7, F-3 (vùng chọn toạ độ toàn cục vật lý), D-2 (cấm x264 / GPL) |
| Phụ thuộc mới | `windows` (MIT / Apache-2.0) với Graphics.Capture / DXGI / Media Foundation; có thể `windows-capture` (MIT) — soát |
| File đụng tới | `fastcast/spikes/video/` MỚI · `fastcast/docs/spikes/video.md` MỚI |

## 1. Làm gì

- Chụp khung của một vùng chọn (toạ độ toàn cục vật lý, `fastcast_capture::geometry::Rect`) bằng
  Windows.Graphics.Capture, hoặc DXGI Desktop Duplication — thử cả hai nếu rẻ, chọn một.
- Mã hoá H.264 bằng Media Foundation (bộ mã hoá phần cứng nếu có) ra MP4.
- Độ nét 480 / 720 = **cạnh ngắn** của vùng, giữ tỉ lệ, không phóng to (vùng nhỏ hơn thì giữ nguyên), làm tròn số chẵn —
  viết thành hàm thuần có test.
- FPS nhập 1–60, mặc định 30; nhịp khung đều khi màn 144 Hz / 60 Hz.
- Âm thanh theo Q-1 (chờ chủ dự án chốt — mặc định "Không"); nếu chốt có âm: AAC qua Media Foundation.
- Kế hoạch dự phòng OpenH264 (BSD-2, tải khi cần, giấy phép bằng sáng chế của Cisco chỉ áp khi tải binary của Cisco) —
  chỉ ghi kế hoạch, không làm.

## 2. Không làm trong task này

- Không UI quay (khung viền, nút dừng) — GĐ3. Không macOS / Linux.
- Không x264 / FFmpeg GPL.

## 4. Code

Crate spike `fastcast/spikes/video/` (`[workspace]` rỗng): `video-spike --rect x,y,w,h --fps 30 --res 720 --secs 10
out.mp4`. Vùng chọn có thể vắt qua hai màn ⇒ ghi lại cách xử lý (chụp từng màn rồi ghép, hay chỉ cho một màn).

## 5. Đo

Quay 720p30 trong 60 s: CPU trung bình (% một nhân), RAM Task Manager, cỡ file, khung rớt; thử trên màn 144 Hz và
60 Hz; thử vùng vắt hai màn.

## 6. Nghiệm thu

- Báo cáo `fastcast/docs/spikes/video.md`: số đo trên, API chọn, giới hạn (vùng vắt màn, DRM / cửa sổ được bảo vệ hiện
  đen), kế hoạch macOS (VideoToolbox) / Linux (VAAPI-GStreamer qua portal ScreenCast).
- File MP4 mở được bằng trình phát mặc định của Windows, macOS (QuickTime) và trình duyệt.
- Hàm tính độ nét có test ca biên (vùng lẻ, vùng nhỏ hơn 480, vùng dọc).

## 8. Nợ chuyển task khác

- UI quay + lưu tách ảnh / video (F-8): GĐ3.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
