# gd4_11 — macOS: UI, overlay, chụp màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ 31/10/2026 — chờ kiểm tay (quyền, chụp thật, hai màn) |
| Máy | Mac. Máy nhà không biên dịch chéo được `fastcast-ui`: `gpui-pre-apple` chỉ dựng shader Metal trên Mac (đã thử 30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~500 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-3, F-3, F-4 |
| Phụ thuộc mới | `objc2-*` (MIT, khối macOS của `crates/ui/Cargo.toml`, `crates/capture/Cargo.toml`) |
| File đụng tới | + `platform/mod.rs`, `overlay/{mod,dev,picker}.rs`, `record/{frame,controls,finish}.rs`, `dev.rs`, `i18n/*`, `tests/*` · SỬA `crates/ui/src/platform/macos.rs`, `crates/capture/src/lib.rs` (nhánh macOS + báo thiếu quyền), `crates/ui/Cargo.toml`, `crates/capture/Cargo.toml`; MỚI `crates/capture/src/macos.rs` |

## 0. Bàn giao từ gd4_12 (30/10/2026)

<!-- handoff: gd4_12 -->

- **Phải khớp**: vùng gửi cho `fastcast-rec` được chia theo `video/src/macos/portable.rs::display_rect`: `Rect` của màn = `CGDisplayBounds` (điểm, gốc trên trái, không lật Y) × scale, scale = `pixelWidth / width` của `CGDisplayMode`. `capture/src/macos.rs` dùng công thức khác thì quay lệch vùng.
- **Bẫy**: hai màn khác scale đặt sát nhau có thể chồng nhau trong hệ này (màn 1728 điểm scale 2 kết thúc ở x = 3456, màn kế bắt đầu ở 1728 × 1). Nếu đổi công thức để tránh chồng, sửa cả `display_rect` + test của nó.
- **Quyền**: `fastcast-rec` thiếu quyền Screen Recording trả `CaptureLost`; UI nên chặn trước bằng `CGPreflightScreenCaptureAccess`.

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- `platform/macos.rs`: `hide` / `show`, `cursor_display`, `set_cursor_pos` (nợ gd1_09), `exclude_from_capture` (`NSWindow.sharingType`), `exit_now`.
- Quyền Screen Recording: `CGPreflightScreenCaptureAccess`; thiếu ⇒ thông báo + mở System Settings đúng trang, không chụp ảnh nền trống.
- Overlay: cửa sổ phủ thanh menu + Dock trên từng màn, pixel vật lý = điểm × `backingScaleFactor`, gốc toạ độ macOS lật trục Y (F-3: chỉ đổi ở lớp `capture` / vẽ).
- Soát trên Mac: `xcap` CoreGraphics chụp nhiều màn, font chữ chú thích `Helvetica Neue` (nợ gd2_04), chép ảnh, Cmd+S, hộp thoại lưu.

## 2. Không làm trong task này

Quay (gd4_12). `.app` (gd4_13). Sửa nhánh Windows.

## 2b. Phân vai

| Phần việc | Vai |
|---|---|
| `platform/macos.rs`, `capture/src/macos.rs`, toạ độ, test tích hợp | [opus] (FFI + hình học; không giao Sonnet) |
| Chụp thật, hộp thoại Lưu, hai màn khác scale, nhìn bằng mắt | [owner-qa] |

## 5. Đo

Overlay 2 màn, khung đầu, RAM giữ ấm so với số GĐ1 (`docs/gd1-report.md`). Kết quả ở mục 9.

## 6. Nghiệm thu

- C1 [opus-run] ✅ Bốn lệnh soát trên Mac xanh; `cargo test` 596 đạt, 0 đỏ, 4 ignored, ba lần liền không treo.
- C2 [opus-unit] ✅ `display_rect` cùng ba ca với `video`; gốc logic = gốc vật lý / scale, cả Y âm; hai màn khác scale bị đánh dấu chồng.
- C3 [opus-run] ✅ Popup + `cover_screen` (bản vá tạm, cửa sổ trong suốt): khung = 1512×982 = cả màn, gồm menu + Dock; kéo chọn, Esc chạy; không sập.
- C4 [opus-run] ✅ Thiếu quyền: `freeze` trả `is_permission_denied`, không hiện hộp thoại (`example probe`).
- C5 [owner-qa] ☐ Thiếu quyền ở app thật: thông báo + System Settings mở đúng trang.
- C6 [owner-qa] ☐ Có quyền: chụp thật, cỡ ảnh khớp `rect`, Cmd+C, Cmd+S, hộp thoại Lưu, thông báo không lọt ảnh chụp; `docs/gd1-report.md` mục 4 + `docs/gd2-report.md` mục 4 bản Cmd.
- C7 [owner-qa] ☐ Hai màn cùng scale, rồi hai màn khác scale (hiện SAI, mục 8).
- C8 ☐ Bốn lệnh trên Windows **chưa chạy** (máy này là Mac); chỉ soát bằng đọc diff.

## 8. Nợ chuyển task khác

- **Hai màn khác scale chồng nhau (lỗi thật, chưa sửa)**: Retina 1728 điểm × 2 phủ x = 0..3456, màn 1× kế bên bắt đầu ở 1728. `Layout::monitor_at` / `split` trả sai màn hoặc hai mảnh trong phần chồng ⇒ ảnh cắt lẫn hai màn. Công thức bị ghim với `video/src/macos/portable.rs::display_rect` nên không đổi một phía trong làn này: `plan/_backlog.md`.
- gd4_13: mic, xem dưới. `NSMicrophoneUsageDescription` + tên app trong danh sách quyền chỉ đúng khi có `.app`.

## 9. Bàn giao thực tế

- **Mã**: `platform/macos.rs` đủ `hide` / `show` / `exit_now` / `exclude_from_capture` / `set_cursor_pos` / `cursor_display` (đổi trạng thái cửa sổ qua hàng đợi chính, cùng lý do `ShowWindowAsync`); `capture/src/macos.rs` dựng bố cục từ CoreGraphics, kiểm quyền; `platform::{same_display, cover_bounds, window_rect, cover_screen, ask_screen_access}`.
- **Khác spec**: gốc GPUI Mac theo từng màn (`bounds().origin` luôn 0) nên `matches` cũ chỉ khớp màn chính; `WindowBounds::Fullscreen` là Space riêng nên overlay dùng `Windowed` rồi bỏ `Titled`. `xcap::Monitor::from_point` nhận điểm nên chụp theo id. Trục Y không lật: `CGDisplayBounds` đã gốc trên trái.
- **Nguyên nhân treo**: kịch bản test dùng `ctrl-c`, app trên Mac đợi Cmd ⇒ UI không gửi gì, `Connection::recv` chờ mãi, UI không thoát vì daemon giả còn nối. Sửa: kịch bản `secondary-…` (`dev::parse_key`), `tests/common` giết UI sau 180 s. Thêm: cửa sổ thử bị che không vẽ (`FASTCAST_TEST_UNSEEN`), màn giả nhân theo scale nguyên ≥ 2, ca chỉ đọc khoá thư mục trên Unix, tên socket ngắn lại, cú bấm dừng 2,6 → 6 s (exe mới mất ~3 s lần đầu).
- **Đổi đụng Windows**: `windows.rs`, `linux.rs` không đổi; mã chung giữ nguyên hành vi (`DISPLAY_LOCAL_BOUNDS` false, `xcap_sys` là đoạn cũ); `record: bar` ghi lúc đổi trạng thái thay vì lúc vẽ; test đổi `ctrl-` ⇒ `secondary-` (= Ctrl). **Bốn lệnh trên Windows chưa chạy.**
- **Đo** (M5 Pro, 1512×982 @2, release `--features dev-env`, màn giả 1080p, `footprint`; Windows GĐ1 trong ngoặc): nghỉ chưa dùng 8,0 MB (5,7); overlay mở 64 MB (50); sau khi đóng + nhả GPU 35 MB (8,5); khung đầu 56 ms, chụp màn giả 6 ms. `fastcast-ui` 11,0 MB. Chụp thật, 2 màn thật chưa đo: thiếu quyền, một màn.
- **Đã soát một phần gd2_04**: `fake_ink_text_*` xanh trên Mac, chữ vào ảnh lưu đúng chỗ, `Helvetica Neue` có sẵn. Chưa nhìn bằng mắt.
- **Quyết định Opus chọn 31/10/2026**: để lỗi hai màn khác scale, không sửa `display_rect` (chủ làn dặn giữ khớp, `video` ngoài ranh giới); không làm mục mic P2 (cần objc2-av-foundation trong UI + hộp thoại TCC không thử được trên máy đang dùng, `Info.plist` thuộc gd4_13).
- **Chờ kiểm tay**: C5, C6, C7, C8.

## 10. Đề xuất cải tiến

Bảo mật: `exclude_from_capture` có thể không còn tác dụng với ScreenCaptureKit trên macOS 15+, chưa thử (đã ghi C6). Pro: không áp.

- [ux] Hai màn khác scale cắt sai ảnh — `capture/src/macos.rs` `mixed_scale_neighbours_are_flagged_as_overlapping` — đổi hệ toạ độ ở cả `capture` + `video` + đặt cửa sổ — case MacBook + màn 1× rất phổ biến — M — P1. Backlog: đụng `video`.
- [ram] Sau overlay còn 35 MB (Windows 8,5) dù đã nhả GPU — số đo mục 9 — truy phần giữ lại (Metal, atlas, malloc zone; gd4_10 có `MallocSpaceEfficient`) — M — P2. Backlog: cần so nhiều lượt, không ảnh hưởng sau khi tự thoát.
- [ux] Thông báo thiếu quyền chỉ 2,5 s — `notice.rs` — để lâu hơn khi lỗi quyền — S — P3. Chờ C5 xem có cần không vì Settings đã mở.
