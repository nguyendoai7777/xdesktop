# materiant-gd1_02 — Style token, Ripple, `.drag_region()`, Icon

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
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

## 10. Đề xuất cải tiến
