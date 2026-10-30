# materiant-gd1_10 — Nghiệm thu GĐ1

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | S — ~300 dòng (example launcher) + báo cáo |
| Phụ thuộc | materiant-gd1_01 → gd1_09, gd1_11 (tông tối trung tính — xong trước, 30/10/2026) |
| Quyết định áp dụng | D-3 (đa nền tảng), D-6 |
| Phụ thuộc mới | — (`unicode-normalization` chỉ nếu example cần bỏ dấu — ưu tiên không) |
| File đụng tới | `examples/launcher.rs` MỚI · `docs/gd1-report.md` MỚI · `ROADMAP.md` SỬA (bàn giao GĐ1) |

## 0. Bàn giao từ materiant-gd1_11 (30/10/2026)

<!-- handoff: materiant-gd1_11 -->

- **Đã có sẵn để dùng**: launcher kiểu Raycast nên mở bằng `WindowOptions { .., ..materiant::window::translucent_window_options() }`
  (nền `Blurred` — acrylic) + nền gốc `materiant::window::translucent_surface(cx)`; nền hàng hover / chọn, chip phím
  dùng `cx.theme().colors().layer(Neutral::N…)` (trắng phủ alpha) — `VirtualList` và `Kbd` đã dùng sẵn. Mẫu thật:
  `fastcast/crates/ui/src/launcher/{mod,view}.rs` — header kiểu Raycast dùng ô trần `gpui_base::input::{InputState,
  Input}` (không `TextField`), icon app qua `AssetSource` riêng; `VirtualList` giờ chỉ vẽ vòng focus khi bàn phím.
- **Đổi so với lúc viết spec này**: tông tối mặc định giờ là đen trung tính (`DARK_SURFACE` `#1c1c1c`, chữ `#f5f5f5`, phụ
  `#a3a3a3`, viền trắng 8 %) — ảnh so với spike / bản web ở nền tối sẽ khác (spike slate) — so theo ảnh mẫu Raycast.
  Tông sáng không đổi.
- **Nợ chuyển sang đây**: soát gallery mọi trang ở tối + `GALLERY_TRANSLUCENT=1`; kiểm tay nền mờ thật (C8 của gd1_11).
- **Bẫy đã gặp**: PrintWindow chỉ chụp nội dung — không thấy desktop nhoè phía sau cửa sổ nền mờ ⇒ so ảnh nền mờ là
  việc `[owner-qa]`. Nền không đục ⇒ GPUI tắt ClearType (chữ AA xám — đừng tưởng lỗi font). Dựng cửa sổ nền mờ mới
  chậm thêm ~27 ms. Máy đang tắt "Animation effects" ⇒ `FRAMES` không in (soát `SPI_GETCLIENTAREAANIMATION` trước).
- **Bẫy nền mờ**: phần tử có `ring_shadow` (ô nhập, switch) phải giữ nền ĐẶC — bóng vẽ cả dưới nền, nền alpha bị ám màu
  vòng.
- **Soát lại khi làm**: RAM launcher ~14,0–14,9 MB (gd1_11 mục 9, nền mờ không tốn thêm); macOS / Ubuntu: `Blurred` là
  `NSVisualEffectView` / tuỳ compositor — chụp xem có nền đen đặc thay vì mờ không. Chi tiết:
  `completed/materiant/gd1/materiant-gd1_11_dark-neutral.md` mục 9.

## 0. Bàn giao từ materiant-gd1_08 (30/10/2026)

<!-- handoff: materiant-gd1_08 -->

- **Đã có sẵn để dùng**: `materiant::menu::{Menu, MenuItem, ContextMenuExt}` — dropdown `Menu::new(id).trigger(nút)
  .label(…).item(MenuItem::new(id, nhãn).icon(…).shortcut("Ctrl+C").on_select(…)).separator().submenu(item, Menu)`;
  menu chuột phải `div().id(…).context_menu(|menu, w, cx| …)`. API + cách dùng: `completed/materiant/gd1/materiant-gd1_08_menu.md` mục 9.
- **Ctrl+K của launcher**: Menu chưa có API mở bằng code — gắn `.context_menu(…)` cho dòng kết quả rồi gán
  `KeyBinding::new("ctrl-k", materiant::menu::OpenContextMenu, Some(<ngữ cảnh launcher>))`: mở giữa dòng, trỏ sẵn mục
  đầu (mục 9 gạch "Cho fastcast"). Thấy cần mở theo điểm / theo code ⇒ thêm `Menu` API ở đây, ghi mục 9.
- **Mục gọi lệnh của app**: `MenuItem::new(id, nhãn).action(MyAction)` — chọn ⇒ dispatch `MyAction` từ chỗ focus trở
  về, chip phím tắt tự lấy từ keymap (khỏi `.shortcut("…")` chép tay). Launcher dùng cho Gán phím / Gỡ phím / Về mặc định.
