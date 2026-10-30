# materiant-gd1_03 — Button, IconButton, Kbd

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
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

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `src/button.rs` (bảng màu thuần `ButtonPaint`, lõi chung Button / IconButton, ripple + focus-visible + spinner) | `[opus]` |
| `src/kbd.rs` (`split_keys`, `mac_symbol`, chip) | `[opus]` |
| `examples/gallery/pages/button.rs`, `ui-tests/tests/button.rs` | `[opus]` — trang nhỏ, phải soát bằng ảnh cùng lúc với component; giao Sonnet tốn lượt hơn tự làm |
| So trang `button` với tài liệu web | `[owner-qa]` |

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

- **C1** `[opus-unit]` — Cho 6 dáng × 5 màu (4 màu nhấn + `#0f766e`) × sáng / tối. Khi tính `ButtonPaint::resolve`.
  Thì `filled` hover / active = nền trộn oklab 12 % trắng / đen; `tonal` alpha 12 / 20 / 26 %; `outlined` / `dashed` viền
  40 / 70 / 100 %, nền 0 / 9 / 12 %; `text` nền 0 / 9 / 12 %; `elevated` nền ngả 6 / 10 % màu chữ; màu `base` nghỉ = màu
  chữ, rê / nhấn = token `primary`; `disabled` dáng `text` bỏ nền + viền. (`button::tests`)
- **C2** `[opus-unit]` — Cho `"Ctrl+Shift+1"`, `"Alt+Space"`, `"+"`, `"Ctrl++"`, `"Ctrl + K"`. Khi `split_keys`. Thì
  `[Ctrl, Shift, 1]`, `[Alt, Space]`, `[+]`, `[Ctrl, +]`, `[Ctrl, K]`; `mac_symbols(true)` ⇒ ⌘ ⌥ ⇧ ⌃ ↩, tắt thì giữ chữ.
  (`kbd::tests`)
- **C3** `[opus-run]` + `[opus-unit]` — Cho trang `button`. Khi mở sáng / tối, đè chuột nút thường, bật "Start
  loading" rồi bấm nút loading. Thì đủ ma trận dáng × màu × 3 cỡ, ripple hiện khi đè, nút loading không in `CLICK`.
  Tự động: `ui-tests/tests/button.rs::inactive_buttons_ignore_pointer`, `leaving_loading_unlocks`.
- **C4** `[opus-unit]` (UI test) + `[opus-run]` — Cho hàng nút `a` · `disabled` · `loading` · `b`. Khi Tab, Space, Tab,
  Enter, Shift+Tab, Enter. Thì `on_click` nhận `a key`, `b key`, `a key` (bỏ qua hai nút không bấm được). Gallery:
  Tab tới đúng nút + vòng focus (`--keys` của gallery chỉ gửi KeyDown nên Space / Enter chỉ phủ bằng UI test).
- **C5** `[owner-qa]` — so trang `button` với tài liệu materiant web: số đo, màu hover / active, vòng focus chỉ hiện khi
  dùng bàn phím (chuột bấm không có vòng).

## 7. Ghi chú UI

Trang `button`: lưới hàng = dáng, cột = màu, ba khối theo cỡ; hàng `loading` / `disabled`; hàng `Kbd`.

## 8. Nợ chuyển task khác

- **Dời hằng cục bộ lên `style.rs`** (gd1_10, khi hết làn song song được sửa `style.rs`): `button.rs` — `RADIUS` 6,
  `GAP` 6, `SPINNER_PERIOD` 1 s, `ICON_BUTTON_ICON_RATIO` 0,625, `ICON_BUTTON_SPINNER_RATIO` 0,55,
  `ELEVATED_HOVER_MIX` / `_ACTIVE_MIX` 6 / 10 %, `SHADOW_ALPHA` 0,1 (`--shadow-1`); `kbd.rs` — `CHIP_HEIGHT` 20,
  `CHIP_MIN_WIDTH` 20, `CHIP_PADDING_X` 5, `CHIP_RADIUS` 4, `CHIP_GAP` 4. `button::optical_lift` (căn thân chữ trong hộp
  `line_height = 1`) đáng thành helper chung của `style.rs` cho mọi component có chữ trong khung cao cố định.

## 9. Bàn giao thực tế

Xong 30/10/2026. Commit materiant `6973d8e` (component + gallery + test), `33c2ef0` (đề xuất 4), gộp `master` ở `d8b6af2`.ở `d8b6af2`.

- **API** (`materiant::button`): `Button::new(id, label)` / `IconButton::new(id, IconName)`; dáng `.text()` `.filled()`
  `.tonal()` `.outlined()` `.dashed()` `.elevated()` / `.variant(Variant)`; màu `.primary()` `.danger()` `.warning()`
  `.success()` `.base()` `.color(hsla)` / `.accent(Accent)` / `.button_color(ButtonColor)`; `.size(Size::{Lg, Md, Sm})`;
  `.loading(bool)` `.disabled(bool)` (method thường + trait `Disableable`); `.icon()` `.icon_end()` (Button);
  `.on_click()` `.accessibility_label()` `.tab_index()`. Cả hai `impl Styled` ⇒ `.rounded_full()`, `.w(px(240.))`,
  `.absolute()`… đè lên mặc định; ripple + vòng focus đọc bo góc SAU style của app. Mặc định: Button `filled`,
  IconButton `text`, `primary`, `md`. `Size::height()` (38 / 32 / 24) dùng lại được cho component khác.
