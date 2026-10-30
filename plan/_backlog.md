# Backlog — việc treo không làm được trong lượt

Mỗi gạch một việc + LÝ DO chưa làm được (thiếu máy, dịch vụ trả phí, chờ quyết định — D-8: đề xuất đã xác nhận thì làm
ngay, không vào đây). Có task thì trỏ tới tệp task, đừng chép lại. `run-task` mục 5, `close-phase` mục 3 ghi thêm.

## fastcast

### GĐ0 (T0–T4 xong 29/10/2026 — chi tiết `fastcast/ROADMAP.md` mục GĐ0)

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
- **[gd1_06 · ram] UI sau khi đóng cửa sổ + nhả GPU 7,3 MB** (chưa mở cửa sổ: 4,2 MB) — soát bộ đệm glyph / font GPUI
  còn giữ; cần đo sâu trong GPUI, ngoài phạm vi launcher. Mục 10 (3).
- **[gd1_06 · ux] Dời launcher ẩn sang màn có con trỏ** bằng `SetWindowPos` thay vì dựng lại (~25 ms) — P3, làm khi có
  máy nhiều màn khác DPI để kiểm. Mục 10 (5).
- **[gd1_02 · owner-qa] Kiểm overlay tay** (C11, C12): `fst` thật, phím chụp vùng — kéo DELL 60 Hz ↔ LG 144 Hz, nhãn
  đúng cỡ vật lý, không màn đen / nháy; màn 125 % / 150 % nét 1:1 không lệch; Esc ở màn có con trỏ; Alt+F4 một màn đóng
  cả hai. Bước ở `plan/gd1_02_region-overlay.md` mục 9. Máy không có màn phụ lúc làm ⇒ chưa chạy overlay thật lần nào.
- **[gd1_02 · ux] Spawn nguội → khung đầu overlay 496–674 ms** (> 400 ms của task): cùng hướng gạch gd1_01 "khởi động
  nguội" — daemon bật sẵn UI headless; trái F-4 ("bật khi dùng") ⇒ chờ chủ dự án chọn đánh đổi RAM.
  `plan/gd1_02_region-overlay.md` mục 10.
- **[gd1_02 · ram] Headless sau lần dùng đầu 9,1–9,6 MB** (trước: 5,3) — cùng gốc với gạch `[gd1_06 · ram]` trên, cần đo
  sâu GPUI / DirectWrite (`HeapCompact` sau khi nhả GPU đã thử: không đổi). **[gd1_02 · ux] Gắn lại GPU 150–405 ms** trên
  máy nhà (gd1_01 đo 17–26 ms) — đóng băng đã chồng lên lúc gắn; đo lại lúc máy rảnh / iGPU / máy công ty. Mục 10 của
  gd1_02.
- **Dọn dữ liệu thử**: `%APPDATA%\fastcast` + `%LOCALAPPDATA%\fastcast` thật trên máy nhà do lượt chạy Task Scheduler
  29/10/2026 tạo — giữ dùng tiếp, hoặc xoá bằng Explorer (session Claude chỉ thấy bản ảo hoá, memory
  `msix-appdata-virtualization`).

## materiant

- Output style `terse` của quy trình xbds (D-5) — phần còn lại của T0b cũ (plan materiant trước khi tách tệp).
- **Kiểm tay gd1_09** (C5 — lý do: so bằng mắt với tài liệu web): `pwsh start.ps1 docs select` / `tabs` / `toast`, Ctrl+T
  sáng / tối — nhịp vạch tab, lò xo vào + trượt ra của toast, rê chuột dừng đếm, panel dropdown + typeahead. Chi tiết
  `plan/materiant-gd1_09_select-tabs-toast.md` mục 9.
- **Kiểm tay gd1_01** (C4 phần nhìn + C5): `cargo run --example gallery -- --page theme` → Ctrl+T xoay Light / Dark /
  System, bấm 4 preset, ở System bật / tắt chế độ tối Windows ⇒ gallery đổi theo; so với trang theme bản web. Chi tiết
  `plan/materiant-gd1_01_theme.md` mục 9.
- **Kiểm tay gd1_02** (C4 + C5 — lý do: kéo cửa sổ của OS và nhìn bằng mắt không giả lập được):
  `cargo run --example gallery -- --page style` → kéo thanh "Drag region" ⇒ cửa sổ đi theo (nhấp đúp phóng to, kéo lên
  mép màn hình Snap); bấm "Occluded button" ⇒ in `CLICK drag-occluded`, cửa sổ không nhích. Đè / thả các ô ripple, so
  với ripple bản web (tông sáng trên nền nhấn đậm hơn chút — đã biết); dải icon nét đều ở 100 % và 150 % DPI. Chi tiết
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9.
- **Kiểm tay gd1_06** (C4 — lý do: touchpad / bánh xe thật và độ mượt trên màn 144 Hz không giả lập được):
  `cargo run --example gallery -- --page scroll` → cuộn bằng touchpad + bánh xe ở khung đoạn văn, bảng rộng (Shift +
  bánh xe / vuốt ngang) và danh sách 10 000 dòng — phải mượt; kéo thumb danh sách tới cuối. Chi tiết
  `plan/materiant-gd1_06_scroll-list.md` mục 9.
