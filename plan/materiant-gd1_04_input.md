# materiant-gd1_04 — Ô nhập: field-shell, ô chữ, ô số

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) |
| Repo | materiant |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | materiant-gd1_02 · **song song** với gd1_03, gd1_05, gd1_06 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/field/mod.rs` · `src/field/shell.rs` · `src/field/input.rs` · `src/field/number.rs` SỬA · `examples/gallery/pages/input.rs` SỬA |

Task làn song song: **chỉ** sửa các tệp trên. Bàn giao ghi vào gd1_10 (nghiệm thu) + fastcast `gd1_06` (launcher dùng
ô tìm kiếm) qua mục 9.

## 0. Bàn giao từ materiant-gd1_02 (29/10/2026)

<!-- handoff: materiant-gd1_02 -->

- **Đã có sẵn để dùng**: `cx.field_tokens()` → `FieldTokens` (`form.css`): `ink`, `placeholder`, `bg`, `bg_disabled`,
  viền `border` / `border_hover` / `border_focus`, vòng `ring_hover` / `ring_focus`, lỗi `danger` + `danger_ring_hover`
  / `_focus`, cảnh báo `warning` + tương tự. Bo `.radius_field(cx)` (10 px), chữ `.text_body(cx)` / `.text_caption(cx)`
  (gợi ý, lỗi), `.text_muted(cx)`.
- Vòng 3 px quanh ô: ô nhập có nền đục (`bg`) ⇒ `.shadow(ring_shadow(field.ring_focus))` dùng được (mẫu "Focus ring" /
  "Rest / hover" trên trang `style`). Phần tử nền trong suốt thì `ring_overlay` (xem bẫy).
- Icon: `Search`, `Close` (dấu ✕ — spec ghi `x`: Lucide `x` không nhúng vì trùng hình `close`), `CloseThin`,
  `ChevronUp` / `ChevronDown` (nút ↑ ↓ của `NumberField`), `Info`, `Warning`. `Icon::new(..).size(px(16.)).color(..)`.
- Nút xoá nhanh trong ô (icon `Close`): `div().id(..).rounded_full()` rồi `.ripple(RippleConfig::centered())`.
- **Bẫy**: `ring_shadow` là bóng spread — GPUI vẽ cả dưới phần tử; phần tử nền trong suốt bị tô kín ⇒
  `ring_overlay(color, bo_góc)`. `StyledExt` / token nhận `cx`; trong `.hover` lấy `FieldTokens` (`Copy`) trước rồi bắt
  vào closure.
- **Soát lại khi làm**: `cargo test` (25 unit + 4 theme UI + 5 ripple UI + 1 gallery); chạy thử chỉ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page <trang> -Keys "…"` — phím, chuột `down@x,y` / `up@` / `move@`, `wait@ms`,
  `shot@tên` (ảnh giữa chuỗi); toạ độ lấy từ ảnh trừ ~31 px thanh tiêu đề; ảnh xem xong xoá. Token + tên hàm đầy đủ:
  `plan/materiant-gd1_02_style-ripple-icon.md` mục 9; mẫu dùng: `materiant/CLAUDE.md` mục "Style · ripple · icon".

## 1. Làm gì

- `FieldShell`: khung nhãn, gợi ý, lỗi, icon đầu / cuối, trạng thái thường / hover / focus / lỗi / disabled theo token
  ô nhập của gd1_02 (`radius-field` 10 px).
- `TextField` trên `gpui_base::Input`: placeholder, chọn chữ, undo / redo, dán, xoá nhanh (icon `x`), `on_change` /
  `on_submit`. Phím Esc / Enter **không** bị nuốt — app bắt ở pha capture được (bẫy đã gặp ở spike launcher).
- `NumberField` với mask số: min / max / bước, ↑ ↓ tăng giảm, gõ chữ sai bị chặn, dán chuỗi lẫn chữ ⇒ lọc số (FPS
  1–60, cỡ chữ của fastcast).

## 2. Không làm trong task này

- Ô nhiều dòng, ô mật khẩu, ô mã (`code-field`) — GĐ2 nếu cần. Không sửa `style.rs` / `icon.rs`.

