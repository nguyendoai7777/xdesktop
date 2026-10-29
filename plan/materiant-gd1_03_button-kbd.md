# materiant-gd1_03 — Button, IconButton, Kbd

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~500 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_04, gd1_05, gd1_06 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/button.rs` SỬA · `src/kbd.rs` SỬA · `examples/gallery/pages/button.rs` SỬA |

Task làn song song: **chỉ** sửa ba tệp trên (luật tệp chung: `materiant/ROADMAP.md` mục Nguyên tắc). Bàn giao ghi vào
gd1_07 và gd1_09 (hai task nhận task này làm phụ thuộc).

## 1. Làm gì

- `Button` / `IconButton` dựng trên `gpui_base::Button` + `.ripple()`: dáng `text` / `filled` / `tonal` / `outlined` /
  `dashed` / `elevated`; cỡ `lg` / `md` / `sm` (icon 38 / 32 / 24 px); màu `primary` / `base` / `danger` / `warning` /
  `success` / tuỳ ý (`Hsla`) — hover / active trộn oklab như `color-mix` của `btn.css`; `loading` (icon `loader` quay
  bằng `gpui_base::motion`, khoá bấm); `disabled`; bo góc theo dáng; icon trái / phải.
- Focus-visible (vòng `focus_ring()`) chỉ khi tới bằng bàn phím; Tab / Space / Enter bấm được.
- `Kbd`: chip phím tắt (`Kbd::new("Ctrl+Shift+1")` tách theo `+`, mỗi phím một chip; tuỳ chọn hiển thị ký hiệu macOS
  ⌘ ⌥ ⇧ ⌃) — riêng materiant, dùng ở launcher và cột phím tắt của Menu (gd1_08).

## 2. Không làm trong task này

- Nhóm nút bật / tắt, nút split, FAB — GĐ2 nếu cần.
- Không sửa `style.rs` / `icon.rs`: thiếu token ⇒ hằng cục bộ trong `button.rs` + ghi mục 8.

## 3. Interface

`Button::new(id, label)` / `IconButton::new(id, IconName)` → builder `.filled()` `.tonal()` … `.primary()` `.danger()`
… `.color(hsla)` `.size(Size::Sm)` `.loading(bool)` `.disabled(bool)` `.icon(IconName)` `.on_click(…)`; `Size` dùng
chung cho component khác (đặt trong `button.rs`, re-export ở `lib.rs` đã khai). `Kbd::new(&str)` `.mac_symbols(bool)`.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\button\src\lib\` — `btn.css` (số đo, mix), `btn.const.ts`, `btn.type.ts`,
  `button.directive.ts`, `icon-button.directive.ts`; spec (`btn.spec.ts`, `icon-btn.spec.ts`) làm nguồn ca.
- Chip phím: style `menu/src/lib/menu-item.ts` + `menu.css` (phần shortcut).

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` màu hover / active của từng dáng × màu khớp công thức `btn.css` (trộn oklab).
- C2 `[opus-unit]` `Kbd` tách `"Ctrl+Shift+1"`, `"Alt+Space"`, `"+"`; ký hiệu mac đúng.
- C3 `[opus-run]` gallery: ma trận dáng × màu × cỡ đủ, sáng / tối; `loading` chặn `on_click`.
- C4 `[opus-run]` Tab đi qua các nút, Space / Enter kích hoạt, `disabled` bị bỏ qua khi Tab.
- C5 `[owner-qa]` so trang `button` với tài liệu materiant web.

## 7. Ghi chú UI

Trang `button`: lưới hàng = dáng, cột = màu, ba khối theo cỡ; hàng `loading` / `disabled`; hàng `Kbd`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
