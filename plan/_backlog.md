# Backlog — việc treo không làm được trong lượt

Mỗi gạch một việc + LÝ DO chưa làm được (thiếu máy, dịch vụ trả phí, chờ quyết định — D-8: đề xuất đã xác nhận thì làm
ngay, không vào đây). Có task thì trỏ tới tệp task, đừng chép lại. `run-task` mục 5, `close-phase` mục 3 ghi thêm.

## fastcast

- **[gd2_05 · owner-qa] Con lăn + bảng màu**: `fst` thật, chụp vùng, chọn công cụ. Lăn con lăn có nấc + vuốt touchpad: mỗi nấc đổi một bước, nhãn `N px` gần con trỏ, không nhảy loạn; lăn giữa lúc kéo; lăn lúc đang gõ chữ có Unikey (con trỏ + IME không mất). Bảng màu (phím `c`): kéo ra ngoài ô vẫn bám, gõ hex không bật công cụ — lý do: máy dùng thật, session không chạy overlay thật, con lăn thật.

- **[gd2_04 · owner-qa] Gõ tiếng Việt vào ô chữ**: chạy `fst` thật, chụp vùng, phím `t`, click, gõ Telex + VNI qua Unikey / EVKey: không mất / nhân đôi chữ, ô ứng viên đúng chỗ; thử cả màn scale khác 100 % + vùng vắt hai màn khác scale (chữ không đổi cỡ vật lý, ảnh lưu khớp) — lý do: máy dùng thật, session không gõ phím thật; màn giả luôn theo scale màn chính.
- **[gd2_04] Font chữ chú thích trên macOS, Ubuntu**: chưa chạy thử, kiểm ảnh lưu có đúng chữ, đúng chỗ.

- **Kiểm tay GĐ1 — MỘT danh sách, theo thứ tự chạy: `fastcast/docs/gd1-report.md` mục 4** (gom mọi gạch `owner-qa` / "Kiểm tay" gd1_01 → gd1_10, T3 autostart, khác DPI, độ trễ phím thật, RDP, nền mờ, dán thật) — lý do: máy dùng thật, session không chạy overlay / phím thật. Tiêu chí 2 màn khác Hz, khác scale: **chưa xác nhận**. Xong ⇒ `close-phase` GĐ1, các gạch kiểm tay dưới đây xoá theo.
- **[gd1_11 · ux] GPUI ghi ERROR `Invalid window handle. (0x80070578)` mỗi lần đóng overlay**: làm rối `ui.log`, khả nghi `gpui-pre-windows` `window.rs:627` — lý do treo: chưa kiểm gốc, phải vá crate ngoài, không ảnh hưởng hành vi (P3). `plan/gd1_11_acceptance.md` mục 10.
- **Kiểm tay gd1_09 (C14 — `plan/gd1_09_color-picker.md` mục 6)**: trên màn HDR và màn scale 125 / 150 %, Ctrl+Shift+3 (hoặc launcher "Lấy màu"): kính lúp hiện cạnh con trỏ, mũi tên dời con trỏ thật đúng 1 px, kính lúp sang màn kia khi di chuột; Enter chép, dán ra so với màu thật — lý do: máy dùng thật không chạy overlay thật; màu HDR phụ thuộc cách `xcap` chụp, chưa kiểm.
- **`set_cursor_pos` macOS / Ubuntu (gd1_09)**: mũi tên chưa kéo con trỏ thật — lý do: chưa có máy, làm cùng GĐ4.
- **[gd1_08 · owner-qa] Kiểm thước tay (C6)**: `fst` thật → Ctrl+Shift+2 → đo một nút trên trang web đã biết cỡ CSS ⇒ phần `@` khớp; có màn khác DPI: trục sang đúng màn, vắt hai màn thì không có `@`; Ctrl+C rồi dán ra `W×H` — lý do: máy dùng thật, chỉ chạy màn giả cùng scale. `plan/gd1_08_ruler.md`.
- **[gd1_08 · ux] Gợi ý trước lần đo đầu, nhãn thước theo cỡ chữ lớn**: mục 10 (4), (5) của gd1_08 — lý do: (4) chờ chủ dự án xem tay, (5) chờ Settings → Cỡ chữ (GĐ4).
- **Kiểm tay gd1_10 (C7 — `plan/gd1_10_light-overlay.md` mục 6)**: RDP vào máy nhà từ máy khác, bấm chụp vùng; log có `overlay: render mode Light (… remote=true)`, kéo chọn dùng được, vùng sáng nét, lưu / chép đúng; xem thêm màn 1440p / 4K nếu có — lý do: không giả lập được RDP, cũng không đo được màn lớn hơn màn thật.
- **Icon app cho exe / khay / bản cài** (icon đã chốt 30/10/2026 — `fastcast/assets/icon/app-icon.svg`, bản đầy đủ có
  nền ô + gradient; launcher đã dùng bản chỉ hình ở `crates/ui/assets/app-icon.svg`): chưa xuất `.ico` (16–256 px) /
  `.png` và nhúng vào exe (`winres` / `.rc`) + icon khay (`tray-icon`) — lý do: lượt materiant-gd1_11 chỉ thay icon
  launcher, không sửa daemon / khay (session điều phối dặn); chọn công cụ xuất ico + soát giấy phép crate nhúng resource
  là việc riêng.

