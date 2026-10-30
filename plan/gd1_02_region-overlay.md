# gd1_02 — Overlay đóng băng + kéo chọn vùng xuyên nhiều màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay C11, C12 |
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

## 2b. Phân vai

| Phần việc | Vai |
| --- | --- |
| `overlay/selection.rs` (máy trạng thái, kẹp khe, góc theo sự kiện nhả) + test | `[opus]` |
| `overlay/mod.rs` (phiên, khớp màn xcap ↔ GPUI, đóng băng sớm, BGRA một bản, `crop`) | `[opus]` |
| `overlay/view.rs` (vẽ 1:1, lớp tối, viền bỏ cạnh nối, nhãn, chuột mức cửa sổ) | `[opus]` |
| `overlay/dev.rs` + `tests/overlay.rs` (màn giả, kịch bản sự kiện, đo RAM / CPU) | `[opus]` |
| `commands.rs`, `app.rs` (đóng băng trước khi gắn GPU, `Route::Opening`, đánh thức vòng giữ ấm) | `[opus]` |
| Kiểm tay đa màn thật, khác Hz / DPI | `[owner-qa]` |

Không giao Sonnet: task gần như toàn hình học đa màn + luồng sự kiện + vòng đời GPU (`[opus]` theo khung mục 8);
không có phần ghép component / i18n (overlay không có chữ ngoài số `W × H`).

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

## 6. Nghiệm thu — Case test

| Case | Cho / Khi / Thì | Phủ | Kết quả |
| --- | --- | --- | --- |
| C1 | Cho 2 màn so le (khe phía trên màn phải). Khi nhấn ở màn 0, di ra ngoài cửa sổ 0 (chuột bị giữ) rồi trong cửa sổ 1, nhả ở khe. Thì vùng liền mạch toàn cục, góc nhả kẹp vào màn gần nhất, nhãn = cỡ vật lý | `[opus-unit]` selection + `[opus-run]` `tests/overlay.rs` | ✅ |
| C2 | Kéo ngược hướng (4 hướng) ⇒ cùng một rect | `[opus-unit]` | ✅ |
| C3 | Kéo 0 px (nhấn – nhả cùng pixel) ⇒ không có vùng (`Idle`); lệch 1 px ⇒ 2 × 1 | `[opus-unit]` | ✅ |
| C4 | Nhả ngoài mọi màn / trong khe / nhấn ngoài desktop ⇒ kẹp; chọn được tới pixel cuối của màn (vùng gồm cả hai pixel góc) | `[opus-unit]` | ✅ |
| C5 | Windows giao nhả chuột trước lần di cuối ⇒ góc chốt theo vị trí sự kiện nhả (1400 × 750, không 1384 × 742) | `[opus-unit]` | ✅ |
| C6 | Esc / chuột phải: có vùng ⇒ bỏ vùng; chưa có ⇒ đóng MỌI cửa sổ overlay; Esc giữa lúc kéo ⇒ huỷ kéo | `[opus-unit]` + `[opus-run]` | ✅ |
| C7 | Lệnh `capture_region` lặp: đang mở ⇒ đưa lên trước; đang gắn GPU ⇒ bỏ qua; sau khi đóng ⇒ mở lại ấm | `[opus-unit]` commands + `[opus-run]` | ✅ |
| C8 | Ảnh 1:1 (lưới 40 px vật lý của màn giả), lớp tối 0,45, viền 1 px màu nhấn NGOÀI vùng, bỏ cạnh nối giữa hai màn, nhãn trên vùng / lật vào trong sát mép | `[opus-unit]` `Geometry` + `[opus-run]` ảnh PrintWindow cửa sổ của app | ✅ |
| C9 | `crop` đọc lại ảnh BGRA thành RGBA xuyên màn, khe trong suốt | `[opus-unit]` | ✅ |
| C10 | Overlay đóng ⇒ nhả ảnh: RAM về mức trước khi mở, hai vòng không tăng dần | `[opus-run]` `measure_overlay_ram_and_drag_cpu` | ✅ (mục 9) |
| C11 | Kéo vắt hai màn khác Hz (DELL 60 Hz + LG 144 Hz) ⇒ vùng liền mạch, nhãn đúng cỡ vật lý; không màn đen / nháy khi mở | `[owner-qa]` | chờ kiểm tay |
| C12 | Màn scale 125 % / 150 % ⇒ ảnh nét 1:1, không lệch vùng; Esc ở màn có con trỏ | `[owner-qa]` | chờ kiểm tay |

