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

## 0. Bàn giao từ gd1_01 (30/10/2026)

<!-- handoff: gd1_01 -->

- **Đã có sẵn để dùng**: `crates/ui/src/commands.rs` — gắn overlay vào nhánh `Command::CaptureRegion` của `open(command,
  cx) -> Vec<AnyWindowHandle>`: trả **mọi** handle cửa sổ overlay (mỗi màn một cái) ⇒ sổ `OpenWindows` tự đưa overlay lên
  trước khi phím tắt bấm lần hai, tự gỡ khi cửa sổ đóng. `open` đã chạy trong `app::with_gpu` (GPU chắc chắn đã gắn).
- `UiState` (global, `crates/ui/src/app.rs`): `config`, `i18n` (`state.i18n.t("…")`), `keep_warm`, `windows`. Đọc bằng
  `cx.global::<UiState>()`. Theme / cỡ chữ đã áp từ `general.*` lúc khởi động.
- GPUI đi qua `materiant::gpui_kit` (không thêm `gpui-kit` vào `Cargo.toml`); `application()` đã `.with_assets(
  materiant::icon::Assets)` + `QuitMode::Explicit` (đóng overlay cuối KHÔNG thoát tiến trình — giữ ấm).
- **Bẫy đã gặp**: UI nhả GPU sau 10 s không cửa sổ (`request_windowing(Headless)`); cửa sổ mở NGOÀI `commands::open`
  (vd sau `cx.spawn`/timer) phải bọc `app::with_gpu`, không thì GPUI báo "cannot open windows while headless".
- Thoát tiến trình chỉ qua `app::quit` — `cx.quit()` trần có thể bị gpui-pre-windows nuốt `WM_QUIT` (mục 9 gd1_01).
  Đóng overlay = `window.remove_window()`, không quit.
- Cửa sổ overlay: `WindowOptions { .., ..materiant::window::window_options() }` + `gpui_kit::open_window` (bọc `Root`).
- Chạy thử không cần daemon thật (đừng bật `fst` — đăng ký phím tắt toàn cục): `cargo run -p fastcast-ui --example
  fake_daemon -- dev` rồi `fastcast-ui --endpoint dev --command capture_region`; gõ `capture_region` vào stdin daemon giả
  để thử lệnh lặp. Thêm `--gpu-idle-secs 1` để đo overlay mở từ trạng thái đã nhả GPU.
- Worktree build cần junction `.claude/worktrees/materiant` → `materiant` (đã có; `fastcast/CLAUDE.md`).
- **Soát lại khi làm** (mục 5): khung đầu overlay ở ba trạng thái — nguội (spawn, ~300 ms khởi động GPUI có sẵn), ấm còn
  GPU, ấm đã nhả GPU (+17–26 ms gắn lại). Nhả GPU làm khung đầu chậm rõ ⇒ tăng `GPU_IDLE_DEFAULT` (`app.rs`), ghi mục 9.
  Test tích hợp mẫu đọc log exe con: `crates/ui/tests/ipc.rs`.

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
