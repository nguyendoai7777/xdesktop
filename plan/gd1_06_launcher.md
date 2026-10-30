# gd1_06 — Launcher kiểu Raycast

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay C7 |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd1_01 · materiant-gd1_02 (`.drag_region()`), gd1_03 (`Kbd`), gd1_04 (ô tìm), gd1_06 (danh sách) |
| Quyết định áp dụng | F-2, F-4 |
| Phụ thuộc mới | `unicode-normalization` (MIT / Apache-2.0) — đã dùng ở spike để bỏ dấu |
| File đụng tới | `crates/ui/src/launcher/mod.rs` MỚI · `crates/ui/src/launcher/filter.rs` MỚI · `crates/ui/src/launcher/view.rs` MỚI · `crates/ui/src/commands.rs` SỬA · `crates/core/src/config.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 1. Làm gì

- `open_launcher` (Alt+Space mặc định, bấm icon khay) ⇒ cửa sổ không viền 760 × 492 logic, giữa màn có con trỏ (lần
  đầu) hoặc vị trí đã nhớ.
- Ô tìm + danh sách mọi lệnh (`Command::ALL` trừ chính nó): tên i18n, mô tả ngắn, chip phím tắt hiện tại (`Kbd`), lệnh
  chưa gán phím thì không chip.
- Lọc không dấu, không phân biệt hoa thường ("thuoc" ⇒ "Thước căn"), xếp: khớp đầu từ > khớp giữa; khớp cả tên tiếng Anh
  của lệnh.
- ↑ ↓ chọn, Enter chạy (ẩn launcher rồi chạy lệnh), Esc ẩn — bắt ở **pha capture** (ô nhập nuốt phím, bẫy đã gặp).
- Mất focus ⇒ ẩn. Kéo bằng thanh trên (ô nhập `occlude` để đặt con trỏ chữ, không kéo). Nhớ vị trí kéo tới.
- **Dựng sẵn ẩn** khi UI khởi động (`Window::set_visible`) ⇒ mở lại tức thì khi UI đang ấm.
- `filter.rs`: bỏ dấu + chấm điểm — hàm thuần, test đơn vị.

## 2. Không làm trong task này

- Ctrl+K gán phím: gd1_07. Lịch sử ảnh / lệnh gần đây.

## 2b. Phân vai

| Phần việc | Ai | File |
| --- | --- | --- |
| Vòng đời cửa sổ launcher: dựng sẵn ẩn, ẩn / hiện (Win32 `ShowWindow`), mất focus ⇒ ẩn, nhả cùng GPU, chạy lệnh sau khi ẩn | [opus] | `crates/ui/src/launcher/mod.rs`, `crates/ui/src/platform.rs` MỚI, `crates/ui/src/app.rs` SỬA (đếm cửa sổ đang hiện, nhả launcher ẩn trước khi nhả GPU), `crates/ui/src/commands.rs` SỬA (nhánh `OpenLauncher`), `crates/ui/src/main.rs` SỬA (`--background`) |
| Vị trí đa màn (hàm thuần `place`), lưu `launcher.position` | [opus] | `crates/ui/src/launcher/mod.rs` |
| Lọc bỏ dấu + chấm điểm | [opus] | `crates/ui/src/launcher/filter.rs` |
| View: ô tìm `TextField`, `VirtualList`, chip `Kbd`, chân; phím ở pha capture | [opus] | `crates/ui/src/launcher/view.rs` |
| Khoá `launcher` trong `config.json` + test | [sonnet] | `crates/core/src/config.rs` |
| Catalog `launcher.*`, `command_desc.*` | [sonnet] | `i18n/vi.toml`, `i18n/en.toml` |
| Kiểm tay | [owner-qa] | — |

## 3. Kiểu dữ liệu · IPC · cấu hình

`config.json` thêm `launcher: { position: { monitorId, x, y } | null }` — toạ độ logic trên màn `monitorId`; màn không
còn ⇒ về giữa màn có con trỏ.

## 4. Code

Mẫu đã chạy: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` — `Launcher`, `fold`, `kbd`, `launcher_options`,
`window_control_area(Drag)` + `occlude`. Chuyển sang component `materiant` thay `div` tự dựng.

## 5. Đo

Alt+Space → khung đầu: UI nguội / ấm (spike: launcher 15,7 MB Task Manager). RAM khi launcher hiện.

## 6. Nghiệm thu