- **Kiểm tay gd1_04** (C4 — lý do: bộ gõ Unikey / EVKey / IME tiếng Việt thật và blur ở cửa sổ active không giả lập
  được khi chạy thử nền): `pwsh start.ps1 docs input` → gõ Telex "Tiếng Việt có dấu" vào các ô chữ (không mất / nhân
  đôi ký tự), gõ Telex vào ô số (không chèn chữ); ô FPS gõ `99` rồi bấm ô khác ⇒ `60`; bấm nhãn "Display name" ⇒ con
  trỏ vào ô. Chi tiết `plan/materiant-gd1_04_input.md` mục 9.
- **Kiểm tay gd1_03** (C5 — lý do: hover thật và so bằng mắt với tài liệu web không giả lập được khi chạy thử nền):
  `cargo run --example gallery -- --page button` → rê / nhấn từng dáng × màu ở sáng / tối, so với trang button của
  materiant web; bấm chuột vào nút thì KHÔNG có vòng focus, Tab tới thì có; Space / Enter bấm được (gallery `--keys`
  không thử được — chỉ gửi KeyDown); chữ trong nút / chip `Kbd` nằm giữa. Chỗ lệch có chủ đích:
  `plan/materiant-gd1_03_button-kbd.md` mục 9.
- **Kiểm tay gd1_05** (C3 phần giảm chuyển động + C4 — lý do: không tự đổi cài đặt hệ thống, so bằng mắt với web):
  `cargo run --example gallery -- --page toggles` → so với trang checkbox / radio / switch của materiant web ở sáng /
  tối; Space / Enter bật tắt được (gallery `--keys` không thử được). Windows → Accessibility → Visual effects →
  Animation effects = Off, mở lại gallery ⇒ thumb nhảy thẳng, tick / chấm / vành sóng không chạy, không ripple.
  `plan/materiant-gd1_05_toggles.md` mục 9.
- **Kiểm tay gd1_07** (C5 bằng mắt — lý do: nhìn cảm giác thật; animation + FRAMES đã đo 30/10, ~60 fps):
  `pwsh start.ps1 docs overlay` → bấm "Open dialog", Tab tới "More options", Space mở Popover, Esc lần một đóng
  Popover, lần hai đóng Dialog, focus về "Open dialog" (tooltip của nó KHÔNG tự hiện); bốn nút góc mở Popover lật vào
  trong; nền tối Popover có viền 1 px. `plan/materiant-gd1_07_overlay.md` mục 9.
- **Kiểm tay gd1_08** (C5 bằng mắt + rê chuột thật — lý do: `gallery-run` chỉ giả lập chuột trái, không có hover OS):
  `pwsh start.ps1 docs menu` → so với trang menu của materiant web ở sáng / tối (chip phím tắt thẳng cột); rê qua Share
  / More mở sau ~150 ms; chuột phải sát góc phải dưới cửa sổ lật lên trên-trái; "40 items" cuộn bằng bánh xe.
  `plan/materiant-gd1_08_menu.md` mục 9.
- **Phím Menu / Apps** mở menu chuột phải như Shift+F10 — lý do treo: tên phím Apps trong GPUI phải bấm phím thật mới
  biết. `plan/materiant-gd1_08_menu.md` mục 10.
- **`cargo fmt --check` đỏ ở tệp của gd1_06** (`src/scroll.rs`, `src/list.rs`, `examples/gallery/pages/scroll.rs`,
  `ui-tests/tests/scroll.rs`) — lý do treo: tệp của làn khác; gd1_10 chạy `cargo fmt` một lượt khi nghiệm thu.
- **RAM gallery macOS** (`phys_footprint`, đã viết ở gd1_01) chưa build trên Mac — lý do: máy này không có target
  darwin. Soát ở gd1_10 hoặc lần đầu chạy gallery trên Mac.

## Workspace

- Agent riêng cho Rust (kiểu `be-builder` / `ui-builder` của xbds) — hiện run-task giao `general-purpose` + `model:
  sonnet`; viết agent khi thấy lời giao lặp lại.
- Hook `Stop` nhắc bàn giao (kiểu `tools/handoff-check.sh` của xbds) — chưa chuyển.
