# gd1_07 — Gán phím tắt từ launcher (Ctrl+K)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | fastcast |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | gd1_06 · materiant-gd1_07 (`Dialog`), gd1_08 (`Menu`) |
| Quyết định áp dụng | F-2, F-4 |
| Phụ thuộc mới | — |
| File đụng tới | `crates/ui/src/launcher/actions.rs` MỚI · `crates/ui/src/launcher/recorder.rs` MỚI · `crates/core/src/ipc.rs` SỬA · `crates/daemon/src/daemon.rs` SỬA · `crates/daemon/src/hotkeys.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 0. Bàn giao từ gd1_06 (30/10/2026)

<!-- handoff: gd1_06 -->

- **Đã có sẵn để dùng**: `crates/ui/src/launcher/view.rs` — `LauncherView` (ô tìm `materiant::field::TextField` giữ
  focus, `VirtualList`, chọn = vị trí trong danh sách đang hiện; `visible_commands()` / `selected()` hiện là
  `#[cfg(test)]` — bỏ cfg nếu actions cần lệnh đang chọn). Phím bắt ở `LauncherView::on_key` (pha capture): hiện bỏ qua
  mọi phím có Ctrl / Alt / Win ⇒ thêm nhánh `ctrl-k` ở đó (hay `on_action`) rồi `cx.stop_propagation()`.
- `LauncherEvent::{Run(Command), Hide}` → `launcher/mod.rs::on_event`; thêm biến thể cho actions nếu cần. Mất focus ⇒
  `Hide` (`observe_window_activation`) — menu / dialog Ctrl+K mở trong CÙNG cửa sổ (popup của gpui-base, cửa sổ bọc
  `Root` bằng `gpui_kit::open_window`) để không làm launcher mất focus rồi tự ẩn.
- Chip phím mỗi dòng đọc `UiState.config.hotkeys` mỗi lần hiện (`launcher::content`, `view::hotkey_label`). Gán xong
  ⇒ cập nhật `UiState.config` (hoặc chờ `ReloadConfig` từ daemon) rồi `view.set_entries(...)` để chip đổi ngay.
- **Đổi so với spec**: chân launcher CHƯA vẽ "Hành động Ctrl K" (khoá `launcher.actions` đã có trong catalog) — vẽ ở
  task này (nợ mục 8 của gd1_06).
- Ghi `config.json` từ UI đã có tiền lệ: `launcher::save_position` (đọc lại file → đổi một khoá → `config::save`, luồng
  nền) — cùng kiểu cho `hotkeys` nếu UI ghi; nhớ cập nhật bản trong `UiState` trước.
- **Bẫy đã gặp**: ẩn / hiện cửa sổ chỉ qua `platform::{hide, show}` (`ShowWindowAsync` — `ShowWindow` đồng bộ làm GPUI
  mất sự kiện). Launcher ẩn vẫn nằm trong `cx.windows()`; giữ ấm đếm bằng `app::windows_open`. Đang ghi phím mà mất
  focus ⇒ launcher ẩn ⇒ phải `ResumeHotkeys` ở nhánh `Hide`.
- Enter của ô tìm vẫn chạy action của `InputState` rồi mới tới capture của launcher — chế độ ghi phím nên chặn ở pha
  capture của gốc view (test: `launcher::view::tests`, mẫu `#[gpui::test]` trong bin).
- **Soát lại khi làm**: `cargo test -p fastcast-ui launcher`; chạy thử `fastcast-ui --endpoint dev --command
  open_launcher --background` với `fake_daemon` (gõ `open_launcher` vào stdin để bật / tắt) — không bật `fst` thật khi
  chủ dự án vắng (đăng ký phím toàn cục). Chi tiết: `plan/gd1_06_launcher.md` mục 9.

## 1. Làm gì