- **C1** `[opus-unit]` Cho catalog vi. Khi lọc "chup", "mau", "thuoc", "ruler" (tên tiếng Anh), "CHỤP" ⇒ Thì mục đầu
  lần lượt là `capture_region`, `color_picker`, `ruler`, `ruler`, `capture_region`; khớp đầu từ đứng trước khớp giữa
  từ; chuỗi rỗng ⇒ đủ lệnh theo thứ tự `Command::ALL` (trừ `open_launcher`).
- **C2** `[opus-unit]` Cho vị trí đã nhớ trên màn còn cắm ⇒ mở đúng chỗ (toạ độ logic của màn đó); màn không còn ⇒
  giữa màn có con trỏ; vị trí lòi ra ngoài (màn đổi độ phân giải) ⇒ kẹp vào vùng làm việc của màn.
- **C3** `[opus-unit]` (`#[gpui::test]`) Cho launcher mở, con trỏ chữ trong ô tìm. Khi gõ "thuoc" ⇒ Thì danh sách còn
  `ruler`, chọn mục 0; ↓ ↑ đổi mục chọn; Enter ⇒ phát `Run(lệnh đang chọn)`; Esc ⇒ phát `Hide`.
- **C4** `[opus-unit]` (`#[gpui::test]`) Cho đã gõ chữ + chọn mục 2. Khi `reset` (mỗi lần hiện lại) ⇒ Thì ô tìm rỗng,
  mục đầu được chọn.
- **C5** `[sonnet-test]` `config.json` cũ không có `launcher` ⇒ đọc được, `position = null`; ghi rồi đọc lại giữ
  `{ monitorId, x, y }` đúng khoá camelCase.
- **C6** `[opus-run]` exe release + `fake_daemon`, `--background` (không giành focus, mở ở màn phụ): `open_launcher`
  lần đầu / lần hai (đã dựng sẵn) / sau khi nhả GPU — log khung đầu + RAM Task Manager lúc hiện, lúc ẩn, sau khi nhả.
- **C7** `[owner-qa]` Alt+Space thật: bấm ra ngoài ⇒ ẩn; mở lại ⇒ ô rỗng, mục đầu chọn; kéo sang màn khác, đóng UI,
  mở lại ⇒ đúng chỗ cũ; gõ Unikey / EVKey (Telex) trong ô tìm; sáng / tối; vi / en.

## 7. Ghi chú UI

```
┌──────────────────────────────────────────────┐  ← thanh trên kéo được
│ 🔍  Tìm lệnh…                                 │
├──────────────────────────────────────────────┤
│ ▣ Chụp vùng          Chọn vùng màn hình  ⌃⇧1 │  ← mục chọn: nền nhấn nhạt
│ ▣ Thước căn          Đo khoảng cách px   ⌃⇧2 │
│ …                                            │
├──────────────────────────────────────────────┤
│ ↵ Chạy    ⌃K Hành động                   Esc │  ← chân
└──────────────────────────────────────────────┘
```

Khoá i18n: `launcher.search`, `launcher.run`, `launcher.actions`, `command_desc.<id>` cho mỗi lệnh.

## 8. Nợ chuyển task khác

- Ctrl+K: gd1_07 — kèm hiện "Hành động Ctrl K" ở chân (khoá `launcher.actions` đã có, chưa vẽ).

## 9. Bàn giao thực tế

Xong 30/10/2026 — fastcast `claude/gd1_06` (3 commit + merge master). Chủ dự án vắng ⇒ các lựa chọn thay chủ dự án ghi
ở `plan/confirm.md` mục fastcast (`[gd1_06]`).

- **Code** (`crates/ui/src/`): `launcher/filter.rs` — `fold` (NFD bỏ dấu, `đ` ⇒ `d`, chữ thường), `Haystack`, `rank`
  (đầu tên > đầu từ của tên > giữa từ của tên > đầu từ của mô tả; xét cả tên tiếng Anh; cùng bậc giữ thứ tự
  `Command::ALL`). `launcher/view.rs` — `LauncherView` (`TextField` + `VirtualList` + `Kbd`), `Entry`, `Texts`,
  `LauncherEvent::{Run, Hide}`, `hotkey_label` (`Meta` ⇒ Win / Super, macOS ⌘). `launcher/mod.rs` — global `Launcher`:
  `init`, `toggle`, `prebuild`, `hidden_window`, `discard_hidden`, `window_closed`; hàm thuần `place` (đa màn).
  `platform.rs` — `hide` / `show` (`ShowWindowAsync`), `cursor_display` (`GetCursorPos` + `MonitorFromPoint` —
  `DisplayId` của gpui-pre-windows chính là `HMONITOR`).
