# materiant-gd1_10 — Nghiệm thu GĐ1

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~300 dòng (example launcher) + báo cáo |
| Phụ thuộc | materiant-gd1_01 → gd1_09 |
| Quyết định áp dụng | D-3 (đa nền tảng), D-6 |
| Phụ thuộc mới | — (`unicode-normalization` chỉ nếu example cần bỏ dấu — ưu tiên không) |
| File đụng tới | `examples/launcher.rs` MỚI · `docs/gd1-report.md` MỚI · `ROADMAP.md` SỬA (bàn giao GĐ1) |

## 0. Bàn giao từ materiant-gd1_07 (30/10/2026)

<!-- handoff: materiant-gd1_07 -->

- **Đã có sẵn để dùng**: `materiant::overlay::{position, stack, tooltip, popover, dialog}` — tooltip
  `.with_tooltip(id, text)`, `Popover::new(id).trigger(…).content(…)`, `DialogHandle::new(cx)` + `Dialog::new(id,
  &handle)`. Chi tiết `plan/materiant-gd1_07_overlay.md` mục 9.
- **Đổi so với spec**: Dialog mở kiểu khai báo (app giữ handle), không `Dialog::open(window, cx, …)`; nợ "mở bằng
  code" cần `Root::register_plugin` trong `materiant::init` — làm được khi hết làn song song (mục 8 của gd1_07).
- **Nợ chuyển sang đây**: kiểm tay gd1_07 (`plan/_backlog.md`): C5 bằng mắt + animation khi bật Animation effects,
  đo `GALLERY_FRAME_STATS` mở / đóng Popover / Dialog (mong ~60 fps).
- **Bẫy**: launcher dùng Popover / Dialog ⇒ cửa sổ phải mở bằng `gpui_kit::open_window` (bọc `Root`) — không có
  `Root` thì Tab không vòng trong Dialog.
- **Soát lại khi làm**: RAM trang `overlay` 15,7 MB (release, `gallery-run.ps1`); so ảnh trang `overlay` sáng / tối.

## 0. Bàn giao từ materiant-gd1_05 (30/10/2026)

<!-- handoff: materiant-gd1_05 -->

- **Đã có sẵn để dùng**: `materiant::checkbox::{Checkbox, CheckState}`, `materiant::radio::{Radio, RadioGroup,
  RadioItem}`, `materiant::switch::Switch` — `.accent(Accent)`, `.label()`, `Disableable`, `on_change(Fn(&T, …))`
  (dùng được `cx.listener`). Trang gallery `toggles`; in `CHECKBOX <id> <state>` / `RADIO <nhóm> <ix>` / `SWITCH <id> <bool>`.
- **Nợ chuyển sang đây** (mục 8 gd1_05): gọi `materiant::radio::init(cx)` trong `materiant::init` (`lib.rs`); cân nhắc
  dời `state_layer` / `child_id` / `fire_on_activate` (`checkbox.rs`, `pub(crate)`) và `SWITCH_WAVE_*` lên `style.rs`;
  sửa `materiant/CLAUDE.md` "chỉ animate ripple, thumb switch, popup" ⇒ thêm dấu checkbox, chấm radio, vành sóng
  switch (chủ dự án nới 30/10/2026).
- **Bẫy đã gặp**: `--keys` của gallery chỉ gửi key-down, GPUI biến Space / Enter thành click ở key-UP ⇒ chạy thử bấm
  bằng phím không ăn (dùng chuột; test UI dùng `simulate_event(KeyDown + KeyUp)`). Sửa `examples/gallery/main.rs` gửi
  thêm `KeyUpEvent` — đề xuất P1 gd1_05 chủ dự án chưa chọn, làm nếu cần soát bàn phím launcher.
- **Bẫy đã gặp**: binding của app thắng `on_key_down` ⇒ phím mũi tên / Esc của launcher nên là action + key context
  (mẫu `radio.rs`: `actions!` + `KeyBinding` ở context riêng, gán lười qua cờ `Global`).
