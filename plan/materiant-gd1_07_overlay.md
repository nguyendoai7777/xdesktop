# materiant-gd1_07 — Overlay: định vị, Tooltip, Popover, Dialog

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~800 dòng |
| Phụ thuộc | materiant-gd1_03 (nút trong Dialog) · **song song** với gd1_09 (và gd1_04–06 nếu chưa xong) |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/overlay/mod.rs` · `position.rs` · `stack.rs` · `tooltip.rs` · `popover.rs` · `dialog.rs` SỬA · `examples/gallery/pages/overlay.rs` SỬA |

Bàn giao ghi vào gd1_08 (Menu dựng trên Popover của task này).

## 0. Bàn giao từ materiant-gd1_03 (30/10/2026)

<!-- handoff: materiant-gd1_03 -->

- **Đã có sẵn để dùng**: hàng nút cuối Dialog = `materiant::button::Button::new(id, label)` — nút chính `.filled()`
  (mặc định), nút phụ `.text().base()` hoặc `.outlined()`; nút nguy hiểm `.danger()`; đang gửi `.loading(true)` (khoá
  bấm, bỏ khỏi Tab). Nút đóng góc dialog: `IconButton::new(id, IconName::CloseThin).base().size(Size::Sm)
  .accessibility_label(…)` (dáng `text` mặc định). Cả hai `impl Styled` (`.w_full()`, `.rounded_full()`).
- Nút tự lo focus (focus handle keyed theo id, `gpui_base::Button` bên dưới) ⇒ bẫy focus của Dialog chỉ cần Tab vòng
  qua các tab stop; nút `disabled` / `loading` đã `tab_stop(false)`. Muốn focus sẵn nút chính khi mở dialog: hiện chưa
  có `.track_focus(&handle)` từ ngoài — cần thì thêm vào `button.rs` (ghi mục 8 nếu làn gd1_03 đã đóng).
- Vòng focus của nút chỉ hiện khi `window.last_input_was_keyboard()` — trả focus về phần tử neo bằng bàn phím sẽ hiện
  vòng, bằng chuột thì không: đúng ý.
- **Bẫy**: Tab của `Root` không chạy khi cửa sổ chưa có gì focus (UI test phải bấm chuột vào một nút trước —
  `ui-tests/tests/button.rs`). GPUI sinh click bàn phím ở **KeyUp**: UI test gửi `KeyDownEvent` + `KeyUpEvent`
  (`press()` trong `ui-tests/tests/button.rs`); `--keys` của `gallery-run.ps1` chỉ gửi KeyDown ⇒ Enter / Space bấm nút
  không thử được qua gallery.
- **Bẫy build**: các worktree dùng chung `CARGO_TARGET_DIR=materiant/target` đè `libmateriant-*.rlib` của nhau khi build
  cùng lúc (`unresolved import` dù code đủ) ⇒ build song song với làn khác thì dùng target riêng.
- Chữ trong khung cao cố định (`line_height = 1`) trông thấp ~2 px: `materiant::button` có `optical_lift` (pub(crate)) —
  chi tiết + bẫy `descent` âm ở `plan/materiant-gd1_03_button-kbd.md` mục 9.
- **Soát lại khi làm**: trang gallery `button` (mẫu mọi dáng / trạng thái); `cargo test -p materiant-ui-tests --test
  button`.

## 0. Bàn giao từ materiant-gd1_06 (30/10/2026)

<!-- handoff: materiant-gd1_06 -->

- **Đã có sẵn để dùng**: thân `Dialog` / `Popover` nội dung dài ⇒ `materiant::scroll::ScrollArea::new(id).vertical()
  .max_h(…)` (thanh mảnh nổi, hiện khi rê / cuộn). `Scrollbar` tự dựng ⇒ `.styles(materiant::scroll::scrollbar_styles(
  cx.scrollbar_tokens()))` để cùng diện mạo.
- **Bẫy đã gặp**: GPUI chạy action của key binding TRƯỚC `on_key_down` — Esc của popup / dialog nên là action trong
  `key_context` riêng của tầng đó (ngữ cảnh sâu hơn thắng cha), không trông `on_key_down` chặn binding của view cha.
  Phím mặc định của component gán một lần qua `Global` cờ (mẫu `materiant::list::bind_keys`) vì `lib.rs` cấm sửa.
- **Bẫy đã gặp**: build ở `CARGO_TARGET_DIR=materiant/target/<task>` riêng (target chung ⇒ cargo đưa exe của làn khác);
  `gallery-run.ps1 -Exe <target riêng>/release/examples/gallery.exe -Out <thư mục riêng>`.
- **Soát lại khi làm**: popup đè lên `VirtualList` (trang `scroll`) — Esc đóng popup, không lọt Enter xuống danh sách
  (danh sách chỉ nhận phím khi có focus).

## 1. Làm gì

- `position.rs`: hàm thuần đặt popup theo neo + phía ưa thích (trên / dưới / trái / phải × đầu / giữa / cuối), **lật
  cạnh** khi không đủ chỗ, kẹp vào khung cửa sổ, khoảng cách lệch.
- `stack.rs`: chồng tầng popup — Esc / bấm ra ngoài đóng tầng trên cùng trước, đóng tầng cha thì đóng cả con.
- `Tooltip`: hiện sau trễ khi rê / khi focus bằng bàn phím, ẩn khi rời; nội dung chữ ngắn.
- `Popover`: neo vào phần tử, mở bằng bấm / phím, bấm ra ngoài + Esc đóng, trả focus về phần tử neo.
- `Dialog`: modal có lớp phủ, bẫy focus (Tab vòng trong dialog), Esc, bấm ra ngoài thì đóng (tắt được), trả focus về
  chỗ cũ, hàng nút cuối dùng `Button` của gd1_03.
- Animate hiện / ẩn ngắn bằng `gpui_base::motion` (tắt khi giảm chuyển động).

## 2. Không làm trong task này

- Menu (gd1_08), drawer / sheet (port khi cần). Không sửa `style.rs` / `icon.rs`.

## 3. Interface

`place(anchor: Bounds, popup: Size, viewport: Bounds, pref: Placement, offset) -> (Point, Placement)` thuần;
`.tooltip(text)` trên phần tử có id; `Popover::new(id).trigger(…).content(…)`; `Dialog::open(window, cx, |…| …)` +
`DialogHandle::close()`.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\overlay\src\lib\` — `position.ts` + `position-config.util.ts` +
  `position.spec.ts` (nguồn ca lật cạnh), `overlay-positioner.ts`, `overlay-stack.ts` + spec, `overlay-dialog.ts`,
  `overlay-dialog-panel/`, `popover/`, `tooltip/`, `overlay.css` (số đo).
- Xem cách gpui-base làm popover / tooltip trước khi tự dựng — dùng lại được thì bọc style.

## 5. Đo

—

## 6. Nghiệm thu

- C1 `[opus-unit]` `place`: lật dưới → trên khi sát mép dưới, lật trái ↔ phải, kẹp khi to hơn khung — theo
  `position.spec.ts`.
- C2 `[opus-unit]` `stack`: mở A → B (con của A), Esc đóng B; đóng A thì B đóng theo.
- C3 `[opus-run]` gallery: Dialog bẫy Tab, Esc đóng, focus về nút mở; Popover sát mép cửa sổ lật đúng.
- C4 `[opus-run]` Tooltip hiện khi Tab tới nút, không hiện khi chỉ lướt chuột qua nhanh.
- C5 `[owner-qa]` Popover mở trong Dialog: Esc lần một đóng Popover, lần hai đóng Dialog.

## 7. Ghi chú UI

Trang `overlay`: bốn nút ở bốn góc mở Popover (thử lật cạnh), nút có Tooltip, nút mở Dialog (có Popover bên trong).

## 8. Nợ chuyển task khác

- gd1_08: Menu dùng `Popover` + `position` + `stack`.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