## 2b. Phân vai

| Phần việc | Ai |
| --- | --- |
| `field/numeric_mask.rs` (hàm thuần + ca C1), `shell.rs`, `input.rs`, `number.rs` — interface, luồng sự kiện, dán qua mask | `[opus]` |
| Trang gallery `input` | `[opus]` (nhỏ, bám sát interface vừa chốt) |
| `ui-tests/tests/field.rs` theo C3, C5–C7 | `[sonnet]` |
| C4 bộ gõ tiếng Việt | `[owner-qa]` |

## 3. Interface

`TextField::new(id, cx)` (Entity, giữ trạng thái gõ) `.placeholder()` `.label()` `.hint()` `.error(Option<…>)`
`.leading_icon(IconName)` `.clearable(bool)`; `NumberField::new(id, cx).range(1..=60).step(1)`; logic mask
`numeric_mask::apply(input, cfg) -> String` là hàm thuần.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\form\` — `ui/src/lib/field-shell/`, `ui/src/lib/input/`,
  `headless/src/lib/numeric-mask.ts` (+ `numeric-mask.spec.ts` làm nguồn ca), `headless/src/lib/field-state.ts`.
- Mẫu ô nhập không nuốt Esc: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` (launcher).

## 5. Đo

—

## 6. Nghiệm thu

- **C1** `[opus-unit]` Cho `numeric_mask` với ca của `numeric-mask.util.spec.ts` + `headless/numeric-mask.spec.ts`
  (âm, thập phân, dán lẫn chữ, `max_digits` / `max_decimals`, caret) và `number::mask_config` / `paste_into` /
  `step_value`. Khi `cargo test -p materiant`. Thì mọi ca khớp số của bản TS; `1..=60` chặn `600`, `-1`, `1.5`; dán
  `"fps: 3a0"` ⇒ `30`; `step_value` ở biên trả `None`.
- **C2** `[opus-run]` Cho gallery trang `input` qua `tools/gallery-run.ps1`. Khi bấm vào ô, gõ, Shift+← chọn chữ,
  Ctrl+Z / Ctrl+Y, Ctrl+V, bấm ✕; ô FPS ↑ tới 60 rồi ↑ thêm. Thì log `CHANGE …` đúng từng bước, ô FPS dừng ở `60`.
- **C3** `[opus-run]` + `[sonnet-test]` Cho ô nhập đang focus. Khi bấm Esc / Enter. Thì listener capture của trang
  (`ESC capture`) và listener bubble (`ESC bubble`) đều nhận; Enter phát `on_submit` và vẫn tới cha.
- **C4** `[owner-qa]` gõ Unikey / EVKey (Telex) + IME tiếng Việt của Windows: "Tiếng Việt có dấu" không mất / nhân
  đôi ký tự.
- **C5** `[sonnet-test]` Cho `TextField` focus. Khi `simulate_input("abc")`, `ctrl-z`, `ctrl-y`, `clear()`. Thì
  `on_change` / `FieldEvent::Change` nhận `abc` → rỗng / bớt → `abc` → rỗng; `set_value` không phát `Change`.
- **C6** `[sonnet-test]` Cho `NumberField` `range(1..=60)` giá trị 59, focus. Khi `up` ×3, `down` ở 1, gõ `a`, dán
  `"x4y2"`. Thì 60 → 60 (dừng), 1 → 1, `a` bị chặn, dán ra `42`.
- **C7** `[sonnet-test]` Cho `NumberField` `range(10..=20)` gõ `5` rồi rời ô (blur). Thì giá trị kẹp về `10`.

## 7. Ghi chú UI

Trang `input`: ô thường, có nhãn + gợi ý, đang lỗi, disabled, có icon search + xoá, NumberField.

## 8. Nợ chuyển task khác

- `FIELD_HEIGHT` (32 px), `FIELD_PADDING_X` (12 px), `FIELD_ICON_SIZE` (16 px) là hằng cục bộ ở `field/shell.rs`
  ⇒ dời lên `style.rs` khi có task được sửa nó (gd1_10 hoặc GĐ2). Cỡ `lg` (38 px, `FIELD_HEIGHT_CLASS.lg`) chưa port.
