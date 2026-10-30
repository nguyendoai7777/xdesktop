# gd0_07 — Spike GNOME Wayland (Ubuntu 26.04)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — làm trên máy công ty (Ubuntu 26.04 GNOME Wayland, nhiều màn) |
| Repo | fastcast (spike ở `fastcast/spikes/wayland/`) — có thể chạm `materiant/spikes/ui-foundation/gpui-proto` để thử overlay |
| Cỡ | M — spike |
| Phụ thuộc | — ; nên làm sớm: trả lời trước khi GĐ1 khoá thiết kế overlay |
| Quyết định áp dụng | D-3, F-3, F-4, F-5, D-2 (LGPL chỉ khi link động và phải hỏi) |
| Phụ thuộc mới | `ashpd` (MIT, portal qua D-Bus) — soát; khay: `tray-icon` backend `ksni` hay `libappindicator` (GTK, LGPL) |
| File đụng tới | `fastcast/spikes/wayland/` MỚI · `fastcast/docs/spikes/wayland.md` MỚI |

## 0. Bàn giao từ gd0_06 (30/10/2026)

<!-- handoff: gd0_06 -->

- **Đã có sẵn để dùng**: `fastcast/spikes/video/src/plan.rs` — `compose_plan` (vùng toàn cục → mảnh từng màn, khung ghép),
  `target_size`, `Pacer` thuần, không phụ thuộc OS; `pattern.rs` — hoạ tiết + mã vạch khung để đếm khung từ video đã giải mã.
- **Soát khi làm**: portal `ScreenCast` có cho biết hình học từng output không — `compose_plan` cần rect vật lý của từng màn.
  Kế hoạch Linux của video đang ghi "portal + PipeWire + GStreamer VAAPI" (`fastcast/docs/spikes/video.md` mục 8), chờ kết
  quả task này.
- **Bẫy đã gặp**: `#[path]` tới `crates/capture/src/geometry.rs` dùng lại hình học không kéo `xcap`; crate spike phải có
  `Cargo.toml` riêng trước khi chạy `cargo`, nếu không lệnh rơi lên workspace fastcast. `cargo deny` của crate ngoài workspace:
  `cargo deny --config ../../deny.toml --manifest-path Cargo.toml check licenses`.
- **Riêng tư**: chỉ quay nội dung do spike tự vẽ khi máy đang dùng thật.

## 1. Làm gì

- **Phím tắt toàn cục** qua portal `GlobalShortcuts`: đăng ký được không, hỏi quyền thế nào, đổi phím ra sao
  (`global-hotkey` hiện tại chỉ chạy X11).
- **Chụp màn** qua portal `Screenshot` / `ScreenCast`: có hỏi quyền mỗi lần không, chụp im lặng được không (token
  `restore_token`), chụp **từng màn** được không, có hình học (vị trí, scale) của từng output không.
- **Overlay toàn màn hình trên từng màn** khi không có layer-shell (GNOME không hỗ trợ): cửa sổ fullscreen theo output
  có phủ thanh trên của GNOME không, có nhảy focus không.
- **GPUI (`gpui-pre`) chạy được không** trên Wayland: chạy `materiant/spikes/ui-foundation/gpui-proto` (launcher +
  overlay), ghi lỗi.
- **Khay**: GNOME không có khay nếu thiếu extension AppIndicator (Ubuntu có sẵn) — thử `tray-icon` với `ksni` (thuần
  D-Bus) và `libappindicator` (GTK, LGPL); soát giấy phép `ksni`.
- **Daemon**: vòng sự kiện Linux cho `fst` (hiện `platform/other.rs` trả lỗi) — chọn cách (calloop / glib / thread +
  channel) theo kết quả phím tắt + khay.
- Autostart: kiểm file `.desktop` do `fst autostart on` ghi (`X-GNOME-Autostart-Delay`) — khởi động lại máy.

## 2. Không làm trong task này

- Không làm xong daemon Linux — chỉ chọn hướng và ước lượng.
- Không X11 (Ubuntu 26.04 mặc định Wayland).

## 5. Đo

RAM `fst` trên Linux nếu chạy được (mục tiêu ≤ 5 MB như Windows); thời gian chụp từng màn qua portal.

## 6. Nghiệm thu

Báo cáo `fastcast/docs/spikes/wayland.md`: bảng từng mục mục 1 — làm được / làm được có điều kiện / không — kèm thứ
phải đổi trong thiết kế (F-3 đóng băng trước, F-4 ba tiến trình, D-6 GPUI) và ước lượng công.

## 8. Nợ chuyển task khác

- Daemon Linux đầy đủ + autostart kiểm thật: gd4_14. Task này chặn `gd4_14`–`gd4_17`, phải làm trên máy Ubuntu (máy nhà không biên dịch chéo được Linux).

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