- **Bẫy đã gặp**: `CARGO_TARGET_DIR` chung giữa worktree song song ⇒ rlib `materiant` của làn này đè làn kia, "Finished"
  mà không build (xanh giả). Còn làn song song thì dùng target riêng (cách mồi hard link: mục 9 gd1_05).
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test toggles` (3 test); trang `toggles` sáng / tối +
  `[owner-qa]` C3 (giảm chuyển động) / C4 (so web) còn treo — `plan/materiant-gd1_05_toggles.md` mục 6, 9.
- `cargo fmt --check` trên master (30/10) báo lệch ở `src/scroll.rs`, `src/list.rs`, `examples/gallery/pages/scroll.rs`,
  `ui-tests/tests/scroll.rs` (gd1_06) — chạy `cargo fmt --all` một lượt.
- Vòng focus switch ở nền tối tương phản ~1,3:1 (`ControlTokens::focus_ring`) — đề xuất gd1_05 chưa chọn; ghi vào lượt
  so ảnh sáng / tối.

## 0. Bàn giao từ materiant-gd1_03 (30/10/2026)

<!-- handoff: materiant-gd1_03 -->

- **Đã có sẵn để dùng**: launcher hiện phím tắt bằng `materiant::kbd::Kbd::new("Ctrl+K")`
  (`.mac_symbols(cfg!(target_os = "macos"))` ⇒ ⌘ ⌥ ⇧ ⌃); nút trong launcher / Settings = `button::{Button, IconButton}`.
- **Nợ chuyển sang đây** (mục 8 của gd1_03): dời hằng cục bộ lên `style.rs` — `button.rs`: `RADIUS` 6, `GAP` 6,
  `SPINNER_PERIOD`, `ICON_BUTTON_ICON_RATIO` 0,625, `ICON_BUTTON_SPINNER_RATIO` 0,55, `ELEVATED_*_MIX`,
  `SHADOW_ALPHA`; `kbd.rs`: `CHIP_*`. `button::optical_lift` (căn thân chữ trong hộp `line_height = 1`) thành helper
  chung của `style.rs` để Select / Tabs / chip dùng.
- So ảnh với web: chỗ lệch CÓ CHỦ ĐÍCH của nút (rem thay px, vòng focus giữ bo góc, `loading` luôn quay + thay icon trái,
  `elevated` nền tối ngả 4 %) — danh sách ở `plan/materiant-gd1_03_button-kbd.md` mục 9, đừng tính là lỗi.
- **Bẫy**: macOS / Ubuntu — `optical_lift` lấy `descent.abs()` vì DirectWrite trả âm; nền khác dấu khác vẫn đúng, nhưng
  soát mắt chữ trong nút trên hai nền đó. `--keys` của gallery chỉ gửi KeyDown (GPUI click bàn phím ở KeyUp) ⇒ Enter /
  Space không thử được qua `gallery-run.ps1`.
- **Soát lại khi làm**: trang gallery `button` sáng / tối, RAM trang 22,6–22,9 MB (release, `-p materiant`).

## 0. Bàn giao từ materiant-gd1_04 (30/10/2026)

<!-- handoff: materiant-gd1_04 -->

- **Đã có sẵn để dùng** (launcher): `materiant::field::TextField` — `cx.new(|cx| TextField::new("search", window, cx)
  .placeholder(…).leading_icon(IconName::Search).clearable(true).on_change(…).on_submit(…))`; focus bằng
  `window.focus(&field.focus_handle(cx), cx)` (`impl Focusable`). Esc, Enter, ↑ ↓ đều đi tiếp tới `on_key_down` /
  `capture_key_down` của launcher (test C3) ⇒ ẩn bằng Esc, chọn bằng ↑ ↓ như mẫu gd1_06 ở dưới. Hoặc
  `cx.subscribe(&field, |…, e: &FieldEvent, …|)` (`Change` / `Submit`).
- **Đổi so với spec**: `new(id, window, cx)` (có `window`); placeholder / giá trị ban đầu áp ở khung vẽ đầu ⇒ đọc
  `value(cx)` sau một khung. `set_value` không phát `Change`. Ô lớn `lg` (38 px) chưa có — launcher cần chữ to thì đặt
  `.text_size()` ở phần tử cha hoặc thêm `FieldSize` (mục 10 gd1_04).
- **Nợ chuyển sang đây** (mục 8 gd1_04): dời `FIELD_HEIGHT` / `FIELD_PADDING_X` / `FIELD_ICON_SIZE` (`field/shell.rs`)
  lên `style.rs`. Kiểm tay C4 gd1_04 (Unikey / EVKey / IME tiếng Việt, ô FPS `99` → rời ô ⇒ `60`, bấm nhãn ⇒ focus) —
  gom vào lượt kiểm tay GĐ1.
- **Bẫy đã gặp**: GPUI chỉ phát focus / blur cho cửa sổ ĐANG active ⇒ gallery `--background` không kiểm được blur;
  test UI cần `window.activate_window()` (mẫu `ui-tests/tests/field.rs` `focus_field`). Enter ở ô một dòng làm
  `InputState` phát `Change` dù chữ không đổi — `TextField` đã lọc, ô tự viết trên `gpui_base::Input` thì nhớ lọc.
  Không thử Ctrl+V trên máy thật (đọc clipboard của chủ dự án) — dán kiểm bằng clipboard giả của test.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test field` (5 ca); trang gallery `input` RAM 16,3 MB lúc mở.
  Chi tiết: `plan/materiant-gd1_04_input.md` mục 9.

## 0. Bàn giao từ materiant-gd1_06 (30/10/2026)