- **Ngoài danh sách tệp**: `app.rs` (launcher ẩn không tính là cửa sổ mở; nhả GPU thì đóng launcher ẩn trước; dựng sẵn
  sau lệnh khởi động), `main.rs` (`--background`: dev / chạy thử, không giành focus, ưu tiên màn phụ),
  `crates/ui/Cargo.toml`. Phụ thuộc: `unicode-normalization` 0.1 (MIT / Apache-2.0, crate mới duy nhất của bản phát
  hành); `windows-sys` 0.61 + `raw-window-handle` 0.6 (đã có trong cây); dev: `gpui` = `gpui-pre` `test-support` cho
  `#[gpui::test]` trong bin (kéo proptest… chỉ vào bản build test).
- **Lệch so với plan**: gpui-pre 0.3.10 KHÔNG có `Window::set_visible` ⇒ Win32 `ShowWindowAsync` (macOS / Linux: ẩn =
  đóng hẳn, chưa dựng sẵn). Không dời được cửa sổ ẩn ⇒ con trỏ sang màn khác (chưa nhớ vị trí) thì dựng lại ở màn mới.
  Nhấp một dòng = chọn, nhấp đúp / Enter = chạy; `open_launcher` khi đang hiện ⇒ ẩn.
- **Cấu hình**: `config.json` → `launcher: { position: { monitorId, x, y } | null }` (`LauncherPrefs`,
  `LauncherPosition` ở `core/src/config.rs`); `monitorId` = uuid màn của GPUI (băm từ `szDevice`), x / y = chỗ XIN đặt,
  px logic tính từ góc màn. UI ghi khoá này khi ẩn mà cửa sổ đã bị kéo (đọc lại file, ghi nguyên tử, luồng nền).
- **Bẫy đã gặp**: (1) `ShowWindow` đồng bộ gửi `WM_SHOWWINDOW` / `WM_ACTIVATE` vào wndproc của GPUI trong lúc app đang
  mượn state ⇒ log `RefCell already borrowed`, sự kiện bị bỏ ⇒ dùng `ShowWindowAsync`. (2) `Window::bounds().origin`
  của popup cao hơn chỗ xin 4 px (Windows 10) ⇒ so "đã kéo" với mốc đọc ở khung đầu, lưu chỗ xin = chỗ thật − độ lệch;
  bản đầu so với chỗ xin nên vị trí trôi 4 px mỗi lần mở. (3) `Window::window_handle()` là hàm riêng trả
  `AnyWindowHandle` — HWND phải lấy qua `HasWindowHandle::window_handle(window)`.
- **Đo** (release, máy nhà Windows 10, GTX 1650, một màn 1920 × 1080, `fake_daemon`, `--background`; RAM = cột Memory
  của Task Manager):

  | Trạng thái | Khung đầu | RAM |
  | --- | --- | --- |
  | UI nguội, `--command open_launcher` | `ui ready` 338–369 ms + cửa sổ mới 26–34 ms | 14,2–15,3 MB |
  | Ẩn (dựng sẵn, còn GPU) | — | 14,2 MB (private 72 MB) |
  | Hiện lại bản dựng sẵn | **0,2–2,6 ms** | 14,5 MB |
  | Ẩn quá `gpu-idle` ⇒ đóng launcher, nhả GPU | — | **7,3 MB** (private 38 MB, 10 luồng) |
  | Mở sau khi đã nhả GPU | gắn GPU 158–188 ms + cửa sổ mới 17–22 ms | 15,6 MB |

  Spike: launcher 15,7 MB. `foreground_unchanged=True` mọi lượt. Script chạy thử: daemon giả nhận stdin
  `open_launcher` (bật / tắt), đo `Win32_PerfRawData_PerfProc_Process.WorkingSetPrivate`.
- **Case**: C1 ✅ `launcher::filter::tests` (5). C2 ✅ `launcher::tests` (5, gồm màn rút, kẹp vùng làm việc, màn nhỏ
  hơn cửa sổ). C3, C4 ✅ `launcher::view::tests` (4 `#[gpui::test]`: gõ "thuoc" ⇒ chỉ `ruler`, Enter chạy đúng một
  lần, ↑ ↓ dừng ở biên, Esc ⇒ `Hide`, `reset`, tên tiếng Anh, rỗng, mất focus ⇒ `Hide`). C5 ✅ 3 test trong
  `core/src/config.rs` (Sonnet). C6 ✅ bảng trên. C7 `[owner-qa]` chờ kiểm tay (dưới).
