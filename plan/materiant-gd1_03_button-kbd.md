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

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `Accent::{Primary, Danger, Warning, Success}.tokens(cx)` → `AccentTokens` đủ cho 4 dáng:
  `filled` = `base` / `on` / `filled_hover` / `filled_active`; `tonal` = `tonal*` + chữ `ink`; `outlined` / `dashed` =
  viền `outline*` + nền `ghost_*` + chữ `ink`; `text` = `ghost_*` + `ink`. Màu tuỳ ý (`Hsla`) / `base` ⇒
  `AccentTokens::resolve(màu, on_color(màu), cx.theme().colors().text, is_dark)` (hàm thuần). `cx.disabled_tokens()`
  (`ink` / `bg` / `border`; dáng text bỏ nền + viền), `LOADING_OPACITY` 0,8.
- Ripple: `.ripple(RippleConfig::default())` (IconButton: `RippleConfig::centered()`), gọi SAU `.rounded*()`. Space /
  Enter ⇒ `RippleTrigger` + `.ripple_with(cfg, &trigger)`, gọi `trigger.fire(window)` trong handler phím; giữ trigger
  bằng `window.use_keyed_state((id, "ripple"), …)` — mẫu: ô "Click, then Space" trong `examples/gallery/pages/style.rs`.
  `disabled` / `loading` ⇒ đừng gắn ripple.
- Icon: `Icon::new(IconName::Loader)` (cung tròn của Lucide `loader-circle`, quay bằng `gpui_base::motion`), `.size()`
  / `.color()`; mặc định 1 rem, màu chữ hiện hành. Gallery đã `with_assets(materiant::icon::Assets)`.
- **Đổi so với spec**: method `StyledExt` nhận `cx` (`.focus_ring(cx)`, `.bg_accent(Accent, cx)`). Trong `.hover` /
  `.active` không có `cx` ⇒ lấy `AccentTokens` (là `Copy`) trước rồi bắt vào closure.
- **Bẫy**: vòng focus `focus_ring()` / `ring_shadow` là bóng spread — GPUI vẽ bóng cả DƯỚI phần tử ⇒ nút `text` /
  `outlined` / `dashed` (nền trong suốt) bị tô kín màu vòng. Dùng `ring_overlay(cx.focus_ring_color(), bo_góc)` làm con
  khi đang focus-visible; `ring_shadow` chỉ cho `filled` / `tonal` / `elevated` (nền đục).
- Kbd: chưa có token riêng — chip dùng `bg(c.neutral(Neutral::N100))` + `border_line(cx)` + `text_caption(cx)` như trang
  `style`; thiếu token ⇒ hằng cục bộ + mục 8 (không sửa `style.rs`).
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

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