- **Kiểm tay gd1_05** (`plan/gd1_05_clipboard.md` C11): overlay thật, Ctrl+C / Enter / nút Chép → dán vào Paint / Word / trình
  duyệt (đúng ảnh, đúng cỡ); đợi UI thoát rồi dán lại; thông báo hiện ở màn có con trỏ, không lấy focus — lý do: máy dùng thật,
  session chỉ chạy màn giả.
- **Clipboard Linux Wayland** (gd1_05): bật `wayland-data-control` của `arboard` + thử trên GNOME, soát `cargo deny` — lý do:
  không có máy Ubuntu trong lượt.
- **Không lưu ảnh chụp vào lịch sử Win+V** (gd1_05 mục 10): tuỳ chọn dùng `exclude_from_history` của `arboard` — lý do: chờ màn
  Settings (GĐ4).

### GĐ0 (T0–T4 xong 29/10/2026 — chi tiết `fastcast/ROADMAP.md` mục GĐ0)

- **[gd0_06 · owner-qa] Quay màn thật** — lý do: máy dùng thật, session không quay màn của chủ dự án; đường `--rect` mới
  biên dịch + test hàm thuần, chưa chạy lần nào. Các lệnh dưới **quay màn thật**, xem xong xoá tệp. Build
  (`cargo build --release --manifest-path fastcast/spikes/video/Cargo.toml`), exe ở `fastcast/spikes/video/target/release/`:
  1. `video-spike --monitors` — lấy toạ độ màn.
  2. `video-spike --rect 100,100,1280,720 --secs 10 a.mp4`, rồi `--backend dxgi` — đúng vùng? có con trỏ? viền vàng?
  3. Vùng vắt hai màn: `--rect <x cách ranh màn 640 px>,100,1280,720 --secs 10 b.mp4` trên DELL 60 Hz + LG 144 Hz.
  4. `--rect 100,100,1280,720 --secs 60 c.mp4` trên từng màn: dòng `MEASURE` (`skipped_slots`, CPU, RAM), `--verify c.mp4`.
  5. Mở tệp bằng Media Player, QuickTime (Mac), trình duyệt; chữ có đọc được không. Thử cửa sổ có DRM: hiện đen?
  Kết quả ghi `fastcast/docs/spikes/video.md` mục 6 + chọn WGC / DXGI ở `plan/confirm.md` trước GĐ3.
- **[gd3_05 · owner-qa] DXGI + con trỏ tự vẽ qua `source::open`** — lý do: máy dùng thật, session không quay màn của chủ dự án; `for_monitor` và `DxgiSource` mới biên dịch + test phần thuần, spike chưa có con trỏ DXGI nên bước trên không phủ. Sau gd3_06, quay màn thật bằng `fastcast-rec` với `FASTCAST_REC_BACKEND=dxgi`, xem xong xoá tệp: đúng vùng, con trỏ đúng chỗ + đúng cỡ trên từng màn, không để lại vết khi rê, chữ I-beam đảo màu, không viền vàng; log không có `dxgi unavailable`. Đổi độ phân giải giữa lúc quay ⇒ `DisplayChanged`. Không nhận viền vàng WGC ⇒ đổi mặc định ở `parse_backend`.
- **[gd3_05 · bảo mật] `FASTCAST_REC_WINDOW` có hiệu lực ở bản release** — lý do: gd3_06, gd3_13 cần để đo; gd3_13 đo xong xử lý cùng đề xuất `exe_path` của gd3_01.
- **[gd0_06] Test `fake_overlay_drag_across_monitors_then_close_and_reopen` đỏ một lần** (`fastcast-ui still running`, quá
  hạn, master 7e29ba5, máy bận): chưa rõ do tải hay lỗi thật, ngoài phạm vi spike — chạy lại `cargo test -p fastcast-ui --test
  overlay` lúc máy rảnh.