- Soát xanh trên nhánh: `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test` (28 unit ui + 5 ipc +
  39 core + …), `cargo deny check licenses`, `cargo fmt --check -p fastcast-ui -p fastcast-core`.
- Chạy thử đã ghi `launcher.position` vào `%APPDATA%\fastcast\config.json` (bản Claude thấy) — đã đặt lại `null`.
- **Chờ kiểm tay** `[owner-qa]` C7: bật `fst` thật, Alt+Space (hoặc nhấp icon khay) ⇒ launcher giữa màn có con trỏ, con
  trỏ chữ trong ô tìm; gõ "chup" / "mau" / "ruler" (cả Unikey / EVKey Telex: "thước" không mất / nhân đôi chữ); ↑ ↓
  Enter; bấm ra ngoài ⇒ ẩn; Alt+Space lại ⇒ ô rỗng, mục đầu chọn, KHÔNG chớp nội dung lần trước; kéo thanh trên sang
  màn khác, Esc, `fst quit`, mở lại ⇒ đúng chỗ cũ; sáng / tối; `general.language` vi / en; Alt+Space không bật menu của
  app đang dùng (GPUI giả lập phím Alt để giành foreground — mục 10).

## 10. Đề xuất cải tiến

Chủ dự án vắng ⇒ Claude tự chọn: làm 6 (ghi lộ trình); còn lại vào `plan/_backlog.md` (lý do ở đó).

1. `[ux]` Mở launcher sau khi UI đã nhả GPU mất ~180–210 ms (gắn GPU 158–188 ms + dựng cửa sổ) so với 0,2 ms bản dựng
   sẵn; nhả GPU sau 10 s rảnh nên đa số lần Alt+Space trong giờ giữ ấm sẽ chịu mức này — bằng chứng: bảng mục 9 —
   đề xuất: giữ GPU (và launcher ẩn) lâu hơn khi launcher vừa dùng, hoặc tăng `GPU_IDLE_DEFAULT` (`app.rs`) — giá trị:
   launcher luôn tức thì — đánh đổi RAM giữ ấm 7,3 ⇒ 14,2 MB — S — P1.
2. `[ux]` GPUI `activate_window` giả lập một lần nhấn Alt (`SendInput VK_MENU`, `gpui-pre-windows` `window.rs:838`) để
   giành foreground — người dùng đang giữ Alt (Alt+Space) có thể lẫn phím / bật menu của app đang dùng — đề xuất: kiểm
   tay C7; nếu lỗi thì daemon gọi `AllowSetForegroundWindow(pid UI)` khi nhận phím tắt và launcher tự `SetForegroundWindow`
   không qua `activate_window` — S — P2.
3. `[ram]` UI sau khi đóng cửa sổ + nhả GPU còn 7,3 MB (gd1_01 đo 4,2 MB khi chưa mở cửa sổ nào) — bằng chứng: bước 4
   của bảng — đề xuất: soát bộ đệm glyph / atlas / font của GPUI còn giữ sau khi đóng cửa sổ — M — P2.
4. `[ux]` Hiện lại có thể chớp một khung nội dung lần trước (swapchain giữ khung cuối lúc ẩn; `reset` chạy khi hiện)
   — chưa thấy được vì không chụp màn — đề xuất: nếu C7 thấy chớp thì `reset` + vẽ một khung rồi mới ẩn — S — P3.
5. `[ux]` Con trỏ sang màn khác (chưa nhớ vị trí) ⇒ dựng lại cửa sổ (~25 ms) vì gpui-pre không dời được cửa sổ — đề
   xuất: `SetWindowPos` dời bản ẩn (đổi px logic ⇒ vật lý theo scale của màn đích) — S — P3.
6. `[pro]` Lệnh tuỳ biến trong launcher (mở thư mục / URL / chạy script, như "Quicklinks" / "Script commands") — chỗ
   hợp đặt huy hiệu "Pro" — ghi vào GĐ4 của `fastcast/ROADMAP.md` — S — P3. ✅ đã ghi.
7. `[bảo mật]` không áp: launcher không nhận dữ liệu từ IPC ngoài lệnh có sẵn; vị trí đọc từ `config.json` được kẹp vào
   vùng làm việc.
