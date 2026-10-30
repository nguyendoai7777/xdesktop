# materiant-gd1_08 — Menu: dropdown + chuột phải

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | M — ~550 dòng |
| Phụ thuộc | materiant-gd1_07 (Popover, định vị, chồng tầng) · gd1_03 (`Kbd`) |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/menu.rs` SỬA · `examples/gallery/pages/menu.rs` SỬA |

Chính là panel Ctrl+K của launcher fastcast (`plan/gd1_07_hotkey-assign.md`). Bàn giao ghi vào gd1_10.

## 0. Bàn giao từ materiant-gd1_07 (30/10/2026)

<!-- handoff: materiant-gd1_07 -->

- **Đã có sẵn để dùng** (interface đủ: `plan/materiant-gd1_07_overlay.md` mục 9):
  - Dropdown = `materiant::overlay::popover::Popover::new(id).trigger(nút).placement(Placement::BOTTOM_START)
    .content(|dismiss, w, cx| …)`; chọn mục xong ⇒ `dismiss.dismiss(w, cx)` (trả focus về trigger). `.bare()` bỏ bề
    mặt nếu menu tự vẽ; muốn cùng diện mạo thì bọc `popover::surface(window, cx)` (nền, bo 8, bóng, viền khi tối).
  - Menu con: Popover lồng trong nội dung Popover cha là TẦNG CON tự động (cha đọc qua `stack::current_scope` lúc vẽ):
    bấm vào menu con nằm ngoài menu cha không đóng cha, Esc đóng menu con trước, đóng cha thì con đóng theo. Đặt
    `.placement(Placement::RIGHT_START)` — sát mép phải tự lật sang trái (`Placement::fallbacks`).
  - Menu chuột phải: tự dựng bằng `overlay::position::anchored(cell, PlaceConfig::new(Placement::BOTTOM_START)
    .offset(px(0.)))` với `cell: Rc<Cell<Bounds>>` = `Bounds::new(vị_trí_chuột, Size::default())`, bọc trong
    `deferred(LayerScope::new(layer, …)).with_priority(LAYER_PRIORITY + PRIORITY_STEP * stack::depth(..))`, đăng ký tầng
    bằng `stack::open(LayerOptions { parent: stack::current_scope(cx), .. }, close_fn, w, cx)`, ghi bounds bằng
    `.on_placed(|b, _, w, cx| stack::set_bounds(layer, b, w, cx))`, đóng khi bấm ra ngoài nếu
    `stack::closes_on_press(layer, pos, w, cx)` — đúng cách `popover.rs` làm (đọc nó làm mẫu).
  - `Popover::open(bool)` + `.on_open_change(…)` cho kiểu điều khiển từ ngoài (mở menu con bằng → / hover).
- **Bẫy đã gặp**:
  - Nội dung Popover nằm DƯỚI trigger trong cây dispatch: phím gán ở ngữ cảnh trigger chạy cả khi focus trong panel ⇒
    `popover.rs` gán Enter / Space = `NoAction` ở `CONTENT_CONTEXT`. ↑ ↓ Enter của menu phải gán ở ngữ cảnh RIÊNG của
    menu (sâu hơn) — không thì ↑ ↓ rơi lên ngữ cảnh `Gallery` (đổi trang).
  - `on_mouse_down_out` của GPUI xét bounds, không xét tầng — đừng tự dùng cho menu con, hỏi `stack::closes_on_press`.
  - Phần tử trong `deferred` vẫn layout như con của chỗ đặt nó: `anchored` đã xử lý (bề ngang = cửa sổ), đừng bọc
    nội dung menu trong khung có bề ngang cố định của trigger.
  - Máy chủ dự án TẮT "Animation effects" ⇒ `motion` nhảy thẳng, `GALLERY_FRAME_STATS` không in gì.
  - `gallery-run --keys`: sau bước chuột không nghỉ — chèn `wait@300` trước phím.
- **Soát lại khi làm**: `cargo test -p materiant-ui-tests --test overlay` (mẫu harness Popover lồng nhau, `settle()`
  qua animation bằng `advance_clock`); trang gallery `overlay` (bốn góc lật cạnh, Popover trong Dialog).

## 0. Bàn giao từ materiant-gd1_03 (30/10/2026)

<!-- handoff: materiant-gd1_03 -->

- **Đã có sẵn để dùng**: cột phím tắt = `materiant::kbd::Kbd::new("Ctrl+Shift+P")` — tách theo `+` (`"Ctrl++"` →
  `Ctrl` `+`), mỗi phím một chip (nền `neutral-100`, viền, chữ caption muted); `.mac_symbols(true)` ⇒ ⌘ ⌥ ⇧ ⌃ ↩ ⌫ ⎋ ⇥
  ↑ ↓ ← →. Hàm thuần `kbd::split_keys`, `kbd::mac_symbol`, `Kbd::labels()` cho test.
- **Chưa có**: dựng `Kbd` từ keymap GPUI — `window.keystroke_text_for(action)` trả dạng `ctrl-shift-p` (nối `-`), `Kbd`
  chỉ tách `+` ⇒ đổi chuỗi (`-` → `+`, cẩn thận phím `-`) hoặc thêm `Kbd::from_keystroke` vào `kbd.rs` (đề xuất 3 của
  gd1_03, chủ dự án chưa chọn — hỏi lại nếu cần).
- Web vẽ shortcut của menu là chữ trơn (`menu.css` `.menu-item-shortcut`: 12 px, muted, `margin-left: 12px`), không phải
  chip — chọn dáng nào cho Menu thì hỏi chủ dự án; `Kbd` chưa có biến thể chữ trơn.
- Mục menu cao cố định ⇒ chữ trông thấp ~2 px như nút: dùng lại cách `button::optical_lift` (chi tiết + bẫy `descent` âm
  ở `plan/materiant-gd1_03_button-kbd.md` mục 9).
- **Bẫy**: GPUI sinh click bàn phím (Enter / Space) ở KeyUp — UI test gửi KeyDown + KeyUp (`press()` trong
  `ui-tests/tests/button.rs`); `--keys` của gallery chỉ KeyDown.
- **Soát lại khi làm**: hàng `Kbd` ở trang gallery `button`; `cargo test -p materiant --lib kbd`.

## 1. Làm gì

- `Menu` dựng trên `Popover` + định vị của gd1_07 (gpui-base không có menu); tham khảo `menu` của gpui-component
  (Apache-2.0 — chỉ đọc cách làm, không thêm phụ thuộc).
- Mục: chữ + icon trái + phím tắt canh phải (`Kbd`) + disabled; nhãn nhóm; vạch ngăn; mục có menu con (→ mở, ← đóng).
- Bàn phím: ↑ ↓ (bỏ qua disabled / vạch ngăn, quay vòng), Enter / Space chọn, Esc đóng tầng hiện tại, gõ chữ nhảy tới
  mục bắt đầu bằng chữ đó (typeahead).
- Mở kiểu dropdown (neo vào nút) và kiểu menu chuột phải (neo vào điểm chuột, lật cạnh).

## 2. Không làm trong task này

- Thanh menu kiểu ứng dụng (File / Edit…), mục checkbox / radio trong menu — GĐ2 nếu cần.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `src/menu.rs`: `menu_nav` thuần, `Menu` / `MenuItem` dựng trên `Popover`, menu con điều khiển `.open()`, focus giữa các tầng, menu chuột phải (`ContextMenuExt`) | `[opus]` — luồng focus / dispatch nhiều tầng |
| `ui-tests/tests/menu.rs` (MỚI) | `[opus]` — cùng lúc với code, cần biết cây dispatch |
| `examples/gallery/pages/menu.rs` | `[opus]` — trang nhỏ, in dòng cho `gallery-run` phải khớp interface vừa chốt (không giao Sonnet: brief dài hơn chính trang) |
| So diện mạo với tài liệu materiant web | `[owner-qa]` |

## 3. Interface

`Menu::new(id).item(MenuItem::new("copy", label).icon(…).shortcut("Ctrl+C").on_select(…)).separator().label(…)
.submenu(…)`; `.context_menu(|menu| …)` trên phần tử có id; điều hướng là hàm thuần `menu_nav(items, ix, key) -> ix`.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\menu\src\lib\` — `menu-panel.ts`, `menu-item.ts`, `menu-label.ts`,
  `menu-separator.ts`, `menu-trigger.ts`, `menu-context.ts`, `menu.util.ts` (+ `menu.util.spec.ts`,
  `menu-panel.spec.ts` làm nguồn ca), `menu.css`, `menu-surface/`.

## 5. Đo

—

## 6. Nghiệm thu

- **C1** `[opus-unit]` — Cho danh sách có mục tắt / nhãn / vạch ngăn. Khi ↑ ↓ Home End hoặc gõ chữ. Thì `menu_nav`
  bỏ qua mục không chọn được, quay vòng ở hai đầu, chưa trỏ ⇒ ↓ mục đầu / ↑ mục cuối, typeahead đúng các ca của
  `menu.util.spec.ts` (`src/menu.rs` tests; chạy thật: `ui-tests` `arrows_skip_disabled_and_wrap`, `typeahead_and_tab`).
- **C2** `[opus-unit]` + `[opus-run]` — Cho menu chuột phải mở sát góc phải dưới. Thì menu lật lên trên-trái
  (`top-end`); mở ở góc trên-trái vùng thì `bottom-start`; menu con mở bằng → (con trỏ ở mục đầu), đóng bằng ←; menu con
  sát mép phải cửa sổ lật sang trái (`left-start`) (`placements_flip_per_axis`, `context_menu_flips_at_the_corner`,
  `escape_closes_the_submenu_first`; gallery: `PLACED corner top-end`, `PLACED recent left-start`).
- **C3** `[opus-unit]` + `[opus-run]` — Cho dropdown đang mở menu con. Khi Esc. Thì menu con đóng, menu cha còn; Esc lần
  hai đóng menu cha, focus về nút. Khi chọn mục (Enter / bấm, kể cả trong menu con). Thì cả chuỗi đóng TRƯỚC, rồi mới
  gọi `on_select` (`enter_selects_closes_and_restores_focus`, `selecting_in_a_submenu_closes_the_chain`; gallery).
- **C4** `[opus-run]` — Rê chuột lên mục có menu con ⇒ mở sau 150 ms (chưa tới thì chưa), rê sang mục thường ⇒ đóng; bấm
  ra ngoài đóng hết (`hovering_opens_the_submenu_after_a_delay`; gallery `move@`).
- **C5** `[owner-qa]` so trang `menu` với tài liệu materiant web; cột phím tắt canh phải thẳng hàng; rê chuột thật.

## 7. Ghi chú UI

```
┌────────────────────────────┐
│ CLIPBOARD                  │
│ ⧉ Copy           [Ctrl][C] │
│ ▢ Save           [Ctrl][S] │
│ ────────────────────────── │
│ ⚙ Settings              ›  │
└────────────────────────────┘
```

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

**Interface đã có** (`materiant::menu`, doc đầu `src/menu.rs`):

- Dropdown: `Menu::new(id).trigger(Button…).label("…").item(MenuItem::new(id, label).icon(IconName).shortcut("Ctrl+C")
  .danger(bool).disabled(bool).on_select(|w, cx| …)).separator().submenu(MenuItem::new(…), Menu::new(sub_id)…)` —
  `.placement(Placement)` (mặc định `BOTTOM_START`, cách nút 4 px), `.disabled(bool)`, `.on_open_change(|open, w, cx|)`
  (cả menu con), `.on_placed(|bounds, placement, w, cx|)`.
- Menu chuột phải: `div().id(…).context_menu(|menu, w, cx| menu.item(…))` (trait `ContextMenuExt` cho `Stateful<Div>`)
  — chuột phải mở tại con trỏ; Shift+F10 khi focus nằm trong phần tử mở giữa phần tử (trỏ sẵn mục đầu). `build` chạy mỗi
  khung khi đang mở (không chạy khi đóng). Phần tử con có menu riêng thắng phần tử cha (`stop_propagation`).
- Thuần: `menu_nav(&[NavItem], Option<usize>, NavKey) -> Option<usize>` (`Prev / Next / First / Last / Type(query)`),
  `typeahead_text(&KeyDownEvent)`, `submenu_config()`, `context_config()`. Action `materiant_menu::{SelectPrev…,
  OpenContextMenu}`, `KEY_CONTEXT = "MateriantMenu"`, `bind_keys(cx)` (lần vẽ đầu tự gọi).

**Cách làm** (chi tiết + bẫy ở doc đầu module):

- Dựng trên `Popover` của gd1_07 (`.bare()`, bề mặt `popover::surface` bo 12 đệm 4) — không viết lại định vị. Menu con là
  Popover lồng trong khung cha, ĐIỀU KHIỂN TỪ NGOÀI bằng `.open(open_sub == Some(ix))`; Popover tự mở khi bấm mục ⇒
  `on_open_change` đồng bộ lại. Menu chuột phải = Popover có trigger cỡ 0 đặt `absolute` tại điểm bấm trong một lớp
  phủ vô hình của phần tử chủ (đo bounds chủ bằng `track_bounds`).
- Focus: Popover focus VỎ của nó khi mở (kể cả mở bằng `.open(true)`) ⇒ khung menu có cờ `grab_focus`, lần vẽ tới
  `window.defer` focus vào khung (sau Popover). Mở menu con bằng → / Enter ⇒ focus vào menu con; rê chuột ⇒ menu cha
  giành lại focus (↑ ↓ vẫn đi ở menu cha như web).
- Phím trong menu con nổi lên menu cha (menu con nằm dưới mục cha trong cây dispatch): action thì nơi sâu nhất bắt;
  typeahead (`on_key_down`) chỉ xử lý khi khung của mình được focus TRỰC TIẾP.
- Chọn mục ⇒ `root.dismiss` (stack đóng cả tầng con, trả focus về nút) rồi mới `on_select`.
- Đang mờ đi (đã đóng) ⇒ khung không gắn handler chuột (rê lúc đó sẽ focus vào khung sắp mất).
- Sửa ngoài phạm vi (bắt buộc): `examples/gallery/pages/mod.rs` bỏ hàm `todo` (trang menu là chỗ giữ cuối cùng ⇒ hàm
  thành dead code, clippy `-D warnings` đỏ).

**Soát xanh** (cwd = worktree, `CARGO_TARGET_DIR=materiant/target/gd1_08`): `cargo build`, `cargo clippy --all-targets
-- -D warnings`, `cargo test` (unit `menu::tests` 5 ca; `ui-tests --test menu` 8 ca), `cargo deny check licenses`,
`cargo tree -i gpui-component` (không có). **Lần soát cuối** (sau khi gộp master có gd1_07-fix, 30/10): tất cả xanh —
lib 104 ca, `ui-tests` đủ các tệp, `licenses ok`, rustfmt sạch ở tệp của task.

**Chạy thật** (`tools/gallery-run.ps1 -Page menu`, máy một màn ⇒ màn mặc định, `foreground_unchanged=True`): bấm
Actions → ↓↓↓ → `MENU share open` + `PLACED share right-start`; Esc ⇒ `MENU share closed`, Esc ⇒ `MENU actions closed`;
File (sát phải) → Open recent → `PLACED recent left-start` (lật trái); ô Corner + Shift+F10 ⇒ `PLACED corner top-end`
(lật lên trên-trái); rê `move@` lên Share ⇒ mở sau 150 ms, rê xuống ⇒ `MENU share closed`; bấm Delete ⇒ `MENU actions
closed` rồi `SELECT delete`; vùng + Shift+F10 + `s` + Enter ⇒ `SELECT save`; sáng / tối đúng (ảnh đã xem, đã xoá). RAM
gallery 14,9–16,0 MB (như các trang khác). Máy chủ dự án tắt animation ⇒ không đo `FRAMES` (hiệu ứng là của Popover,
gd1_07 đã đo ~60 fps).

**Lệch so với spec / web** (ghi `plan/confirm.md`): phím tắt là chip `Kbd` (web chữ trơn); không roving focus; thêm
Shift+F10; menu chuột phải hở 0 px; đóng rồi mới `on_select`. Cỡ thực tế ~700 dòng mã (spec ước 550) — trong trần 900.

**Chờ kiểm tay** (C5 `[owner-qa]`, ghi `plan/_backlog.md`): `pwsh start.ps1 docs menu` — so trang với tài liệu menu
của materiant web ở sáng / tối; cột phím tắt thẳng hàng; rê chuột thật qua Share / More (mở sau ~150 ms, lướt ngang
không bung); chuột phải sát góc phải dưới cửa sổ lật lên trên-trái; dropdown "40 items" cuộn bằng bánh xe và ↑ ↓.

**Đề xuất đã làm** (D-8, chủ dự án vắng — tự chọn hai đề xuất UX giá trị cao, cỡ S):

- Mở bằng bàn phím (Enter / Space trên nút, Shift+F10) ⇒ trỏ sẵn mục đầu (web: focus `first`); mở bằng chuột ⇒ chưa
  trỏ (`window.last_input_was_keyboard()`). Test `keyboard_open_points_at_the_first_item`.
- Menu cao hơn cửa sổ ⇒ danh sách cuộn trong khung (`max_h` = cửa sổ − đệm, `overflow_y_scroll`), ↑ ↓ / typeahead kéo
  mục lọt khung (`ScrollHandle::scroll_to_item`); menu con là `deferred` nên không bị cắt. Gallery: dropdown "40 items"
  (cao kín cửa sổ ⇒ không vị trí nào vừa, định vị chọn vị trí tràn ít nhất = `right-start` cạnh nút; End + `y` + Enter ⇒
  `SELECT Yellow`).
- Sau luật mới của chủ dự án (30/10 — làm hết đề xuất S/M đáng làm), nhánh `claude/gd1_08b`:
  - `MenuItem::action(impl Action)` — chọn mục ⇒ đóng menu, `on_select`, rồi `window.dispatch_action` từ chỗ focus trở
    về (nút / phần tử mở menu); không gọi `.shortcut` ⇒ cột phím tắt tự hiện phím đang gán trong keymap
    (`highest_precedence_binding_for_action` của khung trước — ngữ cảnh nơi mở menu), đổi phím ⇒ menu đổi theo. Đổi
    phím GPUI → chuỗi `Kbd` ngay trong `menu.rs` (`keystroke_combo`, `binding_combos`, `key_label`; phím đôi ⇒ nhiều
    chip) nên KHÔNG phải sửa `kbd.rs`. Test `keystrokes_become_kbd_combos`, `an_action_item_dispatches_from_where_focus_returns`;
    gallery: ô Corner F2 ⇒ `ACTION rename`, mục Rename hiện chip `F2` từ keymap, chọn ⇒ `ACTION rename`.
  - Thanh cuộn mảnh của materiant (`gpui_base::Scrollbar` + `scroll::scrollbar_styles`, luôn hiện khi có phần khuất)
    cạnh danh sách cuộn của menu dài — không dùng `ScrollArea` (khung `size_full` của nó không co theo `max_h`). Menu
    ngắn không có thanh (gallery đã soát cả hai).

**Cho fastcast** (gd1_07 "Gán phím tắt từ launcher", Ctrl+K): menu lệnh của launcher = `Menu` dropdown neo vào nút /
dòng kết quả, hoặc mở bằng code? — Menu CHƯA có API mở từ ngoài (chỉ nút bấm / Enter / Space / chuột phải / Shift+F10).
Ctrl+K mở menu ⇒ cách gọn: dòng kết quả có `.context_menu(…)` và Ctrl+K gửi action `materiant::menu::OpenContextMenu`
khi focus trong dòng (`window.dispatch_action(OpenContextMenu.boxed_clone(), cx)` — mở giữa dòng, trỏ sẵn mục đầu), hoặc
gán `KeyBinding::new("ctrl-k", OpenContextMenu, Some(<ngữ cảnh launcher>))`. "Gán phím tắt…" mở Dialog trong `on_select`
là an toàn (menu đã đóng + trả focus trước khi `on_select` chạy).

## 10. Đề xuất cải tiến

- `[ux]` Mục menu tự hiện phím tắt từ keymap — M — P2 — **ĐÃ LÀM** (`MenuItem::action`, mục 9).
- `[ux]` Thanh cuộn mảnh cho menu dài — S — P3 — **ĐÃ LÀM** (`Scrollbar` cạnh danh sách, mục 9).
- `[ux]` Phím Menu / Apps của bàn phím Windows mở menu chuột phải như Shift+F10 — chưa rõ tên phím trong GPUI — thử
  `KeyBinding::new("menu", …)` trên máy thật — S — P3 (backlog: cần bấm phím thật).
- `[bảo mật]` không áp — menu không đọc tệp / IPC, không lưu gì. `[ram]` không áp — state theo id, rơi khi menu đóng
  hết hiệu ứng (đo RAM gallery không đổi). `[pro]` không áp — component dùng chung.
