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
- **Dọn dữ liệu thử**: `%APPDATA%\fastcast` + `%LOCALAPPDATA%\fastcast` thật trên máy nhà do lượt chạy Task Scheduler
  29/10/2026 tạo — giữ dùng tiếp, hoặc xoá bằng Explorer (session Claude chỉ thấy bản ảo hoá, memory
  `msix-appdata-virtualization`).

## materiant

- Output style `terse` của quy trình xbds (D-5) — phần còn lại của T0b cũ (plan materiant trước khi tách tệp).
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
- **RAM gallery macOS** (`phys_footprint`, đã viết ở gd1_01) chưa build trên Mac — lý do: máy này không có target
  darwin. Soát ở gd1_10 hoặc lần đầu chạy gallery trên Mac.

## Workspace

- Agent riêng cho Rust (kiểu `be-builder` / `ui-builder` của xbds) — hiện run-task giao `general-purpose` + `model:
  sonnet`; viết agent khi thấy lời giao lặp lại.
- Hook `Stop` nhắc bàn giao (kiểu `tools/handoff-check.sh` của xbds) — chưa chuyển.
