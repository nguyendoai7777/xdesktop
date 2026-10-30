# materiant-gd1_07 — Overlay: định vị, Tooltip, Popover, Dialog

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
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

## 2b. Phân vai

| Phần việc | Vai |
| --- | --- |
| `position.rs` (hàm thuần + phần tử `Anchored`), `stack.rs` (luật + lớp GPUI + `LayerScope`) | `[opus]` |
| `popover.rs`, `dialog.rs`, `tooltip.rs` (focus, phím, chồng tầng, animation) | `[opus]` |
| Trang gallery `overlay`, `ui-tests/tests/overlay.rs` | `[opus]` — interface đổi liên tục khi chạy thử, giao Sonnet tốn hơn tự làm |
| C5 nhìn bằng mắt + animation khi bật Animation effects | `[owner-qa]` |

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

- C1 `[opus-unit]` Cho neo 100 × 40 trong khung 1000 × 800, popup 200 × 100 / Khi `place` sát mép dưới, sát mép trái /
  phải, popup to hơn khung / Thì lật dưới → trên, trái ↔ phải, kẹp về mép đầu + 8 px — theo `position.spec.ts`
  (`overlay::position::tests`, 12 test).
- C2 `[opus-unit]` (luật thuần + UI test) Cho A mở, B (con của A) mở / Khi Esc; khi bấm trong B (ngoài A); khi đóng A /
  Thì Esc đóng B trước; bấm trong B giữ cả hai; đóng A thì B đóng theo (`overlay::stack::tests` +
  `ui-tests/tests/overlay.rs` `nested_popovers_close_top_first`, `closing_the_parent_closes_the_child`).
- C3 `[opus-run]` + UI test: Cho Dialog mở từ nút / Khi Tab nhiều lần, Esc / Thì focus vòng trong Dialog, Esc đóng,
  focus về nút mở; Popover bốn góc gallery lật đúng (`dialog_traps_tab_and_restores_focus`, gallery `PLACED …`).
- C4 `[opus-run]` + UI test: Cho nút có Tooltip / Khi Tab tới; khi rê < 150 ms rồi rời / Thì hiện ngay; không hiện
  (`tooltip_shows_on_keyboard_focus`, `tooltip_waits_for_a_deliberate_hover`, ảnh `fast` / `hover`).
- C5 `[owner-qa]` (đã có UI test `escape_closes_the_inner_popover_before_the_dialog` + gallery): Popover mở trong
  Dialog: Esc lần một đóng Popover, lần hai đóng Dialog — chủ dự án nhìn bằng mắt.

## 7. Ghi chú UI

Trang `overlay`: bốn nút ở bốn góc mở Popover (thử lật cạnh), nút có Tooltip, nút mở Dialog (có Popover bên trong).

## 8. Nợ chuyển task khác

- gd1_08: Menu dùng `Popover` + `position` + `stack` (interface chốt ở mục 9).
- Task sau (chưa có tệp): `Dialog::open(window, cx, |…| …)` mở bằng code — cần lớp chứa `Root::register_plugin`
  đăng ký trong `materiant::init` (sửa `lib.rs`), làm khi hết làn song song.

## 9. Bàn giao thực tế (30/10/2026)

**Interface đã chốt** (`src/overlay/`, gd1_08 dựng trên đây):

- `position`: `place(anchor, popup, viewport, pref, offset) -> (Point, Placement)` (đúng spec) + `place_with(anchor,
  popup, viewport, &PlaceConfig) -> Placed { origin, placement }`. `Placement { side: Side, align: Align }`, hằng
  `TOP … RIGHT_END`, `Placement::fallbacks()` (thứ tự web: cạnh đối diện → hai cạnh vuông góc → đổi căn).
  `PlaceConfig { placement, offset = 8, padding = 8, flip, shift, fallbacks }`. Phần tử `anchored(Rc<Cell<Bounds>>,
  PlaceConfig)` (`.occlude()`, `.on_placed(|bounds, placement, w, cx|)`) — đo popup ở prepaint, khung đầu đúng chỗ;
  `track_bounds(&cell)` = canvas con của trigger ghi bounds mỗi khung. Menu chuột phải: đặt thẳng `Bounds` cỡ 0 tại
  con trỏ vào cell.