- `NumberField` chưa có separator nhóm (`1,000`) và chỉ nhận dấu thập phân `.` — đủ cho FPS / cỡ chữ; `numeric_mask`
  đã có `group` + caret nếu GĐ2 cần (gpui-base có `MaskPattern::Number { separator }` để định dạng khi gõ).

## 9. Bàn giao thực tế

- **Code** (`materiant/src/field/`): `shell.rs` — `FieldShell` (RenderOnce: nhãn, gợi ý, lỗi / cảnh báo, icon đầu,
  phần tử cuối, 3 nấc nghỉ → hover → focus theo `FIELD_STATE_CLASS_MAPPED`), `FieldStatus`; `input.rs` — `TextField`
  (Entity, `gpui_base::Input`), `FieldEvent::{Change, Submit}`; `number.rs` — `NumberField` (`gpui_base::NumberInput`,
  nút ↑ ↓ chồng ở cuối, mờ khi chạm biên), `mask_config`, `paste_into`; `numeric_mask.rs` — port
  `numeric-mask.util.ts` (`sanitize`, `group`, `apply`, `is_valid`, `parse`, `to_parsable` / `from_parsable`,
  `count_significant` / `find_caret`). `mod.rs` re-export ⇒ app viết `materiant::field::TextField`.
- **Đổi so với spec**: `TextField::new(id, window, cx)` / `NumberField::new(id, window, cx)` — `InputState` của
  gpui-base cần `window`. Builder không có `cx` ⇒ placeholder / giá trị / min-max-step ghi lại, áp ở khung vẽ đầu
  (`sync`). Setter lúc chạy: `set_value`, `set_error`, `set_warning`, `set_disabled`, `clear`; `input_state()` lộ
  `Entity<InputState>` (chọn chữ, caret). Thêm `.warning(…)`, `.default_value(…)`, `.disabled(…)`, `NumberField::decimals`.
- **Esc / Enter / ↑ ↓**: ô một dòng xử lý rồi `propagate` ⇒ capture lẫn bubble của cha đều nhận (C3 xanh cả chạy
  thật lẫn test). ↑ ↓ trong `TextField` cũng tới cha (ở gallery là đổi trang) — đúng ý cho launcher (↑ ↓ chọn kết
  quả). Trong `NumberField` ↑ ↓ là tăng giảm, không tới cha.
- **Lỗi đã sửa trong task**: (1) Enter ở ô một dòng làm `InputState` phát `Change` dù chữ không đổi (ký tự `\n` vẫn tới
  bộ nhận chữ rồi bị lọc) ⇒ hai ô so với `last_value`, chỉ phát khi đổi thật. (2) Kẹp min / max khi rời ô không báo
  `on_change`: bước kẹp của gpui-base sửa chữ "im lặng" ⇒ `NumberField` nhận `InputEvent::Blur` thì tự kẹp
  (`replace_all`: vào undo) rồi báo `Change` nếu chữ đã khác lần báo trước.
- **Bẫy GPUI**: focus / blur chỉ phát cho cửa sổ **đang active** (`Window::finish` bỏ `previous_focus_path` khi cửa sổ
  không active). C7 đỏ lúc đầu vì cửa sổ test chưa active ⇒ helper test gọi `window.activate_window()`. Gallery chạy
  `--background` (không giành focus) nên KHÔNG kiểm được blur bằng chạy thật ⇒ thêm bước kiểm tay dưới.
- **Đề xuất đã làm** (mục 10): bấm nhãn ⇒ focus vào ô.
- **Chủ dự án vắng** — các lựa chọn thay chủ dự án ghi ở `plan/confirm.md` mục materiant (`[materiant-gd1_04]`).
- **Dán ô số**: `capture_action::<Paste>` ở gốc `NumberField` lọc clipboard qua mask (bộ chặn gõ của `InputState` xét
  cả chuỗi nên sẽ từ chối nguyên chuỗi lẫn chữ), caret đặt sau phần vừa dán.