- Chọn lệnh trong launcher, Ctrl+K ⇒ menu: Gán phím tắt · Gỡ phím · Lịch sử… · Về mặc định.
- **Gán**: chế độ ghi phím — bấm tổ hợp mới, Enter xác nhận, Esc huỷ. Trong lúc ghi, daemon **tạm gỡ mọi phím tắt**
  (không thì tổ hợp đang gán cho lệnh khác bị OS nuốt), xong thì đăng ký lại.
- Kiểm trước khi ghi: tổ hợp không hợp lệ (`HotkeyParseError`), trùng lệnh khác (`Hotkeys::set` → `Conflict` ⇒ hỏi
  "Lấy phím của <lệnh>?" ⇒ `set_force`), hệ thống hay giữ (`hotkey::system_reserved` ⇒ cảnh báo, vẫn cho gán).
- Ghi `config.json` (đọc lại ngay trước khi ghi) ⇒ `ReloadConfig` ⇒ hỏi lại `StatusRequest`: OS từ chối tổ hợp ⇒ báo
  "app khác đang giữ" + nút Quay lại (`Hotkeys::rollback`).
- **Lịch sử…**: danh sách tổ hợp cũ (mới nhất trước, thời điểm thay) ⇒ chọn ⇒ `Hotkeys::restore`.
- **Về mặc định**: `Hotkeys::reset`.

## 2. Không làm trong task này

- Trang Settings → Phím tắt (GĐ4) — dùng lại `actions.rs` / `recorder.rs`.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| IPC `SuspendHotkeys` / `ResumeHotkeys` (core), kết nối hai chiều cho UI (`Connection::sender`, hàng chờ trả lời FIFO ở `ui/src/ipc.rs`) | [opus] |
| Daemon: `Registry` trên lớp `Backend` (giả được trong test), tạm gỡ / đăng ký lại, hẹn 30 s tự khôi phục, UI rớt kết nối ⇒ khôi phục ngay | [opus] |
| `recorder.rs` — `KeyDownEvent` → `Hotkey` (hàm thuần + test) | [opus] |
| `actions.rs` — phép đổi phím thuần (gán / lấy phím / gỡ / lịch sử / mặc định / quay lại) + luồng ghi → kiểm → `config.json` → `ReloadConfig` → `StatusRequest` | [opus] |
| View: Ctrl+K ⇒ menu (`materiant::menu`), hộp thoại ghi phím (`Dialog`), chân "Hành động Ctrl K" | [opus] — dính chặt pha capture phím của `LauncherView`, tách cho Sonnet tốn hơn tự làm |
| Catalog i18n `hotkey_action.*`, `hotkey.*` | [opus] (≈ 20 dòng) |
| Phím tắt thật của OS (đăng ký, app khác giữ, phím mới chạy lệnh) | [owner-qa] |

## 3. Kiểu dữ liệu · IPC · cấu hình

```rust
Message::SuspendHotkeys   // UI → daemon: gỡ đăng ký tạm; tự đăng ký lại sau 30 s nếu không có Resume
Message::ResumeHotkeys    // UI → daemon
```

`hotkeys.bindings` / `hotkeys.history` đã có (core GĐ0 T1).

## 4. Code

`[opus]`: Suspend / Resume ở daemon (hẹn giờ tự khôi phục khi UI chết giữa chừng), luồng ghi → kiểm → reload → soát
trạng thái. `recorder.rs`: đổi `KeyDownEvent` của GPUI → `fastcast_core::hotkey::Hotkey` (hàm thuần, test).

## 5. Đo

—

## 6. Nghiệm thu — Case test

- **C1** Cho bảng mặc định · Khi gán Ctrl+Shift+2 (của Thước căn) cho Chụp vùng ⇒ `Conflict { held_by: Ruler }` ⇒
  đồng ý lấy phím · Thì Chụp vùng = Ctrl+Shift+2, Thước căn không phím, lịch sử cả hai có dòng mới; Quay lại ⇒ cả hai
  về như cũ. `[opus-unit]` (`actions`) + `[opus-run]` (fake_daemon)
