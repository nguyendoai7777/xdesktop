# materiant-gd1_08 — Menu: dropdown + chuột phải

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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

- C1 `[opus-unit]` `menu_nav`: bỏ qua disabled / vạch ngăn, quay vòng, typeahead theo `menu.util.spec.ts`.
- C2 `[opus-run]` gallery: menu chuột phải sát góc phải dưới lật lên trên-trái; menu con mở bằng →, đóng bằng ←.
- C3 `[opus-run]` Esc đóng menu con trước, rồi menu cha; chọn mục ⇒ đóng hết + gọi `on_select`.
- C4 `[owner-qa]` so trang `menu` với tài liệu materiant web; cột phím tắt canh phải thẳng hàng.

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

## 10. Đề xuất cải tiến