- Hàm thuần: `ButtonPaint::resolve(variant, rest, hot, surface, text, dark)` → `{rest, hover, active}` mỗi cái
  `Paint {bg, ink, border}`; `ButtonPaint::disabled`; `elevated_shadow(hover)`; `ButtonColor::tokens(cx)` (màu `base`:
  nghỉ = token màu chữ, rê / nhấn = token primary). `materiant::kbd`: `Kbd::new(&str)` `.mac_symbols(bool)` `.labels()`,
  `split_keys`, `mac_symbol`.
- **Khác spec / web (có chủ đích)**: cỡ tính bằng `rem` (32 px = 2 rem ở cỡ chữ 14) ⇒ co giãn theo Cỡ chữ; vòng focus
  giữ bo góc của nút (web ép 4 px) và luôn vẽ bằng `ring_overlay` (một đường cho mọi dáng, không đè bóng `elevated`);
  `loading` luôn có vòng quay và THAY icon trái (web đứng cạnh); `loading` bỏ khỏi Tab như `disabled`; icon trong
  IconButton = 62,5 % cạnh (trang demo web `size-5` trong 32 px), vòng quay 55 %; quay bằng `with_animation` +
  `Transformation::rotate` (1 vòng / s), giảm chuyển động ⇒ đứng yên; `elevated` nền tối ngả 4 % (đề xuất 4).
- **Chữ lệch xuống (chủ dự án báo 30/10)**: `gpui_base::Button` ép `line_height = 1`; GPUI căn baseline theo ascent /
  descent nên thân chữ thấp ~2,3 px (Segoe UI 14 px, chữ thường). `button::optical_lift(window, font_size)` đẩy nhãn lên
  để tâm hộp nằm giữa baseline và trung bình cap-height / x-height (1,6 px ở 14 px); chip `Kbd` dùng chung. **Bẫy**:
  `TextSystem::descent` của DirectWrite trả số ÂM (−3,51 px) — lấy `.abs()`; bản đầu coi dương nên đẩy 5 px.
- Ca: C1 C2 `[opus-unit]` xanh (5 test `button::tests`, 2 `kbd::tests`); C3 gallery sáng / tối đủ ma trận, ripple khi
  đè, bấm nút loading không in `CLICK` + UI test `inactive_buttons_ignore_pointer`, `leaving_loading_unlocks`; C4 UI test
  `tab_skips_inactive_and_space_enter_press` xanh, gallery Tab tới đúng nút + vòng focus. Space / Enter KHÔNG thử được
  qua gallery: GPUI sinh click bàn phím ở KeyUp, `--keys` chỉ gửi KeyDown (đề xuất 2 → gd1_10). C5 `[owner-qa]` chờ
  kiểm tay. Lưu ý UI test: cửa sổ chưa có gì focus thì Tab của `Root` không chạy — test bấm chuột vào nút đầu trước.
- Soát: `cargo build`, `clippy --all-targets -D warnings`, `cargo test` (32 unit + 3 button + 5 ripple + 4 theme +
  gallery), `deny check licenses` ok, `cargo tree -i gpui-component` không có. RAM gallery trang `button` (~250 nút,
  release, `-p materiant`) 22,6–22,9 MB.
- **Bẫy môi trường**: nhiều worktree dùng chung `CARGO_TARGET_DIR=materiant/target` ⇒ cargo băm metadata gói path
  không theo đường dẫn, các làn build cùng lúc ĐÈ `libmateriant-*.rlib` của nhau (`unresolved import
  materiant::button::Button` dù code đủ). Làn này chuyển sang target riêng `.claude/worktrees/materiant-gd1_03-target`
  (build nguội: test 5m48s, release 15m37s khi 3 làn khác cùng build). Ghi chú cho các làn khác ở thư mục notes chung.
- Lần chạy thử đầu: gallery thành foreground + 4 `CLICK lg-filled-primary mouse` dù không gửi phím — nhiều khả năng
  chủ dự án bấm thật vào cửa sổ ở màn phụ (các lượt sau `foreground_unchanged=True`). Có lượt màn phụ không còn
  (`--display Secondary: not found`) ⇒ cửa sổ mở ở màn chính, vẫn không giành focus.
- Đề xuất đã làm: 4 (`elevated` nền tối). Đề xuất 1, 3 chủ dự án không chọn; 2 không chọn (nếu làm thì ở gd1_10).

### Sửa sau phản hồi của chủ dự án (30/10/2026, nhánh `claude/gd1_03-fix`, commit `4bde0dc`)