<!-- handoff: materiant-gd1_06 -->

- **Đã có sẵn để dùng** (launcher): `materiant::list::{VirtualList, VirtualListHandle, ListKey, Align}`. Ô tìm giữ focus
  ⇒ `on_key_down` của launcher: `ListKey::from_key(&e.keystroke.key)` → `this.selected = this.list.navigate(key,
  this.selected, n)`; lọc xong `this.list.scroll_to(0, Align::Start)`; Enter ⇒ chạy mục chọn. `TextField` của gd1_04 để
  ↑ ↓ đi tiếp lên cha (`plan/confirm.md`) nên cách này chạy được. Mẫu đủ: trang `examples/gallery/pages/scroll.rs`.
- **Nợ chuyển sang đây** (mục 8 của gd1_06): gọi `materiant::list::bind_keys(cx)` trong `materiant::init` (hiện gán lười
  ở lần vẽ danh sách đầu); đồng bộ `ScrollbarMotion` vào theme `gpui_base` ở `theme/` — `with_idle(1 s)`,
  `with_enter / with_exit(160 ms)` cho đúng web (hiện: ẩn sau 2 s, không fade); dời `ROW_RADIUS` / `LIST_RADIUS`
  (`list.rs`), hằng thanh cuộn (`scroll.rs`) lên `style.rs` nếu component khác cần.
- **Việc treo gom**: C4 gd1_06 `[owner-qa]` — cuộn touchpad + bánh xe trên màn 144 Hz ở trang `scroll`.
- **Bẫy đã gặp**: GPUI chạy action của key binding TRƯỚC `on_key_down` ⇒ phím của component phải là action trong
  `key_context` riêng (sâu hơn cha nên thắng), `on_key_down` không chặn được binding của view cha. Worktree chung
  `CARGO_TARGET_DIR` ghi đè rlib của nhau ⇒ build ở `materiant/target/<task>`; `gallery-run.ps1` truyền `-Exe` / `-Out`
  riêng.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test scroll` (7 ca); RAM trang `scroll` 18,1 MB lúc mở /
  18,5 MB sau End — số so khi gộp mọi trang. Chi tiết: `plan/materiant-gd1_06_scroll-list.md` mục 9.

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `.drag_region()` (`materiant::window::DragRegionExt`) — thanh trên của launcher; ô nhập bên
  trong bọc `.occlude()`. Cửa sổ mở với `is_movable: true`. Icon `Search` cho ô lọc.
- Việc treo của gd1_02 cần gom: kiểm tay C4 (kéo cửa sổ) + C5 (ripple so web, icon 150 % DPI) — `plan/_backlog.md`.
- Gom "dời lên `style.rs` / `icon.rs`" của gd1_03–06 (mục 8 của từng task); thêm icon = tệp `assets/icons/<tên>.svg` +
  một dòng `icons!` ở `src/icon.rs`.
- So ảnh sáng / tối: `gallery-run.ps1 -Keys "ctrl-t shot@light ctrl-t shot@dark"` cho mỗi trang.
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- Dựng lại launcher của spike bằng materiant (`TextField`, `VirtualList`, `Kbd`, `.drag_region()`, `Menu` cho Ctrl+K):
  Esc / bấm ra ngoài thì ẩn, kéo được bằng thanh trên (ô nhập không kéo), vị trí kéo tới được nhớ cho lần mở sau.
- Đo RAM so với spike (15,7 MB Task Manager), khung đầu.
- So ảnh gallery với trang tài liệu materiant ở cả sáng / tối — liệt kê chỗ lệch.
- Chạy gallery + launcher trên macOS và Ubuntu (D-3): ghi lỗi nền tảng.
- Gom việc treo của gd1_01–09 (mục 8 "dời token lên `style.rs`", icon thiếu…) thành một lượt dọn hoặc ghi `plan/_backlog.md`.
- Báo cáo `docs/gd1-report.md`; mục "Bàn giao GĐ1" trong `ROADMAP.md` cho fastcast.

## 2. Không làm trong task này

- Không thêm component mới; lỗi lớn ⇒ tách task sửa.

## 5. Đo

- RAM `launcher` example nghỉ + sau khi gõ lọc (Task Manager); cỡ exe; thời gian khung đầu (mẫu `bench.ps1`).

## 6. Nghiệm thu

- C1 `[opus-run]` launcher example chạy đủ hành vi mục 1 trên Windows; RAM ghi vào báo cáo.
- C2 `[opus-run]` soát xanh cả repo; gallery đủ mọi trang, không trang nào còn "chưa làm".
- C3 `[owner-qa]` chạy gallery + launcher trên macOS và Ubuntu (lệnh trong báo cáo), gửi lại ảnh / lỗi.
- C4 `[owner-qa]` duyệt bảng so ảnh sáng / tối.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