- **Kiểm T3 thật**: `fst autostart on` → khởi động lại máy → daemon lên sau ~12 s, logon không chậm →
  `fst status | Out-Host`. Gộp vào gd1_11 nếu chưa làm trước.
- **Khác DPI chạy thật**: đặt một màn 125 % / 150 % → `cargo run -p fastcast-capture --example probe --release`
  (cùng lượt gd1_02).
- **Khay trên Linux**: `tray-icon` đang `default-features = false` ⇒ chưa có backend Linux. Chọn `ksni` (D-Bus thuần, soát
  giấy phép) hay `libappindicator` (GTK, LGPL — phải hỏi) — gd0_07.
- **Daemon macOS / Linux**: `crates/daemon/src/platform/other.rs` trả lỗi — vòng sự kiện macOS (NSApplication) + Linux
  (sau gd0_07). Autostart macOS (`SMAppService`) cùng bản cài GĐ4.
- **[gd1_01 · bảo mật] Pipe IPC giả mạo được**: tạo pipe `fastcast-<user>` với `FILE_FLAG_FIRST_PIPE_INSTANCE` + DACL
  chỉ người dùng hiện tại; UI / CLI kiểm `GetNamedPipeServerProcessId` là `fst` — chưa làm vì phải chạy daemon thật để
  kiểm + đo RAM daemon, mà bật `fst` thật là đăng ký phím tắt toàn cục trên máy khi chủ dự án vắng. Chi tiết:
  `plan/gd1_01_ui-process.md` mục 10.
- **[gd1_01 · ux] Khởi động nguội UI ~300 ms**: đo từng bước khởi động GPUI, hoặc daemon bật sẵn UI headless (~4,2 MB)
  sau đăng nhập — chờ chủ dự án chọn đánh đổi RAM. `plan/gd1_01_ui-process.md` mục 10.
- **[gd1_01 · owner-qa] Kiểm UI cùng daemon thật**: `fst run capture_region` → `ui.log` có `run capture_region`; để
  yên > 10 s, Task Manager `fastcast-ui` ~4 MB; hết `keepWarmMins` tiến trình biến mất; `fst quit` ⇒ UI tắt theo.
- **[gd1_06 · ux] Launcher sau khi nhả GPU ~200 ms** (bản dựng sẵn 0,2 ms): giữ GPU / launcher ẩn lâu hơn khi launcher
  vừa dùng, hoặc tăng `GPU_IDLE_DEFAULT` — chờ chủ dự án chọn đánh đổi RAM giữ ấm 7,3 ⇒ 14,2 MB; gd1_02 (song song) cũng
  đo khung đầu overlay sau nhả GPU trên cùng hằng số. `plan/gd1_06_launcher.md` mục 10 (1). → gd1_02 đã tăng
  `GPU_IDLE_DEFAULT` 10 → 60 s (gạch `confirm.md`); gd1_06 thêm sàn riêng `launcher::HOLD_AFTER_USE` = 60 s (master
  `6503d28`). Còn treo chỉ khi chủ dự án muốn đánh đổi khác.
- **[gd1_06 · owner-qa] Kiểm launcher tay** (C7): Alt+Space thật, Telex, bấm ra ngoài, kéo sang màn khác + mở lại, sáng
  / tối, vi / en, không chớp nội dung cũ, Alt+Space không bật menu app đang dùng — bước ở `plan/gd1_06_launcher.md`
  mục 9; lỗi chớp / Alt thì làm đề xuất 4 / 2 của mục 10.
- **[gd1_11 · ram] UI giữ ấm sau khi dùng overlay 8,3–8,9 MB** (chưa dùng 5,7–5,8; launcher 5,6–5,9 — số 7,3 MB cũ của gd1_06 và 9–13 MB của gd1_02 / gd1_10 là đọc lúc bộ nhớ đang được trả, `fastcast/docs/gd1-report.md` mục 3): ~3 MB còn lại, cần đo sâu GPUI / DirectWrite; P3, chưa làm vì không tăng theo số lần mở.
- **[gd1_06 · ux] Dời launcher ẩn sang màn có con trỏ** bằng `SetWindowPos` thay vì dựng lại (~25 ms) — P3, làm khi có
  máy nhiều màn khác DPI để kiểm. Mục 10 (5).