- **Đổi so với spec**: phím tắt là chip `Kbd` (web chữ trơn) — 5 lựa chọn tự quyết của gd1_08 đang chờ ở
  `plan/confirm.md` mục materiant; chủ dự án đổi ý thì sửa `src/menu.rs` trước khi so ảnh.
- **Đã gỡ** hàm `todo` của `examples/gallery/pages/mod.rs` (trang menu là chỗ giữ cuối) — gallery không còn trang stub.
- **Bẫy đã gặp**: Popover focus VỎ của nó mỗi lần mở (kể cả `.open(true)`) — nội dung có focus riêng phải tự giành lại
  sau khung (`window.defer`), như `grab_focus` trong `menu.rs`. Phím chữ nổi từ tầng con lên tầng cha qua cây dispatch ⇒
  `on_key_down` ở tầng cha phải kiểm `focus.is_focused(window)` trực tiếp.
- **Bẫy**: `cargo fmt` ở gốc workspace sửa luôn tệp của gd1_06 (`scroll.rs`, `list.rs`, trang + test scroll chưa
  rustfmt-sạch) — gd1_10 chạy `cargo fmt` một lượt rồi commit riêng (`plan/_backlog.md`).
- **Kiểm tay còn treo**: C5 của gd1_08 (so trang `menu` với web, rê chuột thật) — gộp vào lượt so ảnh của task này.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test menu` (8 ca), `cargo test -p materiant --lib menu`
  (5 ca); `pwsh tools/gallery-run.ps1 -Page menu -Keys "down@254,114 up@254,114 wait@300 down down down right"` ⇒
  `MENU share open`, `PLACED share right-start`.

## 0. Bàn giao từ materiant-gd1_09 (30/10/2026)

<!-- handoff: materiant-gd1_09 -->

- **Đã có sẵn để dùng**: `materiant::select::Select` (dropdown chọn một, typeahead), `materiant::tabs::Tabs` (ngang /
  `.vertical()` — đủ cho sidebar Settings của fastcast), `materiant::toast::{Toast, ToastSpec, ToastViewport}`
  (`Toast::push(window, cx, …)`; app đặt MỘT `ToastViewport::new()` ở view gốc, `.inset_top(px)` nếu có header tự vẽ).
  API + ví dụ: doc đầu mỗi tệp; tóm tắt ở `completed/materiant/gd1/materiant-gd1_09_select-tabs-toast.md` mục 9.
- **Đổi so với spec**: `Select::new(id)` không `cx`; `ToastTimer.resume` đếm lại đủ thời lượng (như web) — cả hai chờ
  chủ dự án xác nhận ở `plan/confirm.md`.
- **Nợ chuyển sang đây** (mục 8 của gd1_09): dropdown của Select đang neo bằng `gpui_kit::base::Popup` trực tiếp ⇒ chuyển
  sang Popover / định vị lật của gd1_07 (thiếu chỗ phía dưới thì lật lên); cân nhắc `ToastViewport` thành `RootPlugin`
  đăng ký trong `materiant::init` (khi đó bỏ `ToastViewport` khỏi trang toast của gallery); dời hằng cục bộ của
  `select.rs` / `tabs.rs` / `toast.rs` lên `style.rs`, icon đặc của toast lên `icon.rs`; tách nhãn / gợi ý của
  `FieldShell` (+ `.cursor(..)`) để Select bọc lại thay khung tự vẽ.
- **Bẫy đã gặp**: `window.refresh()` gọi trong lúc vẽ (vd callback `on_prepaint` đo kích thước) bị GPUI bỏ qua ⇒ dùng
  `window.request_animation_frame()`; test UI KHÔNG bắt được (helper `frame()` tự `refresh()`), chỉ gallery thấy —
  soát lại launcher nếu có đo kích thước.
- **Bẫy đã gặp**: cửa sổ test chưa focus gì thì action Tab của `Root` không chạy ⇒ focus view gốc trước khi bấm Tab.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test select --test tabs --test toast`; gallery `select` /
  `tabs` / `toast` sáng / tối qua `tools/gallery-run.ps1`; C5 của gd1_09 (so với web) còn chờ chủ dự án.

## 0. Bàn giao từ materiant-gd1_07 (30/10/2026)

<!-- handoff: materiant-gd1_07 -->