- **C2** Cho tổ hợp bị app khác giữ (backend giả từ chối / fake_daemon `taken <tổ hợp>`) · Khi `ReloadConfig` rồi
  `StatusRequest` · Thì `registered = false` ⇒ UI báo `hotkey.register_failed` + nút Quay lại. `[opus-unit]` + `[opus-run]`
- **C3** Cho UI đã gửi `SuspendHotkeys` · Khi UI bị giết (mất kết nối) · Thì daemon đăng ký lại ngay; không Resume mà
  vẫn nối ⇒ tự đăng ký lại sau 30 s. `[opus-unit]` (`Registry` trên backend giả)
- **C4** `recorder`: phím bổ trợ đứng một mình không phải tổ hợp; F13 một mình hợp lệ; PrintScreen hợp lệ; chữ / số
  không bổ trợ ⇒ `NeedsModifier`; Shift + số (GPUI đổi thành ký tự `@`) ⇒ `Shift+2`. `[opus-unit]`
- **C5** View: Ctrl+K trên lệnh đang chọn ⇒ menu mở; chế độ ghi: Enter / Esc / tổ hợp đi vào bộ ghi, không chạy lệnh /
  ẩn launcher. `[opus-unit]` (`#[gpui::test]`)
- **C6** IPC: UI gửi yêu cầu trên kết nối đang nhận `Run` ⇒ trả lời đúng thứ tự, `Run` xen giữa vẫn tới vòng GPUI.
  `[opus-unit]` (socket thật trong test)
- **C7** Phím thật: gán xong phím mới chạy lệnh, phím cũ thôi; trong lúc ghi, bấm tổ hợp đang gán cho lệnh khác không
  chạy lệnh đó. `[owner-qa]`

## 7. Ghi chú UI

Khoá i18n: `hotkey_action.assign`, `hotkey_action.remove`, `hotkey_action.history`, `hotkey_action.reset`,
`hotkey.recording`, `hotkey.take_over` (+ `hotkey.conflict_app`, `hotkey.conflict_system`, `hotkey.register_failed` đã có).

## 8. Nợ chuyển task khác

- GĐ4 Settings → Phím tắt: dùng lại `launcher/actions.rs` (`Change`, `apply`, `check`, `commit`, `ActionTexts`) và
  `launcher/recorder.rs`; hộp thoại ghi phím hiện nằm trong `LauncherView` (`Panel`) — tách thành view riêng khi Settings
  cần.
- materiant: `Menu` chưa mở được theo neo từ code ⇒ Ctrl+K mở menu GIỮA launcher (Raycast: góc dưới phải, trên chân) —
  đề xuất `Menu` / `ContextMenuExt` nhận điểm mở (mục 10, 2).
- gd1_05 (chép qua daemon): UI đã gửi được yêu cầu tới daemon trên kết nối IPC (`UiState.daemon` — `ipc::Requests`,
  `request` / `notify`); `fake_daemon` trả `Error` cho thông điệp lạ — thêm nhánh khi thử.
- gd1_11 (nghiệm thu): gộp kiểm tay C7 (mục 9 "Chờ kiểm tay").

## 9. Bàn giao thực tế (30/10/2026)

**Đã làm** (fastcast `claude/gd1_07`):

- IPC (`core/src/ipc.rs`): `Message::SuspendHotkeys` / `ResumeHotkeys` (thêm biến thể, giữ cũ), `SUSPEND_TIMEOUT` = 30 s,
  `Message::is_reply()`; `Connection` ghi được từ luồng khác (`Connection::sender()` → `ipc::Sender`, khoá mỗi thông điệp).