- **[gd1_02 · owner-qa] Kiểm overlay tay** (C11, C12): `fst` thật, phím chụp vùng — kéo DELL 60 Hz ↔ LG 144 Hz, nhãn
  đúng cỡ vật lý, không màn đen / nháy; màn 125 % / 150 % nét 1:1 không lệch; Esc ở màn có con trỏ; Alt+F4 một màn đóng
  cả hai. Bước ở `plan/gd1_02_region-overlay.md` mục 9. Máy không có màn phụ lúc làm ⇒ chưa chạy overlay thật lần nào.
- **[gd1_03 · owner-qa] Kiểm chỉnh vùng tay** (C9): màn thật nhiều DPI — rê tay nắm thấy con trỏ đổi cỡ đúng hướng, kéo
  cạnh vắt hai màn khác scale bám con trỏ, Tab / Enter / Space trên thanh công cụ, tooltip có phím tắt, Alt + mũi tên
  không bật menu hệ thống, sáng / tối. Bước ở `plan/gd1_03_selection-edit.md` mục 9.
- **[gd1_03 · ux] Thân vùng chọn không có con trỏ "dời" trên Windows**: `gpui-pre-windows` (`util.rs`) map `OpenHand` /
  `ClosedHand` về `IDC_ARROW`, không có `IDC_SIZEALL` — lý do treo: phải vá crate ngoài (upstream) hoặc đặt con trỏ Win32
  riêng qua `platform` — M, P3.
- **[gd1_02 · ux] Spawn nguội → khung đầu overlay 496–674 ms** (> 400 ms của task): cùng hướng gạch gd1_01 "khởi động
  nguội" — daemon bật sẵn UI headless; trái F-4 ("bật khi dùng") ⇒ chờ chủ dự án chọn đánh đổi RAM.
  `plan/gd1_02_region-overlay.md` mục 10.
- **[gd1_02 · ux] Gắn lại GPU 150–405 ms** trên
  máy nhà (gd1_01 đo 17–26 ms) — đóng băng đã chồng lên lúc gắn; đo lại lúc máy rảnh / iGPU / máy công ty. Mục 10 của
  gd1_02.
- **[gd1_07 · owner-qa] Gán phím thật (C7)**: bật `fst` thật → Alt+Space → Chụp vùng → Ctrl+K → Gán phím tắt… →
  Ctrl+Shift+2 (của Thước căn; lúc ghi KHÔNG mở Thước căn) → Enter → "Lấy phím" ⇒ Ctrl+Shift+2 mở Chụp vùng; tổ hợp app
  khác giữ ⇒ báo + Quay lại; giết `fastcast-ui` lúc đang ghi ⇒ phím tắt chạy lại ngay. `plan/gd1_07_hotkey-assign.md` mục 9.
- **[gd1_07 · ux] PrintScreen không ghi được từ launcher trên Windows** (GPUI không báo `VK_SNAPSHOT`): subclass HWND
  launcher bắt `WM_KEYUP VK_SNAPSHOT` khi đang ghi — chưa làm vì cần bấm phím thật để kiểm (Win11 có thể giữ PrtSc cho
  Snipping). Mục 10 (1) của gd1_07.
- **[gd1_07 · ux] Menu Ctrl+K mở giữa launcher** — materiant `ContextMenuExt` nhận điểm mở bằng phím (góc dưới phải như
  Raycast); chờ materiant mở lại sau nghiệm thu gd1_10. Mục 10 (2).
- **Dọn dữ liệu thử**: `%APPDATA%\fastcast` + `%LOCALAPPDATA%\fastcast` thật trên máy nhà do lượt chạy Task Scheduler
  29/10/2026 tạo — giữ dùng tiếp, hoặc xoá bằng Explorer (session Claude chỉ thấy bản ảo hoá, memory
  `msix-appdata-virtualization`).

- **Kiểm tay gd1_04 (C8, C9 — `plan/gd1_04_save-image.md` mục 6)**: Lưu thành… trên overlay thật (hộp thoại phải nổi trên overlay, huỷ thì về overlay, phím vẫn nhận); bấm thông báo "Đã lưu" mở Explorer đúng tệp, ✕ chỉ đóng, rê chuột dừng đếm giờ — lý do: máy dùng thật, session không chạy overlay thật / không mở Explorer.
- **Chỉnh `save.imageDir` trong Settings** (F-8 ghi "chỉnh được", gd1_04 mục 10): hiện chỉ sửa tay `config.json` — lý do: Settings thuộc GĐ4, chưa có.