- **Cho fastcast** (`gd1_06` launcher dùng ô tìm): `materiant::field::TextField::new(id, window, cx)` +
  `.placeholder().leading_icon(IconName::Search).clearable(true).on_change().on_submit()`; Esc / Enter / ↑ ↓ tới cha
  (bắt bằng `on_key_down` hay `capture_key_down` của launcher); chữ hiển thị (placeholder) app truyền từ catalog i18n.
- **Cho gd1_09** (select): khung trigger dùng lại được `materiant::field::FieldShell::new(id, nội_dung)` + `.trailing(chevron)`
  + `.focused(…)` — cùng viền / vòng / nhãn / lỗi với ô nhập.
- **Chạy thật** (`gallery-run.ps1 -Page input`, exe `target/gd1_04/release`): gõ `hello`, Shift+← ×2, `x` ⇒ `helx`;
  Ctrl+Z ×2 ⇒ `hello` → rỗng; Ctrl+Y ×2 ⇒ `hello` → `helx`; Esc ⇒ `ESC capture` + `ESC bubble`; Enter ⇒
  `SUBMIT plain helx`; ✕ ⇒ `CHANGE search` rỗng; FPS Ctrl+A `58` ↑↑↑ ⇒ 59, 60, (dừng); `a` bị chặn; nút ↑ mờ ở 60.
  `foreground_unchanged=True`. RAM trang input 16,3 MB (trang theme 15,9 MB ở gd1_01). Không thử Ctrl+V trên máy
  thật (sẽ đọc clipboard của chủ dự án) — dán phủ bằng C6 với clipboard giả. Ảnh đã xoá.
- **Test**: C1 14 unit (`numeric_mask` 11, `number` 3); C3 / C5 / C6 / C7 ở `ui-tests/tests/field.rs` (Sonnet viết,
  Opus sửa C7 + thêm assert "Enter không phát Change").
- **Bẫy**: `CARGO_TARGET_DIR` dùng chung giữa worktree ⇒ cargo coi lib của worktree khác là "Fresh" (dep-info ghi
  đường dẫn tương đối) — đã chuyển `target/gd1_04` riêng theo điều phối; ghi chú ở thư mục ghi chú chung.
- **Chờ kiểm tay** (C4 `[owner-qa]`): gõ Unikey / EVKey Telex + IME tiếng Việt của Windows vào các ô trang `input`:
  "Tiếng Việt có dấu" không mất / nhân đôi ký tự; ô số gõ Telex không chèn chữ. Thêm: ô FPS gõ `99` rồi bấm ô khác
  ⇒ về `60`; bấm nhãn "Display name" ⇒ con trỏ vào ô. Lệnh: `pwsh start.ps1 docs input` (hoặc
  `cargo run --example gallery -- --page input`).

## 10. Đề xuất cải tiến

Soi sau khi xanh (chủ dự án vắng — session tự chọn theo điều phối 30/10/2026):

- [ux] Bấm nhãn không đưa focus vào ô (bản web `<label for>` có) — `shell.rs` nhãn chỉ là chữ — nhãn cũng
  `on_mouse_down` ⇒ focus — S — P2. **Đã làm** (cùng closure với khung).
- [ux] Dán số có dấu trừ Unicode (U+2212, hay gặp khi chép từ tài liệu) / chữ số full-width bị bỏ —
  `paste_filters_digits` — chuẩn hoá về ASCII trong `sanitize` — S — P3. **Bỏ**: lệch bản web, hiếm với FPS / cỡ chữ.
- [ux] Cỡ `lg` 38 px cho ô tìm kiếm của launcher (fastcast gd1_06) — `FIELD_HEIGHT_CLASS.lg` chưa port — `FieldSize` +
  builder `.large()` — S — P3. **Chưa làm**: chờ fastcast gd1_06 chốt kích thước launcher (mục 8).
- [ux] Dòng lỗi hiện / ẩn tức thì (bản web trượt vào 200 ms) — `materiant/CLAUDE.md` chỉ cho animate ripple / thumb /
  popup — S — P3. **Bỏ**: trái luật animation của repo.
- [ram] / [bảo mật] / [pro]: không áp — ô nhập không giữ tệp / IPC, mỗi ô một `InputState` (RAM trang 16,3 MB, ngang
  các trang khác); chưa có tính năng nâng cao hợp huy hiệu Pro.
