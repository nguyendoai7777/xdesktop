# materiant-gd1_05 — Checkbox, Radio, Switch

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | S — ~450 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_03, gd1_04, gd1_06 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/checkbox.rs` · `src/radio.rs` · `src/switch.rs` SỬA · `examples/gallery/pages/toggles.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10.

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `cx.control_tokens()` → `ControlTokens`: `checked` (primary) / `on_checked`,
  `unchecked_border` (N400), `track_off` (N300), `thumb` (surface), quầng `state_hover` / `state_focus` (N400 20 % /
  34 %), `focus_ring` (switch, N400 40 %). Màu nhấn khác ⇒ `Accent::X.color(cx)` / `.on_color(cx)`. `CONTROL_DURATION_MS`
  200, `DISABLED_OPACITY` 0,5 (switch).
- Icon: `Check` (dấu tích), `Minus` (indeterminate), `Circle` (radio) — `Icon::new(..).size(..).color(..)`.
- Ripple tròn quanh ô: `.ripple(RippleConfig::centered().radius(px(…)))` trên phần tử tròn (`rounded_full()` TRƯỚC
  `.ripple()`); Space ⇒ `RippleTrigger` + `.ripple_with()`, `trigger.fire(window)` trong handler phím (mẫu ô "Click,
  then Space" ở `examples/gallery/pages/style.rs`). OS giảm chuyển động ⇒ ripple tự tắt; thumb switch tự kiểm
  `cx.reduce_motion()`.
- **Bẫy**: vòng focus bằng `ring_shadow` / `.focus_ring(cx)` tô kín phần tử nền trong suốt (GPUI vẽ bóng dưới phần tử)
  ⇒ ô checkbox chưa chọn / radio dùng `ring_overlay(color, bo_góc)` hoặc quầng `state_focus` làm nền.
- Soát animation thumb giữa chừng: `-Keys "… space shot@half wait@200 shot@done"`.
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- `Checkbox` trên primitive cùng tên của `gpui-base`: checked / unchecked / indeterminate (icon `minus`), nhãn bấm
  được, disabled, ripple tròn quanh ô.
- `Radio` + `RadioGroup`: ↑ ↓ / ← → đổi lựa chọn trong nhóm, Tab vào nhóm rơi vào mục đang chọn.
- `Switch`: thumb trượt có animate (`gpui_base::motion`), Space bật / tắt, tắt animate khi OS giảm chuyển động.
- Màu chọn = primary (hoặc màu nhấn khác), đúng sáng / tối.

## 2. Không làm trong task này

- Nhóm checkbox có "chọn tất cả" (GĐ2 nếu cần). Không sửa `style.rs` / `icon.rs`.

## 3. Interface

`Checkbox::new(id).checked(CheckState).label(…).on_change(…)`; `RadioGroup::new(id).items(…).selected(ix)
.on_change(…)`; `Switch::new(id).on(bool).on_change(…)`; `.accent(Accent)` chung.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\form\ui\src\lib\` — `checkbox/` (cả `checkbox-field`, `checkbox-group` để
  lấy số đo), `radio/`, `switch/`. README / API.md của `form`.

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` điều hướng nhóm radio: ↓ ở mục cuối quay về đầu, bỏ qua mục disabled.
- C2 `[opus-run]` gallery: Space bật / tắt checkbox + switch, indeterminate → checked khi bấm, disabled không đổi.
- C3 `[opus-run]` sáng / tối đúng màu; switch animate, tắt khi bật "Show animations = off" của Windows.
- C4 `[owner-qa]` so trang `toggles` với tài liệu materiant web.

## 7. Ghi chú UI

Trang `toggles`: ba cột (Checkbox · Radio · Switch), mỗi cột đủ trạng thái + disabled, một hàng đổi màu nhấn.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
