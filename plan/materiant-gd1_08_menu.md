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