- **"Màu chưa đúng"** — so cả 288 ô (6 dáng × primary / base / danger / warning / success / `#0f766e` × nghỉ / rê / nhấn
  / disabled × sáng / tối) với Chrome: trang HTML dùng `btn.css` gốc (`:hover` / `:active` đổi thành class), theme
  Black Pink, đọc `getComputedStyle` rồi đổi oklab → sRGB. Khớp ≤ 1/255 mọi ô, trừ (a) chữ primary nền tối: web
  `r = 1,027` ngoài gam, màn hình cắt về 1,0 — như nhau; (b) nền `elevated` tối lúc nghỉ — đề xuất 4, cố ý. 7 số tham
  chiếu Chrome giữ lại trong `button::tests::matches_chrome_reference`. Khác thật là **bảng màu**: trang tài liệu web ở
  theme "Mặc định" dùng màu dự phòng (deeppink, `oklch(58.6% .253 17.585)` = `#ec003f`, `#faad14`, `#52c41a`, cùng
  mã cho hai nền), gallery dùng Black Pink (gd1_01). Trang `button` có nút **Palette** đổi bốn màu nhấn giữa hai bảng để
  so 1:1 (ghi `plan/confirm.md`).
- **"Đủ theo button type"** — thêm `.selected(bool)` (dáng `elevated` đang bật ⇒ nền màu gốc, rê / nhấn không đổi — như
  `aria-pressed="true"`; `ButtonPaint::pressed`); gallery thêm hàng chip `elevated` bật / tắt và ma trận **IconButton
  đủ 6 dáng × 6 màu × 3 cỡ** (trước chỉ 2 icon mỗi hàng).
- **"Bóng elevated quá mờ"** — web `--shadow-1` là đen 10 % nền sáng / **20 % nền tối** (`libs/ui/styles/theme.css`),
  bản trước dùng 10 % cho cả hai. `elevated_shadow(hover, dark)` theo đúng hai mức.
- **Ripple bấm liên tục** — phía Button không dựng lại lớp ripple: id lớp chứa (`NamedChild(id, "ripple-layer")`) và
  khoá `use_keyed_state` cố định, lớp chứa luôn gắn khi nút bấm được. UI test `rapid_clicks_keep_earlier_waves`: 3 lần
  bấm cách 60 ms ⇒ 3 vòng cùng sống, 1 s sau mờ hết. Lỗi chủ dự án thấy (nếu còn) ở lõi `effect/ripple.rs` — session cha
  soát ở `claude/ripple-multi`.
- **Bẫy**: `cargo fmt --all` trong worktree định dạng lại cả tệp của làn khác (`scroll.rs`, `list.rs`…) — chỉ commit tệp
  của mình, `git checkout --` phần còn lại. Build ở `CARGO_TARGET_DIR=materiant/target/gd1_03` riêng; soát exe đúng bản
  bằng `grep -a -c "Elevated chips" …/gallery.exe`.
- Soát: clippy sạch, `cargo test` (61 unit + 4 UI button + các làn đã gộp), `deny` ok; RAM trang `button` 22–27 MB
  (thêm ~110 IconButton).

## 10. Đề xuất cải tiến

Bảo mật: không áp (không tệp, IPC, dữ liệu người dùng). RAM: không áp — vòng quay chỉ xin khung khi đang `loading`,
giảm chuyển động thì đứng yên; trang `button` (~250 nút) 22,8 MB.

1. `[ux]` Nút `loading` phình ngang vì vòng quay chen vào trước chữ — ảnh trạng thái "Start loading": cả hàng dời phải
   ~130 px, nút cạnh đó chạy khỏi con trỏ — giữ bề ngang: vòng quay đè lên giữa nút, chữ ẩn (`visibility`) như
   `loadingPosition="center"` của MUI; nút có icon trái thì vẫn thay icon như hiện tại — không nhảy bố cục khi bấm Lưu —
   S — P1.
2. `[ux]` `--keys` của gallery chỉ gửi KeyDown (`main.rs`, `window.dispatch_keystroke`) mà GPUI sinh click bàn phím ở
   KeyUp (`gpui-pre` `elements/div.rs` ~3099) ⇒ Space / Enter không chạy thử được qua `gallery-run.ps1` (C4 phải dựa UI
   test) — `--keys` gửi KeyDown + KeyUp cho phím thường — mọi task sau chạy thử bàn phím được — S — P2. `main.rs` là tệp
   chung, làn song song không sửa ⇒ ghi vào gd1_10.
3. `[ux]` Menu (gd1_08) lấy phím tắt từ keymap GPUI (`keystroke_text_for` → dạng `ctrl-shift-p`), `Kbd::new` chỉ tách
   theo `+` — thêm `Kbd::from_keystroke(&Keystroke)` (đọc `modifiers` + `key`, tự chọn ký hiệu mac theo nền tảng) —
   gd1_08 khỏi tự đổi chuỗi — S — P2.
4. `[ux]` `elevated` trên nền tối gần như không khác `text`: bóng đen 10 % mất trên nền tối (ảnh trang `button` chế độ
   Dark) — nền tối thì nền nút ngả 4 % màu chữ (lớp phủ độ cao kiểu Material dark) — S — P3.