- Daemon: `hotkeys::Registry` dựng trên trait `Backend` (`GlobalHotKeyManager` / OS giả trong test), `suspend` / `resume`
  giữ bảng + trạng thái, `apply` lúc đang tạm gỡ chỉ nhớ bảng. `hotkeys::ResumeDeadline`: hạn dời theo mỗi lần UI gửi lại,
  **một** luồng hẹn giờ (64 KB stack) sống cùng lúc. `daemon.rs`: `UiDisconnected` ⇒ đăng ký lại ngay; hết hạn ⇒ đăng ký
  lại + log warn + làm mới khay.
- UI `ipc.rs`: `Requests` (global trong `UiState.daemon`) gửi yêu cầu trên CHÍNH kết nối nhận lệnh, trả lời ghép FIFO
  (daemon trả theo thứ tự), rớt kết nối ⇒ người chờ nhận lỗi; `notify` cho tạm gỡ / đăng ký lại.
- `launcher/recorder.rs`: `Keystroke` → `Hotkey` (`Recorded::{Partial, Combo, Invalid}`), đổi ngược ký tự Shift của GPUI
  Windows theo bố cục US (`@` ⇒ `Shift+2`), đi qua chuỗi chuẩn ⇒ cùng luật với `config.json`.
- `launcher/actions.rs`: `Change::{Assign, Remove, Restore, Reset, Undo}` + `apply` (thuần), `check` (trùng / OS giữ /
  không đổi), `registration_error`, `commit` (đọc lại `config.json` ngay trước khi ghi → áp → `config::save` → `ReloadConfig`
  → `StatusRequest`), `ActionTexts` (catalog con + "N phút trước").
- `launcher/view.rs`: Ctrl+K (chỉ khi focus ở ô tìm và có lệnh chọn) ⇒ `OpenContextMenu` ⇒ menu trên gốc launcher (chuột
  phải cũng mở): nhãn lệnh · Gán phím tắt… · Gỡ phím · Lịch sử ▸ (menu con: thời điểm + chip tổ hợp, mới nhất trước) ·
  Về mặc định (mục tắt khi vô nghĩa). Hộp thoại `Dialog`: ghi (`intercept_keystrokes`, Enter / Esc trơn = lưu / huỷ, giữ
  thêm phím bổ trợ ⇒ bắt đầu tổ hợp mới, báo lỗi tại chỗ) → hỏi lấy phím / OS hay giữ → báo OS từ chối + Quay lại. Chân
  "Hành động Ctrl K" (nợ gd1_06). Chip đổi ngay, giữ lệnh đang chọn.
- `launcher/mod.rs`: `Suspend` ⇒ `SuspendHotkeys` + gửi lại mỗi 20 s khi ghi lâu; `Commit` ⇒ `actions::commit` rồi cập nhật
  `UiState.config.hotkeys` + chip / hộp thoại lỗi; ẩn launcher ⇒ đóng hộp thoại (đang ghi ⇒ `ResumeHotkeys`).
  `FASTCAST_LAUNCHER_KEYS` (dev): phím đưa thẳng vào GPUI để chạy thử.
- `fake_daemon`: trả lời yêu cầu của UI (in `SUSPEND` / `RESUME` / `RELOAD` / `STATUS`), stdin `taken <tổ hợp>`.
- Ngoài dòng "File đụng tới" (cần cho luồng): `ui/src/ipc.rs`, `ui/src/app.rs` (+ trường `daemon`), `launcher/view.rs`,
  `launcher/mod.rs`, `examples/fake_daemon.rs`, `fastcast/CLAUDE.md`, `ROADMAP.md` (chỗ Pro). 8 tệp Rust sửa lớn (trần 7)
  — một lát dọc liền mạch, không tách.

