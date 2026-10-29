# Backlog — việc treo, đề xuất đã chọn

Mỗi gạch một việc làm được. Có task thì trỏ tới tệp task, đừng chép lại. Skill `run-task` (mục 5) và `close-phase`
(mục 3) ghi thêm vào đây.

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
- **RAM gallery macOS** (`phys_footprint`, đã viết ở gd1_01) chưa build trên Mac — soát ở gd1_10 hoặc lần đầu chạy
  gallery trên Mac.

## Workspace

- Agent riêng cho Rust (kiểu `be-builder` / `ui-builder` của xbds) — hiện run-task giao `general-purpose` + `model:
  sonnet`; viết agent khi thấy lời giao lặp lại.
- Hook `Stop` nhắc bàn giao (kiểu `tools/handoff-check.sh` của xbds) — chưa chuyển.