- **[gd3_04] Windows N**: có thể `fastcast-rec.exe` không bật nổi thay vì báo `NoEncoder` (exe nhập trực tiếp từ `mfplat.dll`; suy từ cách crate `windows` liên kết, chưa kiểm) — lý do: không có máy Windows N. Khi có máy: thử; nếu đúng thì gd3_11 coi "bật exe lỗi" như `NoEncoder`, hoặc nạp trễ DLL.
- **[gd3_04] Vùng siêu dài**: 8000 × 720 mã hoá xong nhưng Media Foundation không giải mã lại được (`0xC00D36B4`), 5120 × 720 thì được; ngưỡng chưa dò, chưa thử trình phát khác — lý do: P3, chỉ gặp khi vắt 3–4 màn với vùng thấp, ưu tiên sau các làn GĐ3.
- **[gd3_04 → gd3_13] RAM quay 720p30**: 44–53 MB, cao hơn spike 29,6 MB, chưa rõ nguồn; tăng chậm ~1,1 MB / phút — lý do: phải đo lúc máy rảnh, hiện các làn khác đang build. gd3_13 đo lại, vẫn trên 35 MB thì soi (`plan/gd3_04_video-encoder.md` mục 9).

## materiant

- Output style `terse` của quy trình xbds (D-5) — phần còn lại của T0b cũ (plan materiant trước khi tách tệp).

### GĐ1 — port component (đóng 30/10/2026, `completed/materiant/gd1/`)

- **Kiểm tay GĐ1 — một lượt** (lý do: nhìn bằng mắt / so web, hover + kéo cửa sổ thật của OS, bộ gõ Unikey / EVKey,
  touchpad + màn 144 Hz, nền mờ thật phía sau, FRAMES khi bật Animation effects — không giả lập được khi chạy thử nền):
  bảng 14 dòng có lệnh từng mục ở `materiant/docs/gd1-report.md` mục 6 (gom C4 / C5 của gd1_01 → gd1_09, C8 gd1_11, C1
  phần tay của gd1_10, phím Menu / Apps của gd1_08). Kết quả báo lại / ghi vào đây.
- **macOS / Ubuntu GĐ1** (gd1_10 C3 — lý do: máy này không có Mac / Ubuntu, không target darwin): gallery + launcher +
  `cargo test`, nhãn RAM `phys_footprint` / `RssAnon` chưa build lần nào — lệnh + chỗ dễ vỡ ở
  `materiant/docs/gd1-report.md` mục 5.
- **Task dọn nợ GĐ1 → GĐ2** (lý do: chạm ~10 module, vượt cỡ S của gd1_10 — tách task khi mở GĐ2): dời hằng cục bộ lên
  `style.rs` / `icon.rs` + `optical_lift` thành helper chung; Select neo bằng Popover lật cạnh; `ToastViewport` / Dialog
  mở bằng code qua `RootPlugin`; `ScrollbarMotion` 1 s + fade; `FieldShell` tách nhãn; `FieldSize::Lg`; vòng focus switch
  nền tối ~1,3:1. Danh sách + nguồn: `materiant/docs/gd1-report.md` mục 7.
- **[gd1_10 · ux] `start.ps1 launcher`** cho chủ dự án mở launcher example như `docs` (lý do: `start.ps1` / `start.sh`
  ở repo gốc ngoài phạm vi tệp của gd1_10). `completed/materiant/gd1/materiant-gd1_10_acceptance.md` mục 10 (2).
- **[gd1_10 · ram] Trang gallery `button` 24,1 MB** (các trang khác 14–18) — đo phần nào tốn (bóng `elevated`, glyph)
  trước khi fastcast dùng nhiều bóng; lý do treo: không chặn, P3. Mục 10 (3).

## Workspace

- Agent riêng cho Rust (kiểu `be-builder` / `ui-builder` của xbds) — hiện run-task giao `general-purpose` + `model:
  sonnet`; viết agent khi thấy lời giao lặp lại.
- Hook `Stop` nhắc bàn giao (kiểu `tools/handoff-check.sh` của xbds) — chưa chuyển.