**Kiểm** (cwd = worktree, `CARGO_TARGET_DIR=C:/xdesktop-target/fastcast-gd1_07`): `cargo build` · `clippy --all-targets
-D warnings` · `fmt --check` · `cargo test` (core 41, daemon 14, ui bin 87 sau khi gộp master có gd1_03, + tích hợp) · `deny check licenses` ok.
Test mới: C1 `take_over_then_undo_restores_both`, C2 `taken_combo_is_reported_not_fatal` +
`registration_error_matches_command_and_hotkey`, C3 `suspend_unregisters_everything_and_resume_restores`,
`apply_while_suspended_waits_for_resume`, `resume_deadline_moves_with_one_timer`, C4 `recorder::tests` (5), C5
`ctrl_k_assign_records_then_asks_to_take_over`, `escape_cancels_recording_without_hiding`, C6
`requests_share_the_command_connection` + `sender_writes_while_another_thread_reads`. `tests/overlay.rs`
(`fake_overlay_drag…`) đỏ một lần khi máy đang bận build song song, chạy lại riêng xanh — chập chờn theo tải, không do
task này.

**Chạy thật** `[opus-run]` (release, `fake_daemon gd107`, `--background`, phím qua `FASTCAST_LAUNCHER_KEYS`, không bàn
phím thật): Ctrl+K → Enter → Ctrl+Shift+2 → Enter → Enter ⇒ daemon nhận `SUSPEND`, `RESUME`, `RELOAD`, `STATUS
capture_region=Ctrl+Shift+2` (Thước căn mất phím); `config.json`: `capture_region` = Ctrl+Shift+2, `ruler` = null, lịch sử
cả hai có dòng. `taken Ctrl+Alt+F9` → gán Ctrl+Alt+F9 ⇒ log `not registered … (fake)`, hộp thoại lỗi → Enter (Quay lại) ⇒
`RELOAD` + `STATUS capture_region=Ctrl+Shift+2`. Giết UI giữa lúc ghi ⇒ daemon giả thấy `SUSPEND` rồi `UI GONE` (daemon thật
đăng ký lại ở `UiDisconnected`). `config.json` (bản ảo hoá MSIX) đã khôi phục bản sao lưu.

**Không đo RAM daemon**: không thêm phụ thuộc vào `daemon` / `core`; chạy `fst` thật = đăng ký phím toàn cục trên máy
chủ dự án (cấm khi vắng). Thêm lúc chạy: tối đa một luồng 64 KB khi đang ghi phím.

**Opus chọn 30/10/2026** (ghi `plan/confirm.md`):
- UI gửi yêu cầu trên kết nối nhận lệnh (hàng chờ FIFO) thay vì mở kết nối CLI riêng mỗi yêu cầu — UI chết ⇒ daemon thấy
  ngay, đăng ký lại không chờ 30 s.
- Thôi tạm gỡ ngay khi Enter bắt được tổ hợp (trước bước hỏi lấy phím) — hỏi / ghi không cần phím tắt tắt.
- Menu Ctrl+K mở giữa launcher (`context_menu` trên gốc + `OpenContextMenu`) — không sửa materiant khi gd1_10 đang
  nghiệm thu; chuột phải mở tại con trỏ.
- Lịch sử là menu con (thời điểm tương đối + chip), chọn ⇒ `Hotkeys::restore`; Gỡ phím / Lịch sử / Về mặc định trùng lệnh
  khác ⇒ cùng hộp thoại "Lấy phím".
- Ký tự Shift của GPUI Windows đổi ngược theo bố cục US.

**Bẫy đã gặp**:
- GPUI chạy action gán phím (Enter của ô tìm, Esc của `Dialog`) TRƯỚC `capture_key_down` ⇒ bộ ghi phải dùng
  `cx.intercept_keystrokes`; interceptor `stop_propagation` vẫn để GPUI gọi key listener ⇒ cờ `swallow_key` để `on_key`
  không xử lý lại (Enter vừa lưu từng bấm luôn nút "Lấy phím"; Esc vừa huỷ từng ẩn launcher).
- `Keystroke::parse` của gpui-pre đòi `&'static str`.
- GPUI Windows không báo PrintScreen (không có `VK_SNAPSHOT` trong `parse_immutable`, `MapVirtualKeyW` trả 0; Windows chỉ
  gửi `WM_KEYUP`) ⇒ không ghi được PrintScreen từ launcher (mục 10, 1).
