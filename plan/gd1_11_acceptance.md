# gd1_11 — Nghiệm thu GĐ1 (Windows)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — đo + báo cáo, sửa lỗi nhỏ phát hiện được |
| Phụ thuộc | gd1_01 → gd1_10 |
| Quyết định áp dụng | F-1 → F-5, F-8, D-3 |
| Phụ thuộc mới | — |
| File đụng tới | `fastcast/docs/gd1-report.md` MỚI · `fastcast/ROADMAP.md` SỬA (mục bàn giao GĐ1) |

## 0. Bàn giao từ gd1_10 (30/10/2026)

<!-- handoff: gd1_10 -->

- **Đã có sẵn để dùng**: `overlay/render_mode.rs`; log `overlay: render mode …` cho biết adapter + chế độ; `overlay: monitor <i>
  rendered <n> times` khi đóng; `FASTCAST_OVERLAY_RENDER=light|full`; `FASTCAST_OVERLAY_FAKE=1080p-offscreen`.
- **Đổi so với lúc viết spec này**: `OverlayView` không đọc phiên trong `render` (giữ `visible`); viền vùng chọn là bốn thanh
  cho cả hai chế độ. Chế độ nhẹ: nền tối nửa độ phân giải, 25 fps ở 1080p, tới 10 fps ở 4K.
- **Nợ chuyển sang đây**: gom kiểm tay RDP (`plan/gd1_10_light-overlay.md` C7) vào báo cáo; ghi số CPU 0,90 nhân là của WARP ép,
  chưa có RDP thật, chưa đo 1440p / 4K.
- **Bẫy đã gặp**: cửa sổ đủ cỡ lớn hơn màn thật có thể bị OS kẹp ⇒ số đo 4K giả không tin được. Chụp PrintWindow bằng bản
  release: bản debug mở console và giành focus.
- **Soát lại khi làm**: lệnh đo WARP ở `fastcast/CLAUDE.md`, trả lại `Cargo.lock` sau khi đo; đo lại lúc máy rảnh RAM sau khi nhả
  GPU trên GPU thật (12–13 MB so với 9,1–9,6 MB ở gd1_02, chưa truy nguyên).

## 1. Làm gì

- Chạy lại toàn bộ luồng GĐ1 trên bản release, máy nhà Windows 2 màn (DELL 60 Hz + LG 144 Hz), thêm một lượt đặt một
  màn scale 125 % hoặc 150 %.
- Bảng số đo: RAM daemon nghỉ, RAM UI giữ ấm không cửa sổ, RAM UI khi overlay mở / launcher mở; độ trễ phím tắt →
  overlay và Alt+Space → launcher (nguội / ấm); CPU khi kéo (GPU thật / WARP).
- Danh sách kiểm tay cho chủ dự án (`[owner-qa]`) gom từ mục 6 các task GĐ1, kèm bước làm.
- Kiểm `fst autostart on` + khởi động lại máy (GĐ0 T3 còn treo) cùng lượt này.

## 2. Không làm trong task này

- macOS / Ubuntu (GĐ4, sau gd0_07).

## 5. Đo

Như mục 1 — so với spike (`materiant/docs/spikes/ui-foundation.md` mục 2) và với GĐ0 (daemon 1,1 MB).

## 6. Nghiệm thu

- Báo cáo `fastcast/docs/gd1-report.md`: bảng số đo, kết quả kiểm tay, lỗi còn lại (đã ghi `plan/_backlog.md`).
- Không lỗi chặn nào ở luồng chụp → lưu / chép trên 2 màn khác Hz và khác scale.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
