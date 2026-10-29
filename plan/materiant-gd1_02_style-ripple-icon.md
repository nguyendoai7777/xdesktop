# materiant-gd1_02 — Style token, Ripple, `.drag_region()`, Icon

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (29/10/2026) |
| Repo | materiant |
| Cỡ | M — ~700 dòng |
| Phụ thuộc | materiant-gd1_01 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — (SVG Lucide chép vào repo — ISC, ghi nguồn + giấy phép ở `assets/icons/LICENSE-lucide`) |
| File đụng tới | `src/style.rs` SỬA · `src/effect/mod.rs` + `src/effect/ripple.rs` SỬA · `src/window.rs` SỬA · `src/icon.rs` SỬA · `assets/icons/*.svg` MỚI · `src/lib.rs` SỬA (đăng ký asset) · `examples/gallery/pages/style.rs` SỬA |

## 0. Bàn giao từ materiant-gd1_01 (29/10/2026)

<!-- handoff: materiant-gd1_01 -->

- **Đã có sẵn để dùng** (`materiant::theme`): `cx.theme()` (trait `ActiveTheme`) → `colors()` = `ThemeColors` đã giải
  theo nền: `primary` / `on_primary`, `danger` / `on_danger`, `warning` / `on_warning`, `success` / `on_success`,
  `surface`, `text`, `muted`, `border`, `input` / `input_hover` / `input_focus`, `primary_ink`, `series[8]`,
  `neutral(Neutral::N50…N900)`. Kèm `font_size()`, `caption_size()`, `radius_field()` (10 px), `shadow_card_md()` /
  `shadow_card_2xs()`, `is_dark()`. Trait style ở `style.rs` chỉ cần bọc các hàm này.
- Trộn hover / active kiểu `color-mix` của button: `materiant::theme::color::mix(a, b, phần_a)` (= `color-mix(in oklab,
  a p%, b)`, có nhân alpha — trộn với `transparent` giữ sắc); chữ trên nền nhấn: `color::on_color`. Màu vào / ra là
  `gpui_kit::Rgba`; `ThemeColors` là `Hsla` ⇒ `Rgba::from(hsla)` trước khi trộn.
- `Accent` (enum cho `bg_accent` / `on_accent`) CHƯA có — đặt trong `style.rs`, ánh xạ sang 4 cặp màu trên.
- `rem` của mọi cửa sổ đã theo cỡ chữ gốc (`theme.rem_size()` = `font_size × 16 / 14`) ⇒ token kích thước trong
  `style.rs` nên theo `rem` (`rems(…)`, `text_sm()`…) để co giãn theo Settings → Cỡ chữ; `px(…)` cố định chỉ cho viền
  1 px, bán kính bo.
- Ripple: nhánh tông sáng / tối lấy từ `cx.theme().is_dark()` hoặc độ sáng của nền (`color::Oklch::from(rgba).l`).
  Giảm chuyển động của OS: `gpui_kit::base` có `reduce_motion` (soát API khi làm).
- **Test UI đã bật**: crate con `ui-tests/` (dev-dependency `gpui` = gpui-pre `test-support`) — viết
  `ui-tests/tests/<module>.rs` với `#[gpui::test]`, mẫu `ui-tests/tests/theme.rs` (`cx.add_window` bọc `Root`).
  `cargo test` chạy cả hai crate; đo cỡ / RAM dùng `-p materiant`. Không bật `gpui-kit` feature `test-support` (xung
  đột `taffy`).
- `materiant::init` đã gọi `theme::init`; đăng ký asset icon thêm SAU dòng đó trong `src/lib.rs`.
- **Bẫy**: máy chạy thử là máy dùng thật của chủ dự án (hay chơi game ở màn chính) — chạy thử gallery CHỈ qua
  `pwsh materiant/tools/gallery-run.ps1 -Page style -Keys "…"`: màn phụ, không giành focus, phím vào thẳng GPUI, ảnh
  bằng PrintWindow; không `SendKeys` / chụp màn hình (gd1_01 đã gửi nhầm Ctrl+T vào game). Ripple cần CHUỘT ⇒ script
  chưa giả lập được: kiểm hình học / thời lượng bằng unit test, đè / nhả chuột bằng `#[gpui::test]` `simulate_*`
  trong `ui-tests/`, phần nhìn ⇒ `[owner-qa]`.