## 7. Ghi chú UI

Lớp tối: đen alpha 0,45. Viền vùng chọn 1 px logic màu nhấn của theme. Nhãn `W × H` góc trên trái phía ngoài vùng, lật
vào trong khi sát mép màn. Con trỏ chữ thập.

## 8. Nợ chuyển task khác

- Thanh công cụ + chỉnh vùng: gd1_03. Lưu / chép: gd1_04, gd1_05. Overlay dùng lại cho thước (gd1_08), lấy màu (gd1_09).
- **Wayland (gd0_07 chưa chạy — cần máy Ubuntu)**: API overlay khoá trên Windows. Điểm có thể vướng: (1) cửa sổ toàn
  màn theo từng output — `WindowBounds::Fullscreen` + `display_id` chưa chứng minh trên GNOME, có thể phải dùng
  `WindowKind::LayerShell` (GPUI có, feature `wayland`); (2) toạ độ toàn cục — Wayland không cho biết vị trí cửa sổ /
  con trỏ ngoài surface: khớp màn dựa vào `display.bounds()` (xdg-output) phải soát; kéo xuyên màn dựa vào "implicit
  grab" (giữ nút thì con trỏ vẫn báo về surface đã nhấn, toạ độ ngoài biên) — giống SetCapture nhưng chưa thử;
  `activate_under_cursor` (đọc `mouse_position` lúc mở) chưa có giá trị trước sự kiện đầu; (3) chụp nền — `xcap` trên
  GNOME Wayland cần portal Screenshot (hộp thoại xin quyền, chậm) ⇒ đóng băng có thể > 400 ms. Đã ghi `plan/confirm.md`.

## 9. Bàn giao thực tế

- **Quyết định trong task** (mục 4): **UI đóng băng**, không phải daemon — daemon không mang `xcap` / GPU (F-4,
  `fastcast/CLAUDE.md`). Đóng băng chạy NGAY khi nhận lệnh, trước khi (có thể) chờ gắn lại GPU: ảnh là màn lúc bấm phím.
- **Đổi so với spec**: `OverlaySession` giữ `layout` + `shots: Vec<Arc<RenderImage>>` (BGRA, đổi kênh tại chỗ) thay vì
  `frozen: Frozen` — giữ cả `Frozen` (RGBA) lẫn ảnh GPUI là hai bản (+8 MB mỗi màn 1080p). Cắt bằng
  `OverlaySession::crop` (dựa `fastcast_capture::crop_frames` mới, bọc byte GPUI không chép). `windows` là
  `Vec<AnyWindowHandle>` (`gpui_kit::open_window` trả handle của `Root`). Vùng chọn **gồm cả pixel lúc nhả** (kéo 0 → 1919
  = 1920) để chọn được tới mép màn; nhấn – nhả tại chỗ = không chọn.
- **File ngoài danh sách**: `crates/capture/src/lib.rs` (`crop_frames`), `crates/ui/src/app.rs` (sửa lỗi + GPU 60 s),
  `crates/ui/tests/{common/mod.rs, ipc.rs, overlay.rs}` (helper chung; test `ipc` thôi dùng `capture_region` vì giờ nó
  mở overlay thật), `CLAUDE.md` của fastcast.
- **Lỗi gd1_01 sửa trong task**: vòng giữ ấm lúc headless ngủ tới hết giờ giữ ấm; lệnh đến > 1 s sau khi nhả GPU thì
  sau đó GPU KHÔNG BAO GIỜ được thả lại (RAM kẹt ~16 MB thay vì ~9 MB tới khi thoát). `with_gpu` giờ đánh thức vòng qua
  kênh `keep_warm_wake`; test C10 của `ipc.rs` gửi lệnh muộn 1,5 s để lỗi không quay lại.
- **Đề xuất đã làm (D-8, trong phạm vi)**: đóng băng trước khi gắn GPU; `Route::Opening` (bấm lần hai lúc đang gắn GPU
  150–400 ms không mở bộ overlay thứ hai); cửa sổ chỉ vẽ lại khi phần của nó đổi (`Visible`); `GPU_IDLE_DEFAULT`
  10 s → 60 s (gắn lại GPU đo 150–405 ms trên GTX 1650 ⇒ overlay từ trạng thái đã nhả chậm ~3 lần; giữ thêm ~7 MB trong
  một phút) — gạch `plan/confirm.md`.