- `stack`: `LayerStack` thuần (`push`, `remove` gom cả con cháu, `escape_target`, `press_closes`); lớp GPUI theo cửa
  sổ: `open(LayerOptions { parent, close_on_escape, close_on_outside }, close_fn, window, cx) -> LayerGuard` (rơi guard =
  rời ngăn xếp), `close(id)` (đóng con, sâu trước), `set_bounds`, `closes_on_press(id, point)`, `depth`, `top`,
  `dismiss_top`, `current_scope`, phần tử `LayerScope::new(id, child)` (nội dung tầng — trigger tầng con đọc
  `current_scope` lúc vẽ để biết cha).
- `popover`: `Popover::new(id).trigger(e).content(|dismiss: PopoverDismiss, w, cx| …)` + `.placement / .offset /
  .place_config / .open(bool) / .on_open_change / .on_placed / .close_on_outside / .close_on_escape / .bare() /
  .disabled()`, `Styled` = khung trigger. `popover::surface(window, cx)` = bề mặt chuẩn (Menu / Select dùng lại).
  Phím: `TRIGGER_CONTEXT` Enter / Space ⇒ `Toggle`; `CONTENT_CONTEXT` Esc ⇒ `Dismiss`, Enter / Space ⇒ `NoAction`
  (gán lười một lần, mẫu `list::bind_keys`). Ưu tiên `deferred` = `LAYER_PRIORITY` (100) + `PRIORITY_STEP` (10) × số
  tầng đang mở lúc mở ⇒ tầng mở sau luôn nổi trên.
- `dialog`: `DialogHandle::new(cx)` (`open / close / is_open / layer`) + `Dialog::new(id, &handle).title(…)
  .close_button(label).child(…).actions([…]).close_on_escape(b).close_on_backdrop(b)`. Bẫy Tab = `FocusTrapElement` của
  gpui-base (cửa sổ phải bọc `Root`). Bấm nền = `on_click` của lớp nền (cả hai đầu cú nhấn trên nền).
- `tooltip`: `TooltipExt::with_tooltip(id, text)` / `Tooltip::new(id, text).placement(…).child(…)`; trễ 150 / 80 ms,
  focus bàn phím hiện ngay, bấm thì giấu; ưu tiên vẽ 200.

**Lệch spec** (đã ghi `plan/confirm.md`): Dialog khai báo thay `Dialog::open(…)`; `.with_tooltip(id, text)` thay
`.tooltip(text)`; tự dựng định vị / Popover / Dialog thay bọc gpui-base (Popup không lật, Dialog gán Enter = Confirm);
không mũi tên, chỉ mờ dần; nền tối Popover có viền 1 px.

**Kiểm**: `cargo build` · `clippy --all-targets -D warnings` · `cargo test` (lib: 12 test `position` + 5 `stack`;
`ui-tests/tests/overlay.rs` 8 test — C2 / C3 / C4 / C5 + bấm lại trigger + bấm nền) · `deny check licenses` · `cargo
tree -i gpui-component` (không có). Kiểm đột biến: cho `closes_on_press` luôn `true` ⇒ 3 UI test đỏ (test bắt đúng
luật ngăn xếp). `[opus-run]` (`gallery-run.ps1`, release, không giành focus): góc trên-trái `left-start → right-start`,
trên-phải `top-start → left-start`, dưới-trái `bottom-start → top-start`, dưới-phải `right → left-center` (kéo lên);
Dialog: Tab Tab Space mở Popover trong, Esc đóng Popover, Tab ×5 vẫn trong Dialog, Esc đóng Dialog, focus về "Open
dialog" (có vòng focus + tooltip hiện vì về bằng phím); Tooltip: rê 60 ms không hiện, 450 ms hiện. RAM trang
`overlay` 15,7 MB sau khi mở / đóng hết (trang trống ~14,7).