- **Soát lại khi làm**: `cargo test` (đang 17 unit + 4 UI + 1 gallery); `tools/gallery-run.ps1 -Page style`; trang
  `theme` để so màu token. Chi tiết gd1_01: `plan/materiant-gd1_01_theme.md` mục 9.

Cuối **trục tuần tự**: xong task này mới mở bốn làn song song gd1_03–06. Vì các task song song **không được** sửa
`style.rs` / `icon.rs`, task này phải đặt đủ token + icon chúng cần (mục 3).

## 1. Làm gì

- `style.rs`: trait mở rộng trên `Styled` đọc `Theme::global(cx)`: `bg_surface()`, `text_ink()`, `text_muted()`,
  `border_line()`, `focus_ring()`, `radius_field()`, `shadow_card_md()`, `text_caption()` + nền theo màu nhấn
  (`bg_accent(Accent)`, `on_accent(Accent)`) và trạng thái hover / active (trộn oklab như `color-mix` của CSS button).
- Ripple theo Material: bán kính tới góc xa nhất, lan 400 ms, mờ dần = 2/3 thời lượng, giữ khi đè chuột, nhả khi thả
  chuột ở bất kỳ đâu hoặc cửa sổ mất focus, opacity 0,12 (tông tối) / 0,16 (tông sáng), tuỳ chọn `center` / `radius`,
  tắt khi OS bật giảm chuyển động. Gắn lên mọi phần tử có id: `.ripple(cfg)`. Khác web: không có blend `plus-lighter` ⇒
  tông sáng là trắng có alpha.
- `window.rs`: `.drag_region()` cho cửa sổ không viền — `window_control_area(Drag)` (Windows) + `start_window_move` khi
  nhấn chuột (macOS / Wayland / X11); phần tử tương tác bên trong bọc `.occlude()` để bấm vào không bị kéo.
- `icon.rs`: `Icon::new(IconName::…)` + `.size()` / `.color()`, SVG nhúng qua `AssetSource`. Bộ icon: port 6 icon của
  materiant (`check`, `chevron`, `close`, `close-thin`, `info`, `warning`) + Lucide cho: `search`, `chevron-down` /
  `-up` / `-right`, `minus` (indeterminate), `circle` (radio), `loader` (vòng quay), `copy`, `save`, `settings`,
  `keyboard`, `x`. Thêm icon sau ⇒ chỉ task sau ghi nợ, không sửa ở task song song.
- Trang gallery `style`: lưới ô có ripple (tông sáng / tối, center), dải icon đủ bộ, một thanh kéo được.

## 2. Không làm trong task này

- Không có `Button` (gd1_03) — ripple thử trên `div` có id.
- Không làm `PressEffect` dạng scale (chỉ khi component nào cần — ghi nợ).

## 3. Interface chốt cho bốn làn song song

- Token đủ cho: nút (nền nhấn + hover / active / disabled), ô nhập (viền thường / hover / focus / lỗi, nền input),
  checkbox / radio / switch (nền chọn = primary, track), thanh cuộn (thumb muted + alpha). Liệt kê tên hàm cuối cùng
  vào mục 9 để bốn session đọc.