- **Số đo** (release, máy nhà Windows 10, GTX 1650, màn giả — KHÔNG chụp màn thật; chụp thật cộng ~40–50 ms theo spike):

  | Đo | Kết quả |
  | --- | --- |
  | Lệnh IPC → khung đầu cả 2 màn, UI ấm còn GPU (màn giả nhỏ / 1080p) | 32–45 ms / 57–164 ms |
  | Như trên, UI ấm đã nhả GPU (gắn lại 150–405 ms) | 228–608 ms |
  | Spawn nguội → khung đầu (gồm khởi động GPUI, nối IPC) | 496–674 ms (> 400 ms ⇒ mục 10) |
  | RAM (Task Manager) 2 màn 1080p: headless trước khi dùng / overlay mở / vừa đóng (còn GPU) / đã nhả GPU | 5,3 / 46,8–50,4 / 15,1–17,5 / 9,1–9,6 MB — hai vòng không tăng ⇒ ảnh được nhả |
  | CPU kéo ~2 s (120 lần di, cả hai cửa sổ vẽ lại) | 141–359 ms (đo kèm nhiễu PowerShell; spike 62 ms / 1 cửa sổ) |

- **Lệnh soát** (cwd = worktree, `CARGO_TARGET_DIR` riêng): `cargo build`, `cargo clippy --all-targets -- -D warnings`,
  `cargo test` (46 unit ui + 5 ipc + 2 overlay, cộng các crate khác), `cargo deny check licenses` — xanh, cả sau khi gộp
  master (gd1_06 launcher). Đo: `cargo test --release -p fastcast-ui --test overlay -- --ignored --nocapture`.
- **[opus-run]**: ảnh PrintWindow của hai cửa sổ màn giả (đã xem rồi xoá) — lưới 1:1, ngoài vùng tối còn 0,55×, viền
  `#FF1493` 1 px ngoài vùng, nhãn `741 × 261`; `foreground_unchanged=True`, không phím / chuột thật.
- **Chờ kiểm tay** (C11, C12 — `plan/_backlog.md`): `fst` thật, bấm phím chụp vùng: kéo từ DELL sang LG (và ngược
  lại), nhãn đúng cỡ vật lý, không màn đen / nháy; đổi scale màn 125 % / 150 %, ảnh nét không lệch; Esc ở màn đang có
  con trỏ; Alt+F4 một màn đóng cả hai.

## 10. Đề xuất cải tiến

- [ux] Spawn nguội → khung đầu 496–674 ms (> 400 ms) — bằng chứng mục 9 (`MEASURE fake_overlay_first_frame_ms
  cold_spawn`) — daemon bật sẵn `fastcast-ui` headless lúc khởi động / sau khi UI tự thoát (~5 MB) thay vì chờ lần bấm
  đầu — lần chụp đầu nhanh như lần sau — S — P2. Không làm: đánh đổi RAM thường trực của F-4 (chủ dự án chọn) + đụng
  daemon ⇒ `_backlog.md` + `confirm.md`.
- [ram] Sau lần mở cửa sổ đầu, RAM headless 9,1–9,6 MB thay vì 5,3 MB (không tăng thêm ở vòng sau) — đo
  `measure_overlay_ram_and_drag_cpu` — tìm cache một lần của GPUI / DirectWrite còn giữ sau khi nhả GPU, thử thả khi
  headless — ~4 MB lúc giữ ấm — M — P3. `_backlog.md`.
- [ux] Gắn lại GPU 150–405 ms trên máy này (gd1_01 đo 17–26 ms) — log `gpu attached in` — đo lại khi máy rảnh, trên
  iGPU / máy công ty; vẫn chậm thì gắn GPU song song với đóng băng (luồng nền) — 40–50 ms lúc headless — S — P3.
  `_backlog.md`.
- [bảo mật] Không áp: ảnh đóng băng chỉ ở RAM, nhả khi đóng (C10), log chỉ có toạ độ vùng. Biến dev
  `FASTCAST_OVERLAY_FAKE` / `_SCRIPT` có cả trong bản release (để đo RAM bản release) — chỉ tiến trình cùng người dùng đặt
  được biến môi trường, tức đã chạy được mã ⇒ không mở thêm bề mặt.
- [pro] Không thêm: chụp hẹn giờ / nhiều vùng / chụp cuộn hợp huy hiệu Pro nhưng chưa có tính năng nào để đặt chỗ —
  ghi khi lên kế hoạch GĐ4.