**Cỡ**: ~1 280 dòng code lib (không test / comment) + 186 gallery — vượt trần 900: hai `Element` tự dựng (`Anchored`,
`LayerScope`) + lớp GPUI của `stack`. Đã code xong, liền mạch ⇒ không tách.

**Bẫy đã gặp**:
- Phần tử trong `deferred` vẫn LAYOUT như con của chỗ đặt nó (trigger) ⇒ tooltip ngắt dòng theo bề ngang nút. `Anchored`
  đặt bề ngang = cửa sổ, cột căn đầu ⇒ con co theo nội dung (`max-content`).
- `on_mouse_down_out` của GPUI xét bounds phần tử, không xét tầng ⇒ bấm vào popover con nằm ngoài popover cha sẽ đóng
  cha — phải hỏi `stack::closes_on_press`.
- Máy chủ dự án đang TẮT Windows "Animation effects" ⇒ `cx.reduce_motion()` = true, mọi `motion::transition` nhảy thẳng,
  `GALLERY_FRAME_STATS` không in dòng nào ⇒ không đo được độ mượt ở máy này.
- `gallery-run --keys`: sau bước chuột KHÔNG nghỉ — `down@ up@ escape` liền nhau thì Esc tới trước khung đầu; chèn
  `wait@300`.
- `cargo fmt` không đối số format cả crate (đã chạm `list.rs`, `scroll.rs` của làn khác — đã khôi phục) ⇒ dùng
  `cargo fmt -- <tệp của mình>`.
- `.debug_selector(…)` có ở mọi build (no-op ngoài test-support) ⇒ đặt trong lib được cho UI test (`materiant-tooltip`).

**Chờ kiểm tay** (`[owner-qa]`, ghi `plan/_backlog.md`): C5 bằng mắt; bật lại Animation effects ⇒ xem mờ dần 140 / 160
ms + `GALLERY_FRAME_STATS=1` (mong 60 fps); Popover nền tối có viền (đề xuất 1).

**Đề xuất đã làm**: 1 (viền nền tối), 2 (`Popover::disabled`).

## 10. Đề xuất cải tiến

1. `[ux]` Popover nền tối lẫn vào trang — ảnh `overlay-tr` (panel `surface` trên nền `surface`, bóng không thấy) — viền
   1 px `border` khi tối — rõ ranh giới panel — S — P1. **Đã làm.**
2. `[ux]` Trigger bị tắt vẫn mở popover — `popover.rs` (bắt chuột / phím ở khung bọc, không biết nút con `disabled`) —
   `impl Disableable for Popover` — tránh mở panel từ nút xám — S — P1. **Đã làm.**
3. `[ux]` Modal không chặn phím tắt của view cha — gallery: ↑ / ↓ (ngữ cảnh `Gallery`, tổ tiên trong cây dispatch) vẫn
   đổi trang khi Dialog mở — cần cơ chế GPUI chặn binding của tổ tiên (vd ngữ cảnh Dialog gán `NoAction` cho danh sách
   phím app khai) — tránh thao tác "xuyên" modal — M — P2. Chưa làm: cần quyết định cách app khai phím toàn cục.
4. `[ux]` Dialog mở chỉ focus khung, chưa focus control đầu (web `showModal()` focus control đầu) — `dialog.rs`
   `open()` — tuỳ chọn `.initial_focus(&FocusHandle)` — người dùng phím đỡ một Tab — S — P2. Chưa làm: handle tạo trước
   control (cần thiết kế API cùng ô nhập gd1_04).
5. `[ram]` Mỗi `with_tooltip` giữ một entity + `FocusHandle` (web: một panel dùng chung) — `tooltip.rs` — danh sách
   nghìn dòng có tooltip thì tốn; dùng chung một state theo cửa sổ — S — P3.
6. `[ux]` Tooltip bọc phần tử không focus được: bấm vùng bọc làm khung bọc nhận focus (GPUI focus phần tử
   `track_focus` khi bấm) — `tooltip.rs` — chỉ dò focus, không nhận focus khi bấm — S — P3.
- `[bảo mật]` không áp (không tệp, không IPC). `[pro]` không áp (component nền).