- `RippleConfig { center: bool, radius: Option<Pixels>, color: Option<Hsla> }`, `.ripple(cfg)` trên `Stateful<Div>`.
- `IconName` enum + `Icon` `RenderOnce`.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\effect\` — `ripple/` và `src/lib/press-effect.ts` (README / API.md của
  gói); icon từ `common/icon/src/lib/*.ts` (đường SVG nằm trong tệp `.ts`). Số đo CSS: `button/src/lib/btn.css`
  (hover / active mix).
- Drag region: mẫu đã chạy ở `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` (launcher) + mẹo ở
  `docs/spikes/ui-foundation.md`.
- Hình học ripple (bán kính tới góc xa nhất, tiến độ theo thời gian) là hàm thuần ⇒ test được.

## 5. Đo

- CPU khi bấm liên tục 10 ripple / s (Task Manager) — ghi số; không vẽ lại khi ripple đã tắt.

## 6. Nghiệm thu

- C1 `[opus-unit]` bán kính ripple = khoảng cách tới góc xa nhất cho điểm bấm ở góc / giữa / ngoài biên.
- C2 `[opus-unit]` tiến độ: 0 ms → 0, 400 ms → 1; mờ bắt đầu sau khi nhả, kéo dài 2/3 × 400 ms.
- C3 `[opus-run]` gallery: ripple giữ khi đè, nhả khi thả ngoài phần tử / khi Alt+Tab.
- C4 `[opus-run]` thanh kéo trên trang `style` kéo được cửa sổ; nút bọc `.occlude()` bên trong bấm không kéo.
- C5 `[owner-qa]` ripple nhìn giống bản web (tông sáng hơi khác — đã biết), icon nét đều ở 100 % / 150 % DPI.

## 7. Ghi chú UI

Trang `style`: hàng ô ripple (nền surface / nền primary), dải icon có tên dưới, thanh kéo ở trên cùng.

## 8. Nợ chuyển task khác

- gd1_03 dùng `.ripple()` + `Icon` (`loader`) cho `Button`; gd1_04–06 dùng token + icon đã chốt.

## 9. Bàn giao thực tế

**Tên hàm chốt cho bốn làn gd1_03–06** (mẫu đủ ở `materiant/CLAUDE.md` mục "Style · ripple · icon · vùng kéo"):

- `materiant::style`
  - `Accent { Primary, Danger, Warning, Success }` (+ `Accent::ALL`, `.color(cx)`, `.on_color(cx)`, `.tokens(cx)`).
  - `AccentTokens` (nút, `btn.css`): `base`, `on`, `filled_hover` (+12 % trắng), `filled_active` (+12 % đen), `ink` (chữ
    của text / outlined / tonal: 85 % / 70 % về màu chữ), `ghost_hover` 9 %, `ghost_active` 12 %, `tonal` 12 % /
    `tonal_hover` 20 % / `tonal_active` 26 %, `outline` 40 % / `outline_hover` 70 % / `outline_active` 100 %.
  - `DisabledTokens { ink, bg, border }` (alpha 0,3 / 0,036 / 0,15 của màu chữ); `LOADING_OPACITY` 0,8;
    `DISABLED_OPACITY` 0,5 (switch); `CONTROL_DURATION_MS` 200.
  - `FieldTokens` (ô nhập, `form.css`): `ink`, `placeholder`, `bg`, `bg_disabled`, `border` / `border_hover` /
    `border_focus`, `ring_hover` / `ring_focus`, `danger` + `danger_ring_hover` / `_focus`, `warning` + tương tự.
  - `ControlTokens` (checkbox / radio / switch): `checked`, `on_checked`, `unchecked_border` (N400), `track_off` (N300),
    `thumb` (surface), `state_hover` / `state_focus` (N400 20 % / 34 %), `focus_ring` (N400 40 %).
  - `ScrollbarTokens { thumb, thumb_hover }` (`muted` alpha 0,45 / × 1,35); `SCROLLBAR_THUMB_HOVER_ALPHA_SCALE`.
  - `ActiveTokens` trên `App`: `cx.field_tokens()`, `control_tokens()`, `scrollbar_tokens()`, `disabled_tokens()`,
    `focus_ring_color()` (primary 50 %). Vòng 3 px (`FOCUS_RING_WIDTH`): `ring_shadow(color)` (bóng spread — CHỈ nền
    đục: GPUI vẽ bóng cả dưới phần tử, nền trong suốt bị tô kín) / `ring_overlay(color, bo_góc)` (con tuyệt đối, viền
    tràn ra ngoài — nút text / outlined, ô chọn; gắn khi `focus.is_focused(window)`).
  - `StyledExt` (mọi `Styled`, nhận `cx`): `bg_surface`, `text_ink`, `text_muted`, `border_line`, `focus_ring`,
    `radius_field`, `shadow_card_md`, `shadow_card_2xs`, `text_body`, `text_caption`, `bg_accent(Accent, cx)`,
    `on_accent(Accent, cx)`.
- `materiant::effect::ripple`: `RippleConfig { center, radius, color, opacity }` (+ `::centered()`, builder), trait
  `RippleExt::ripple(cfg)` / `.ripple_with(cfg, &trigger)` trên `Stateful<Div>`; `RippleTrigger::fire(window)` (bấm
  phím ⇒ vòng từ tâm, tự mờ — giữ trigger bằng `window.use_keyed_state`, mẫu ở doc + ô "Click, then Space" của trang
  `style`); hằng `RIPPLE_DURATION`, `RIPPLE_OPACITY`, `RIPPLE_LIGHT_OPACITY`.
- `materiant::icon`: `IconName` (Check, ChevronDown / Up / Left / Right, Close, CloseThin, Info, Warning, Search, Minus,
  Circle, Loader, Copy, Save, Settings, Keyboard; `ALL`, `path()`, `file_name()`), `Icon::new(..).size(..).color(..)`,
  `Assets` (`AssetSource`).
- `materiant::window::DragRegionExt::drag_region()` trên mọi `InteractiveElement`.

**Cho fastcast** (`gd1_03_selection-edit` dùng ripple, `gd1_06_launcher` dùng `.drag_region()`): `use
materiant::effect::ripple::{RippleConfig, RippleExt}` → `.ripple(RippleConfig::default())` trên `div().id(..)`, gọi
sau `.rounded*()`; vùng kéo `use materiant::window::DragRegionExt` → `.drag_region()`, phần tử bấm được bên trong
`.occlude()`, cửa sổ `is_movable: true`. App phải `application().with_assets(materiant::icon::Assets)` nếu dùng `Icon`
(app có asset riêng ⇒ gọi `materiant::icon::Assets.load(path)` trong `AssetSource` của mình cho `icons/…`).

**Lệch so với mục 1 / 3** (đều đã ghi ở doc của module):

- Method `StyledExt` nhận `cx` (`.bg_surface(cx)`): builder GPUI không cầm `cx`. Trong `.hover` / `.active` dùng bộ
  token `Copy` bắt vào closure.
- `RippleConfig` thêm `opacity: Option<f32>` (mặc định 0,16 khi màu ripple sáng — OKLCh L ≥ 0,7 — còn lại 0,12; tông lấy
  theo độ sáng màu ripple, mặc định màu chữ, thay vì `is_dark()`).
- `.ripple()` chép bo góc của phần tử LÚC GỌI ⇒ gọi sau `.rounded*()`. Vòng được cắt bằng đa giác (tròn ∩ chữ nhật bo
  góc, Sutherland–Hodgman) vì `ContentMask` của GPUI chỉ là chữ nhật.
- Mất focus nhả ripple khi cửa sổ CHUYỂN từ active sang không; bấm vào cửa sổ đang nền (gallery `--background`, popup
  không focus) vẫn giữ được. Đồng hồ = `background_executor().now()` (test tua được).
- Icon: không có Lucide `chevron-*` / `x` riêng — dùng chevron 4 chiều + `close` của materiant (cùng hình). `Loader` là
  `loader-circle` của Lucide (cung tròn, quay được). Đăng ký asset: app gọi
  `application().with_assets(materiant::icon::Assets)` (không làm được trong `materiant::init`); gallery đã gọi.
- Gallery `--keys` nhận thêm chuột `down@x,y` / `up@` / `move@` + `wait@ms` (đưa thẳng vào GPUI) để chạy thử C3 không
  đụng chuột thật; sau bước chuột không nghỉ cố định (phím vẫn 300 ms). `tools/gallery-run.ps1` in thêm `cpu_ms`.

**Nghiệm thu** (29/10/2026, Windows 10, màn phụ 1920×1080 100 %):

- C1, C2 ✅ `cargo test -p materiant --lib ripple` (`radius_reaches_furthest_corner`, `timeline_matches_material`) + cắt
  đa giác (`clip_keeps_circle_inside_rounded_rect`). Lỗi bắt được khi viết: hai cung bo kín nửa cạnh ngắn (pill, nút
  tròn) sinh đỉnh gần trùng ⇒ cạnh ~0 hướng ngẫu nhiên cắt mất cả vòng — đã bỏ đỉnh trùng.
- C3 ✅ `ui-tests/tests/ripple.rs` (giữ khi đè, thả ngoài vẫn nhả, mờ hết ~267 ms, hết vòng thì `animating = false`,
  mất focus ⇒ nhả, nhấn ngoài không sinh vòng, reduce-motion ⇒ không lớp ripple) + `gallery-run.ps1 -Page style -Keys
  "down@420,199 wait@100 up@1000,600 down@250,189 wait@600"`: ô thả ngoài đã mờ hết, ô còn đè giữ vòng phủ kín cắt theo
  bo 12 px; nút tròn / pill cắt đúng hình. Sáng (ripple đen 0,12 trên surface, trắng 0,16 trên primary) và tối đều đúng.
- C4 ⏳ `[owner-qa]`: kéo cửa sổ của OS không giả lập được (HTCAPTION do Windows hỏi hit-test) — xem `plan/_backlog.md`.
- C5 ⏳ `[owner-qa]`: so ripple với bản web, icon ở 150 % DPI.
- Mục 5 (đo): tổng CPU của tiến trình qua `gallery-run.ps1` 2 lượt — nghỉ 3 s 547–625 ms (phần lớn là khởi động), 30
  ripple trong 3 s (10 / s, đè 50 ms) 828–1000 ms ⇒ ripple liên tục thêm ~300 ms / 3 s ≈ 10 % một nhân (khung 60 Hz).
  Hết vòng ⇒ không xin khung (test `animating = false`). Nhấn / nhả chỉ báo view chứa ripple (`cx.notify(view)`),
  không vẽ lại cả cửa sổ — sửa trong lượt soát cải tiến (bản đầu `window.refresh()`: 969–1016 ms).
- RAM trang `style` (private working set, gallery-run): 16,2–17,2 MB lúc nghỉ, ~18 MB sau một loạt ripple. Exe release
  build lại không đổi đáng kể (9 SVG + 8 SVG ≈ 6 KB nhúng).
- Kiểm xanh: `cargo fmt --check`, `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test` (25 unit + 4
  theme UI + 4 ripple UI + 1 gallery), `cargo deny check licenses` (Lucide ISC — đã cho phép ở D-2).

**Soát cải tiến (mục 5 run-task)**: bảo mật — không áp (không IPC / tệp; ảnh chạy thử xoá ngay sau khi xem). UI/UX —
nhãn ô ripple ghi "dark / light tone" sai ở nền tối ⇒ đổi theo màu (sửa luôn); phím chưa sinh ripple (mục 10). RAM /
hiệu năng — `window.refresh()` ⇒ `cx.notify(view)` (sửa luôn, số ở trên). Pro — không áp.

**Đề xuất đã làm** (chủ dự án chọn cả hai, 29/10/2026 — D-8):

- P1 ripple khi bấm phím: `RippleTrigger` + `.ripple_with()`; test `trigger_fires_one_released_wave` (một vòng, không
  giữ, lan xong tự mờ, bắn trước lần vẽ đầu thì bỏ qua); gallery: click ô "Click, then Space" rồi `space` ⇒ in
  `RIPPLE key space`, ảnh `shot@key` thấy vòng từ tâm. Lỗi thật bắt được khi chạy: `ring_shadow` trên ô nền trong suốt
  tô kín cả ô màu vòng (GPUI vẽ bóng dưới phần tử) ⇒ thêm `ring_overlay`, ghi rõ ở doc + `CLAUDE.md` — gd1_03 / 04 cần.
- P2 `shot@<tên>`: gallery in `SHOT <tên>` rồi nghỉ 300 ms; `gallery-run.ps1` theo dõi stdout, chụp
  `<trang>-<tên>.png` ngay (in dòng `shots=`). Đã soát: `down@290,190 wait@40 shot@spread` thấy vòng đang lan cắt theo
  mép ô.

## 10. Đề xuất cải tiến

- ✅ P1 `[ux]` Bấm bằng bàn phím không có phản hồi ripple — `effect/ripple.rs` chỉ nghe `MouseDownEvent`; Button
  (gd1_03), checkbox / radio (gd1_04) nhấn Space / Enter chỉ thấy focus ring — thêm `ripple::trigger(window, id)` (vòng
  từ tâm, tự nhả) để component gọi trong handler phím — phản hồi đồng nhất chuột / phím, đúng tinh thần "dùng hết bằng
  bàn phím" — S — P2.
- ✅ P2 `[ux]` `gallery-run.ps1` chỉ chụp một ảnh cuối — animation (vòng đang lan, thumb switch gd1_04, popup gd1_05) không
  soát được giữa chừng — thêm bước `shot@<tên>` trong `--keys`: gallery in `SHOT <tên>`, script chụp ngay khi thấy dòng
  đó — bốn làn song song tự soát animation không cần chủ dự án — S — P2.