- **Đã có sẵn để dùng**: `materiant::overlay::{position, stack, tooltip, popover, dialog}` — tooltip
  `.with_tooltip(id, text)`, `Popover::new(id).trigger(…).content(…)`, `DialogHandle::new(cx)` + `Dialog::new(id,
  &handle)`. Chi tiết `completed/materiant/gd1/materiant-gd1_07_overlay.md` mục 9.
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
  `[owner-qa]` C3 (giảm chuyển động) / C4 (so web) còn treo — `completed/materiant/gd1/materiant-gd1_05_toggles.md` mục 6, 9.
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
  `elevated` nền tối ngả 4 %) — danh sách ở `completed/materiant/gd1/materiant-gd1_03_button-kbd.md` mục 9, đừng tính là lỗi.
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
  Chi tiết: `completed/materiant/gd1/materiant-gd1_04_input.md` mục 9.

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
  18,5 MB sau End — số so khi gộp mọi trang. Chi tiết: `completed/materiant/gd1/materiant-gd1_06_scroll-list.md` mục 9.

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
  `completed/materiant/gd1/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

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

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `examples/launcher.rs` (lọc bỏ dấu, nhớ vị trí, phím ở pha capture, menu Ctrl+K), `examples/common/dev.rs` | `[opus]` |
| `materiant::init` gán phím mọi component; `ContextMenuExt::context_menu_at` + test | `[opus]` |
| `tools/gallery-run.ps1 -Example launcher`, đo RAM / khung đầu, soát gallery 11 trang sáng / tối nền mờ | `[opus-run]` |
| `docs/gd1-report.md`, `ROADMAP.md` bàn giao GĐ1 | `[opus]` |
| Kiểm tay (kéo cửa sổ thật, bộ gõ, so web, macOS / Ubuntu, FRAMES khi bật animation) | `[owner-qa]` |

Không giao Sonnet: phần ghép UI chỉ một tệp ~540 dòng gắn chặt với lọc / phím / vị trí (hình học cửa sổ là `[opus]`).

## 5. Đo

- RAM `launcher` example nghỉ + sau khi gõ lọc (Task Manager); cỡ exe; thời gian khung đầu (mẫu `bench.ps1`).

## 6. Nghiệm thu

- **C1** `[opus-run]` + `[opus-unit]` — Cho launcher example release mở nền (`gallery-run.ps1 -Example launcher`), Khi gõ
  `thuoc` / `vung`, ↑ ↓, Enter, Esc, Ctrl+K → Pin, Ctrl+T, tệp vị trí `300 200` / ngoài màn, Thì lọc đúng (bỏ dấu), chọn
  đúng, `RUN` + đóng, Esc xoá chữ rồi mới ẩn, menu mở ngay trên chân và ghim đưa mục lên đầu, mở đúng chỗ đã nhớ / về giữa
  khi chỗ cũ ngoài màn; RAM ghi vào báo cáo. Kéo cửa sổ thật + bấm ra ngoài: `[owner-qa]` (báo cáo mục 6 dòng 11).
- **C2** `[opus-run]` — Cho nhánh `claude/gd1_10`, Khi soát xanh (`build`, `clippy -D warnings`, `test`, `deny`,
  `fmt --check`, `tree -i gpui-component`) + chụp gallery 11 trang × sáng / tối nền mờ, Thì xanh hết, không trang stub.
- **C3** `[owner-qa]` — gallery + launcher trên macOS và Ubuntu (lệnh: báo cáo mục 5), gửi lại ảnh / lỗi.
- **C4** `[owner-qa]` — duyệt chỗ lệch so với web (báo cáo mục 4) + kiểm tay một lượt (báo cáo mục 6).

## 8. Nợ chuyển task khác

- GĐ2 (task dọn nợ, `plan/_backlog.md` mục materiant): dời hằng cục bộ lên `style.rs` / `icon.rs`, Select neo bằng
  Popover lật cạnh, `ToastViewport` / Dialog mở bằng code qua `RootPlugin`, `ScrollbarMotion`, `FieldShell` tách nhãn,
  `FieldSize::Lg`, vòng focus switch nền tối. Danh sách đủ: `materiant/docs/gd1-report.md` mục 7.
- fastcast launcher (Ctrl+K hành động): dùng `ContextMenuExt::context_menu_at(Anchor::BottomRight, …)` trên phần thân.

## 9. Bàn giao thực tế

✅ 30/10/2026. Nhánh `claude/gd1_10` (materiant): `examples/launcher.rs` MỚI, `examples/common/dev.rs` MỚI (tách từ
`gallery/main.rs`), `docs/gd1-report.md` MỚI, `src/lib.rs` (init gán phím), `src/menu.rs` (`context_menu_at`),
`ui-tests/tests/menu.rs` (+1 ca), `tools/gallery-run.ps1` (`-Example`, chịu tiến trình tự thoát), `Cargo.toml`
(`[[example]] launcher`, `test = true`), `CLAUDE.md`, `ROADMAP.md`; commit riêng `cargo fmt --all` (tệp gd1_06).

- **Số đo** (release `-p materiant`, cột Memory, cửa sổ nền): launcher nghỉ 14,4–14,7 MB (spike 15,6–15,8), sau gõ lọc +
  menu 15,2–15,7 MB, khung đầu 374–398 ms máy rảnh / 496–578 ms lúc CPU ~58 % (spike 376–382), exe 8,9 MB (spike 23,2).
  Gallery nền mờ 13,8–24,1 MB theo trang (bảng ở báo cáo mục 3). `FRAMES` không đo được: máy tắt Animation effects.
- **Soát** (cwd = worktree, `CARGO_TARGET_DIR=C:/xdesktop-target/materiant-gd1_10`): `cargo build`, `clippy --all-targets
  -D warnings`, `test` (111 unit + 1 gallery + 5 launcher + 60 UI, trong đó menu 10), `deny check licenses` ok,
  `fmt --all --check` sạch, `tree -i gpui-component` không có. Chạy thử: `foreground_unchanged=True` mọi lần, ảnh đã xoá.
- **Opus chọn 30/10/2026** (D-9, gạch ở `plan/confirm.md`): ô tìm `TextField` (không ô trần như fastcast) — vì ví dụ để
  nghiệm thu component; ẩn = đóng cửa sổ + nhớ chỗ ở tệp trong thư mục tạm — vì ví dụ không có tiến trình giữ ấm, không
  nhúng FFI ẩn cửa sổ vào crate component; tách `examples/common/dev.rs` (sửa `gallery/main.rs`) thay vì chép ~150 dòng;
  `materiant::init` gán phím mọi component (nợ gd1_05 / gd1_06); nợ dời token KHÔNG làm ở đây (chạm ~10 module, vượt cỡ
  S) — gom một task GĐ2; đóng GĐ1 dù C3 / C4 chờ kiểm tay.
- **Bẫy**: lần chạy đầu của exe mới build khung đầu ~6 s (Defender quét) — bỏ số đó. `cargo fmt -- <tệp>` vẫn format cả
  crate. `Corner` của gpui là `Anchor` trong gpui-pre 0.3.10 (`Bounds::corner(Anchor)`). Action `OpenContextMenu` đi từ
  chỗ focus lên ⇒ phần tử có `.context_menu` phải là tổ tiên của ô đang focus. Escape ở pha capture của launcher phải
  kiểm ô tìm còn focus, không thì nuốt Esc của menu đang mở.
- **Chờ kiểm tay**: C1 phần kéo / bấm ra ngoài, C3, C4 — một danh sách 14 dòng ở `materiant/docs/gd1-report.md` mục 6
  (+ `plan/_backlog.md`).

- **Cho fastcast**: Ctrl+K hành động của launcher = `ContextMenuExt::context_menu_at(Anchor::BottomRight, …)` (`Anchor` từ
  `materiant::gpui_kit`) trên phần thân chứa ô tìm + `KeyBinding::new("ctrl-k", materiant::menu::OpenContextMenu, …)`;
  `materiant::init` đã gán phím mọi component. Mẫu: `materiant/examples/launcher.rs`. Không đổi API cũ.

**Đề xuất đã làm**: (1) `context_menu_at` — Ctrl+K mở ngay trên chân như Raycast.

## 10. Đề xuất cải tiến

1. `[ux]` Ctrl+K mở menu giữa launcher — bằng chứng: ảnh chạy thử (menu đè giữa danh sách); `ContextMenuExt` mở bằng phím
   ở tâm chủ — đề xuất: `context_menu_at(Anchor)` — giá trị: fastcast Ctrl+K đúng kiểu Raycast — S — P2. **Đã làm.**
2. `[ux]` `pwsh start.ps1 launcher` cho chủ dự án mở launcher example như `docs` — bằng chứng: báo cáo mục 6 dòng 11 phải
   gõ `cargo run --manifest-path …` — giá trị: kiểm tay nhanh — S — P3. Chưa làm: `start.ps1` / `start.sh` ở repo gốc
   ngoài phạm vi tệp của task (backlog).
3. `[ram]` Trang `button` 24,1 MB (cao nhất, các trang khác 14–18) — bằng chứng: bảng báo cáo mục 3 — đề xuất: đo xem phần
   nào (bóng `elevated`, glyph) — giá trị: biết chi phí bóng trước khi fastcast dùng nhiều — S — P3 (backlog).
4. `[pro]` Không áp (task nghiệm thu component).
5. `[bảo mật]` Tệp vị trí của example ở thư mục tạm: chỉ hai số, đọc có kiểm (`parse_position` từ chối rác / NaN, chỗ
   ngoài màn bị bỏ) — không cần sửa.