- `Dialog` không báo khi đóng bằng Esc / ✕ / nhấp nền ⇒ hộp thoại hỏi / lỗi dọn ở `render`; hộp thoại ghi tắt Esc / nhấp
  nền của `Dialog`.

**Chờ kiểm tay** `[owner-qa]` (C7, ghi `plan/_backlog.md`): bật `fst` thật → Alt+Space → chọn Chụp vùng → Ctrl+K → Gán
phím tắt… → bấm Ctrl+Shift+2 (đang của Thước căn — trong lúc ghi KHÔNG được mở Thước căn) → Enter → "Lấy phím" ⇒ Ctrl+Shift+2
mở Chụp vùng, Thước căn hết phím; Ctrl+K → Lịch sử ▸ → chọn Ctrl+Shift+1 ⇒ Chụp vùng về Ctrl+Shift+1 (Thước căn vẫn trống — lấy
lại bằng Lịch sử của Thước căn); mở app giữ một tổ hợp (vd. ShareX) rồi gán tổ hợp đó ⇒ báo "app khác đang giữ" + Quay lại; đang ghi thì
`taskkill /F /IM fastcast-ui.exe` ⇒ phím tắt chạy lại ngay.

**Đề xuất đã làm**: hạn tự đăng ký lại dời được với một luồng hẹn giờ (trước: mỗi `SuspendHotkeys` một luồng ngủ 30 s —
client gửi liên tục đẻ luồng không giới hạn); chỗ Pro "hồ sơ phím theo app" vào `fastcast/ROADMAP.md` GĐ4.

## 10. Đề xuất cải tiến

1. `[ux]` PrintScreen không ghi được trên Windows — bằng chứng: `gpui-pre-windows` `events.rs::parse_immutable` không có
   `VK_SNAPSHOT`, `MapVirtualKeyW(VK_SNAPSHOT)` = 0 ⇒ không có `KeyDown` — đề xuất: subclass HWND launcher (`platform.rs`)
   bắt `WM_KEYUP VK_SNAPSHOT` khi đang ghi — giá trị cao (app chụp màn hay gán PrtSc) — M — P2 — **backlog**: cần bấm phím
   thật để kiểm (Win11 "Print screen mở Snipping" còn giữ phím).
2. `[ux]` Menu Ctrl+K mở giữa launcher thay vì góc dưới phải — bằng chứng: `materiant/src/menu.rs::open_context` lấy
   `host.center()` khi mở bằng phím — đề xuất: `ContextMenuExt` nhận điểm / neo mở bằng phím — S — P3 — backlog
   (materiant đang nghiệm thu gd1_10, không sửa).
3. `[ux]` Phím số bàn phím phụ: GPUI đổi `VK_NUMPAD1` ⇒ `"1"` ⇒ ghi thành Ctrl+1 (đăng ký `Digit1`, phím numpad không chạy)
   — đề xuất: `Key::Numpad(n)` trong core + `Code::Numpad*` — M — P3.
4. `[ux]` Bố cục không phải US (AZERTY, QWERTZ): đổi ngược ký tự Shift theo US sai — đề xuất: GPUI lộ scan code / VK —
   M — P3.
5. `[bảo mật]` Tiến trình cùng người dùng gửi `SuspendHotkeys` mỗi < 30 s giữ phím tắt tắt mãi — bằng chứng: daemon không
   kiểm vai (`daemon.rs::request`) — đề xuất: chỉ nhận từ kết nối `Role::Ui` (ipc_server biết vai) + gộp vào mục pipe giả
   mạo gd1_01 — S — P3.
6. `[ram]` không áp — không thêm phụ thuộc; một luồng 64 KB chỉ khi đang ghi phím.
7. `[pro]` Hồ sơ phím tắt theo app đang mở — đã ghi chỗ `fastcast/ROADMAP.md` GĐ4 (chờ xác nhận).
