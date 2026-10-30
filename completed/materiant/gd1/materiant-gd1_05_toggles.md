# materiant-gd1_05 — Checkbox, Radio, Switch

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
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
  `completed/materiant/gd1/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- `Checkbox` trên primitive cùng tên của `gpui-base`: checked / unchecked / indeterminate (icon `minus`), nhãn bấm
  được, disabled, ripple tròn quanh ô.
- `Radio` + `RadioGroup`: ↑ ↓ / ← → đổi lựa chọn trong nhóm, Tab vào nhóm rơi vào mục đang chọn.
- `Switch`: thumb trượt có animate (`gpui_base::motion`), Space bật / tắt, tắt animate khi OS giảm chuyển động.
- Màu chọn = primary (hoặc màu nhấn khác), đúng sáng / tối.

## 2. Không làm trong task này

- Nhóm checkbox có "chọn tất cả" (GĐ2 nếu cần). Không sửa `style.rs` / `icon.rs`.

## 2b. Phân vai

| Phần việc | Vai |
| --- | --- |
| `checkbox.rs` (+ `state_layer` dùng chung), `radio.rs` (điều hướng, action + key context), `switch.rs` (motion) | `[opus]` |
| Trang gallery `toggles.rs`, test UI `ui-tests/tests/toggles.rs` | `[opus]` — task S, giao Sonnet tốn hơn tự làm |
| So trang `toggles` với tài liệu materiant web | `[owner-qa]` |

## 3. Interface

`Checkbox::new(id).checked(CheckState).label(…).on_change(…)`; `RadioGroup::new(id).items(…).selected(ix)
.on_change(…)`; `Switch::new(id).on(bool).on_change(…)`; `.accent(Accent)` chung.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\form\ui\src\lib\` — `checkbox/` (cả `checkbox-field`, `checkbox-group` để
  lấy số đo), `radio/`, `switch/`. README / API.md của `form`.

## 5. Đo

—

## 6. Nghiệm thu

- **C1** `[opus-unit]` + `[opus-unit]` UI — Cho nhóm radio 4 mục, mục 1 disabled, đang chọn mục 2 / Khi Tab vào nhóm
  rồi ↓ ↓ ↓, ↑ ↑, Home, End ← → / Thì Tab rơi vào mục 2; ↓ ở mục cuối quay về đầu, bỏ qua mục 1; Home / End tới
  mục bật đầu / cuối; ↓ gán ở ngữ cảnh ngoài (như gallery đổi trang) không chạy; Tab kế ra khỏi nhóm (một điểm dừng).
  Chưa chọn mục nào ⇒ Tab rơi vào mục bật đầu. (`radio.rs` tests, `ui-tests/tests/toggles.rs`)
- **C2** `[opus-unit]` UI + `[opus-run]` — Cho checkbox lửng, checkbox / switch disabled / Khi Tab + Space / Enter,
  bấm chuột trong gallery / Thì lửng ⇒ tick ⇒ bỏ, switch bật ⇒ tắt, mục disabled không nhận focus, không đổi.
- **C3** `[opus-run]` — Cho gallery trang `toggles` / Khi Ctrl+T sáng ↔ tối, đổi màu nhấn, Space trên switch chụp
  giữa chừng (`shot@half`) / Thì màu ô / track theo màu nhấn, đúng hai nền; thumb ở giữa quãng lúc 100 ms; giảm chuyển
  động ⇒ thumb nhảy thẳng (motion tự kiểm `cx.reduce_motion()` — gpui-base đọc "Animation effects" của Windows).
- **C4** `[owner-qa]` so trang `toggles` với tài liệu materiant web.

## 7. Ghi chú UI

Trang `toggles`: ba cột (Checkbox · Radio · Switch), mỗi cột đủ trạng thái + disabled, một hàng đổi màu nhấn.

## 8. Nợ chuyển task khác

- **gd1_10**: gọi `materiant::radio::init(cx)` trong `materiant::init` (`lib.rs`) — hiện `RadioGroup` tự gán phím ở lần
  vẽ đầu (cờ `Global`), đúng nhưng gán muộn hơn app có thể mong.
- **gd1_10**: `state_layer` / `child_id` / `fire_on_activate` (`checkbox.rs`, `pub(crate)`, radio dùng chung) — dời lên
  `style.rs` nếu component khác (chip, list item chọn) cần vòng phản hồi tròn. Hằng `SWITCH_WAVE_*` (6 px, 450 ms,
  0,6) dời lên `style.rs` nếu cần dùng chung.
- **gd1_08 / gd1_09** (menu, select, tabs — phím mũi tên): binding của app thắng `on_key_down` ⇒ điều hướng bằng action
  + key context riêng, mẫu `radio.rs`; Space / Enter kích hoạt ở key-UP (test: `simulate_event` down + up).
- **gd1_10**: sửa `materiant/CLAUDE.md` mục "Viết component" — "chỉ animate ripple, thumb switch, popup" ⇒ thêm dấu
  checkbox, chấm radio, vành sóng switch (chủ dự án nới 30/10/2026).

## 9. Bàn giao thực tế

- **Đã làm** (`materiant` nhánh `claude/gd1_05`): `checkbox.rs` — `Checkbox` + `CheckState` (`From<bool>`, `toggled`),
  ô 18 px viền 2 / bo 4, vòng phản hồi 40 px (hover cả hàng qua nhóm `materiant-control`, focus chỉ khi bàn phím —
  `window.last_input_was_keyboard()`), ripple tâm (màu chữ / màu nhấn khi tick), Space / Enter ⇒ ripple. `radio.rs` —
  `Radio` (dùng lẻ được) + `RadioGroup` (`items`, `selected(impl Into<Option<usize>>)`, `.horizontal()`, `RadioItem`
  `.disabled()`), hàm thuần `navigate` / `tab_stop`, action `SelectNext/Prev/First/Last` gán ở key context
  `MateriantRadioGroup` (thắng ↑ ↓ của gallery), `radio::init` tự gọi ở lần vẽ đầu. `switch.rs` — `Switch` +
  `SwitchGeometry` (38 × 24, thumb 20, quãng 14; nhấn giữ thumb 25, quãng 9), track cross-fade bằng opacity, thumb dịch
  + phình qua `motion::transition` 200 ms `EaseOut`. Cả ba: `.accent(Accent)`, `Disableable`, `.label()`,
  `.accessibility_label()`, `on_change(Fn(&T, &mut Window, &mut App))` — dùng được `cx.listener`.
- **Quyết định trong task**: `on_change` nhận `&T` (như `cx.listener`); `Switch` có `.label()` (web để nhãn ở
  `field-shell`) cách track 8 px; thời lượng dấu / chấm dùng `CONTROL_DURATION_MS` 200 (web: checkbox 180, radio 250).
- **Đề xuất đã làm** (chủ dự án chọn 30/10/2026, nới luật "chỉ animate ripple, thumb, popup"): tick lộ dần trái → phải
  bằng khung cắt + dấu trừ nở từ tâm (`cubic-bezier(.4,0,.6,1)`, ra thì mất ngay như web); chấm radio nhún
  (`cubic-bezier(.34,1.56,.64,1)`) vào, `ease-out` ra; vành sóng switch khi nhả (6 px, 450 ms, 0,6 → 0, màu nhấn). Tất
  cả qua `motion::transition` ⇒ giảm chuyển động thì nhảy thẳng. Ba đề xuất P1 không chọn — ghi lại ở mục 10.
- **Soát**: `cargo build`, `clippy --all-targets -D warnings`, `cargo test` (31 unit — +6: `CheckState`, hình học
  checkbox / switch, `navigate` ×2, `tab_stop` — + 4 theme + 5 ripple + **3 toggles UI** + 1 gallery), `deny` ok,
  `cargo tree -i gpui-component` không có. Sau khi gộp master (gd1_03 / 04 / 06): 66 unit + UI button 3, field 5,
  ripple 6, scroll 7, theme 4, toggles 3 + gallery 1 — xanh; clippy, deny xanh.
- **Chạy thử** (`gallery-run.ps1`, không giành focus, ảnh đã xoá): sáng / tối đúng màu, đổi accent Danger đổi cả trang;
  bấm chuột: lửng ⇒ tick, Bluetooth bật, ba mục disabled không in gì; ↓ ↓ trong nhóm "size" (focus bằng chuột) ⇒
  `RADIO size 3` (bỏ mục khoá), `size 0` (vòng) và trang KHÔNG đổi; nhấn giữ 400 ms ⇒ thumb phình; khung 30–60 ms sau bấm
  thấy tick vẽ dở, chấm nở / co, vành sóng, track cross-fade. Tab vào nhóm accent rơi đúng mục đang chọn. RAM 15,9–17
  MB.
- **Bẫy gặp**: (1) GPUI biến Space / Enter thành click ở **key-up**; `simulate_keystrokes` và `--keys` của gallery chỉ gửi
  key-down ⇒ test dùng `simulate_event(KeyDown + KeyUp)`, chạy thử dùng chuột. (2) Binding của app thắng `on_key_down`
  (dispatch binding trước listener) ⇒ phím mũi tên phải là action + key context sâu hơn. (3) `CARGO_TARGET_DIR` chung với
  làn song song ⇒ xanh giả (mục 10) — gd1_05 build ở `.claude/worktrees/target-gd1_05` (mồi hard link; proc-macro `.dll`
  hard link bị khoá khi làn khác đang nạp ⇒ lần đầu lỗi E0786, chạy lại thì cargo build lại các crate đó).
- **Chờ kiểm tay** (`[owner-qa]`): C4 so trang `toggles` với tài liệu web; C3 nhánh giảm chuyển động (Windows →
  Accessibility → Visual effects → Animation effects = Off, mở gallery trang `toggles`, bật / tắt switch ⇒ thumb nhảy
  thẳng, không ripple).

## 10. Đề xuất cải tiến

- `[ux]` Vòng focus switch ở nền tối gần như không thấy — ảnh gallery tối: vòng `N400 40 %` = rgb(44,52,68) trên nền
  rgb(15,23,42), tương phản ~1,3:1 (WCAG 1.4.11 đòi 3:1) — switch dùng `cx.focus_ring_color()` (primary 50 %, như ô
  nhập / nút) thay `control.focus_ring` — người dùng bàn phím ở nền tối thấy được đang ở công tắc nào — S — P1.
- `[ux]` `--keys` của gallery chỉ gửi key-down (`window.dispatch_keystroke`) mà GPUI biến Space / Enter thành click ở
  key-UP ⇒ chạy thử không bấm được checkbox / switch / nút bằng phím (gd1_05 phải dùng chuột) — `examples/gallery/main.rs`
  gửi thêm `KeyUpEvent` sau mỗi phím — soát `[opus-run]` bàn phím cho mọi component — S — P1 (file cấm làn song song
  ⇒ làm ở gd1_10).
- `[ux]` Bẫy `CARGO_TARGET_DIR` chung giữa worktree song song: cargo băm crate path theo đường dẫn tương đối ⇒ rlib
  `materiant` của làn này đè làn kia, fingerprint báo "Finished" mà không build — **xanh giả** (gd1_05 gặp: cảnh báo của
  `src/button.rs` gd1_03 khi build gd1_05) — ghi vào `materiant/CLAUDE.md` mục Bẫy + skill `run-task` mục 4: làn song song
  dùng target riêng mồi bằng hard link (`cp -al`, 16 s, bỏ `incremental/`) — S — P1.
Chủ dự án chọn 30/10/2026: chỉ dòng 4 + 5 (đã làm — mục 9). Ba dòng P1 không chọn.

- `[ux]` ✅ Chấm radio nhún khi chọn (`cubic-bezier(.34, 1.56, .64, 1)` 250 ms) + dấu tick hiện dần như bản web — bằng
  `motion::transition` (tự tắt khi giảm chuyển động); trái CLAUDE.md "chỉ animate ripple, thumb, popup" ⇒ cần chủ dự án
  nới luật — S — P3.
- `[ux]` ✅ Vành sóng lan ra khi nhả switch (`.switch-wave`, 450 ms) — phản hồi "đã nhận lệnh" như web — S — P3.
- `[ram]` không áp: RAM gallery trang `toggles` 15,9 MB (bằng trang `theme`), không phụ thuộc mới. `[bảo mật]` không áp
  (component không đọc / ghi gì). `[pro]` không áp.
