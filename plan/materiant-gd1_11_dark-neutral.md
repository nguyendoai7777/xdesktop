# materiant-gd1_11 — Tông tối đen trung tính + nền cửa sổ trong / mờ (launcher kiểu Raycast)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay C8 (nền mờ thật) |
| Repo | materiant, fastcast |
| Cỡ | S — ~250 dòng (materiant ~200, fastcast ~20) |
| Phụ thuộc | materiant-gd1_09 ✅, materiant-gd1_08 ✅ (đã gộp), gd1_06 ✅ (launcher fastcast) |
| Quyết định áp dụng | D-6 (GPUI gpui-pre 0.3.10), D-9 (không hỏi), F-4 (RAM là tính năng) |
| Phụ thuộc mới | — |
| File đụng tới | materiant: `src/theme/palette.rs`, `src/theme/mod.rs`, `src/window.rs`, `src/style.rs`, `src/list.rs`, `src/kbd.rs`, `src/field/input.rs`, `src/field/number.rs`, `examples/gallery/main.rs` (SỬA). fastcast: `crates/ui/src/launcher/mod.rs`, `crates/ui/src/launcher/view.rs` (SỬA) |

Chủ dự án (30/10/2026, ảnh mẫu launcher Raycast): đổi tông tối từ xanh đen (slate) sang **đen trung tính + opacity**.
Phần gợi ý "Quick AI Tab" trong ảnh bị gạch ⇒ không làm.

## 1. Làm gì

- Bảng màu tối mặc định (`DEFAULT_SEEDS`) bỏ ánh xanh: surface / text / muted / border / input là xám trung tính (sắc
  độ 0). Black Pink: nhánh tối của muted / border (zinc, ám xanh nhẹ) ⇒ trung tính. Màu nhấn, preset Rose / Rebecca
  (ám màu có chủ ý), nhánh sáng: giữ nguyên.
- Tầng nổi bằng **trắng phủ alpha** thay màu đặc: `ThemeColors::layer(Neutral)` = màu chữ với alpha sao cho đặt trên
  `surface` ra đúng `neutral(step)`. Nền hover / chọn của List, chip Kbd, nút xoá / stepper của ô nhập, nền disabled
  của ô nhập, track switch tắt dùng `layer` ⇒ đặt trên nền trong suốt vẫn đúng. Viền (`border`) tối = trắng 8 %.
- Tương phản: chữ chính ≥ 4,5:1, chữ phụ (`muted`) ≥ 3:1 trên surface và trên nền trong suốt xấu nhất (desktop
  trắng phía sau).
- `materiant::window`: `translucent_window_options()` (nền `Blurred` — acrylic Windows) + `translucent_surface(cx)`
  (surface hạ alpha ở tông tối). Gallery `GALLERY_TRANSLUCENT=1` mở bằng nó để đo.
- fastcast launcher mở bằng `translucent_window_options()`, nền gốc `translucent_surface`.
- Đo RAM + FRAMES trước / sau (gallery opaque ↔ translucent; launcher fastcast trước / sau). Tốn đáng kể ⇒ nền đặc.

## 2. Không làm trong task này

- Gợi ý "Quick AI Tab" (ảnh mẫu, bị gạch).
- Đổi bố cục launcher (nhóm "Suggestions", icon app thật…) — chỉ đổi màu / nền.
- `src/menu.rs`, `examples/gallery/pages/menu.rs` (làn materiant-gd1_08b có thể đang mở).
- Mica (chỉ Windows 11 22621+; máy chủ dự án Windows 10) — để `WindowBackgroundAppearance` cho app tự chọn sau.

## 2b. Phân vai

| Phần | Ai |
|---|---|
| Bảng màu, `layer`, chuyển component sang `layer`, test màu / tương phản | [opus] |
| `window::translucent_*`, gallery `GALLERY_TRANSLUCENT`, launcher fastcast | [opus] |
| Đo RAM / FRAMES, chạy gallery qua `gallery-run.ps1` | [opus-run] |
| Nhìn nền mờ thật (PrintWindow không chụp được phần desktop phía sau), kéo launcher (acrylic Win10 có thể giật khi kéo) | [owner-qa] |

Task nhỏ, đan vào nhau (bảng màu ↔ component) ⇒ Opus tự làm, không giao Sonnet.

## 3. Kiểu dữ liệu

- `ThemeColors::layer(&self, step: Neutral) -> Hsla` (mảng `layer: [Hsla; 10]` riêng tư như `neutral`).
- `materiant::window::translucent_window_options() -> WindowOptions` = `window_options()` + `window_background:
  Blurred`; `translucent_surface(cx: &App) -> Hsla`; hằng `TRANSLUCENT_SURFACE_ALPHA`.

## 4. Code

- `palette.rs`: `DEFAULT_SEEDS` nhánh tối; `ThemeColor::pair_alpha`… cho viền trắng 8 %.
- `theme/mod.rs`: `ThemeColors::resolve` dựng `layer`.
- Component: thay `neutral(N100/N200/N300)` làm NỀN bằng `layer(…)`.
- gpui-pre-windows 0.3.10 `set_background_appearance`: `Transparent` = `SetWindowCompositionAttribute` accent 2,
  `Blurred` = accent 4 (acrylic, build ≥ 17763), Mica = DWM 22621+. Nền không đục ⇒ GPUI tắt ClearType (chữ xám AA).

## 5. Đo

Release, máy nhà Windows 10 19045, RAM = cột Memory (private working set):
gallery `-p materiant` trang `style` opaque ↔ `GALLERY_TRANSLUCENT=1` (RAM + `FRAMES` khi ripple chạy);
launcher `fastcast-ui --endpoint dev --command open_launcher --background` trước / sau.

## 6. Nghiệm thu — Case test

| Case | Cho / Khi / Thì | Phủ |
|---|---|---|
| C1 | Cho `DEFAULT_SEEDS` tối / Khi resolve / Thì surface, text, muted, border, input và cả thang 50–900 có r = g = b | [opus-unit] |
| C2 | Cho mọi preset tối + mặc định / Thì `text` trên `surface` ≥ 4,5:1, `muted` trên `surface` ≥ 3:1 (mặc định: cả trên nền trong suốt đặt trên trắng) | [opus-unit] |
| C3 | Cho tối và sáng / Khi phủ `layer(step)` lên `surface` (sRGB) / Thì lệch `neutral(step)` ≤ 1/255 mỗi kênh với nền trung tính | [opus-unit] |
| C4 | Nhánh sáng của `DEFAULT_SEEDS`, màu nhấn, Rose / Rebecca không đổi (test cũ giữ nguyên số) | [opus-unit] |
| C5 | `translucent_window_options()` ⇒ `Blurred`, vẫn bỏ trần khung hình không active | [opus-unit] |
| C6 | Gallery mọi trang ở tối đọc rõ (chụp PrintWindow từng trang) | [opus-run] |
| C7 | RAM / FRAMES translucent không tệ hơn opaque quá 1 MB / 5 fps; launcher mở được, khung đầu không chậm hơn | [opus-run] |
| C8 | Nhìn launcher thật: nền đen trong mờ thấy desktop nhoè phía sau, kéo thanh trên không giật | [owner-qa] |

## 7. Ghi chú UI

Mẫu (Raycast): nền ~#1c1c1c alpha ~0,88 + blur; hàng chọn trắng ~9 %; viền trắng ~8 %; chữ phụ trắng ~60 %; chip phím
trắng ~9 % + viền mảnh. Tông sáng không đổi.

## 8. Nợ chuyển task khác

- materiant-gd1_10 (nghiệm thu): soát lại gallery ở tối với bảng trung tính mới + `GALLERY_TRANSLUCENT=1`.
- `cargo fmt --check` của materiant đỏ ở `src/list.rs`, `src/scroll.rs`, `examples/gallery/pages/scroll.rs`,
  `ui-tests/tests/scroll.rs` — lệch có sẵn từ làn gd1_06, không phải task này (đã để nguyên).

## 9. Bàn giao thực tế

Xong 30/10/2026. materiant `bf55fe9` (nhánh `1722dbf`), fastcast `7928d81` (nhánh `433a2c9`).

- **Bảng màu** (`theme/palette.rs`): `DEFAULT_SEEDS` nhánh tối `#1c1c1c` (`DARK_SURFACE`) / chữ `#f5f5f5` (15,9:1) /
  phụ `#a3a3a3` (7,6:1) / viền trắng 8 % (`ThemeColor::pair_dark_alpha`, `color::hex_alpha`) / input `#424242`. Black Pink
  tối: muted `#a3a3a3`, viền trắng 10 %. Nhánh sáng, màu nhấn, Rose / Rebecca không đổi (test C4).
- **`ThemeColors::layer(step)`** (`theme/mod.rs`): `text` với alpha giải theo tổng ba kênh sRGB ⇒ phủ lên `surface`
  ra đúng `neutral(step)`. Dùng ở: list hover / chọn (`list.rs`), chip Kbd (tối bậc 200, sáng 100 — `kbd.rs`), nút xoá
  (`field/input.rs`), stepper (`field/number.rs`), `FieldTokens::bg_disabled` (`style.rs`), panel / mục chọn của gallery.
  Bậc 200 = trắng 7,4 % (mẫu Raycast ~8 %). Giữ `neutral` đặc: switch track, ô nhập (có `ring_shadow` — bóng vẽ dưới
  nền, nền alpha sẽ ám màu vòng).
- **Dialog**: lớp nền tối `#000000a6` thay slate `#0f172abf` (sáng giữ).
- **Cửa sổ mờ** (`window.rs`): `translucent_window_options()` (`WindowBackgroundAppearance::Blurred`) +
  `translucent_surface(cx)` (tối alpha `TRANSLUCENT_SURFACE_ALPHA` 0,88, sáng đục). gpui-pre-windows 0.3.10: `Blurred`
  = `SetWindowCompositionAttribute` accent 4 (acrylic, build ≥ 17763; máy 19045 có), `Transparent` = accent 2, Mica chỉ
  22621+. Nền không đục ⇒ GPUI tắt ClearType (`window.rs:4918` của gpui-pre). Gallery `GALLERY_TRANSLUCENT=1`.
- **fastcast launcher**: `launcher/mod.rs` trải `translucent_window_options()`, `view.rs` nền gốc
  `translucent_surface(cx)`.
- **Đo** (release, Windows 10 19045, GTX 1650, RAM = private working set, 3 lượt mỗi bên):

  | | Nền đặc | Nền mờ |
  |---|---|---|
  | Gallery trang style (tối, 3 lần ripple) | 15,9–16,4 MB, CPU 609–719 ms | 15,0–16,0 MB, CPU 453–734 ms |
  | Launcher hiện (cửa sổ mới) | 14,0–14,3 MB, khung đầu 34–57 ms | 14,0–14,6 MB, khung đầu 61–81 ms |
  | Launcher hiện lại (dựng sẵn) | 14,4–14,7 MB, 0,2 ms | 14,3–14,9 MB, 0,2–0,3 ms |

  ⇒ không tốn RAM; dựng cửa sổ mới chậm thêm ~27 ms (đặt acrylic), đường hay dùng (hiện bản dựng sẵn) không đổi ⇒
  giữ nền mờ. **FRAMES không đo được**: máy đang tắt "Animation effects" (`SPI_GETCLIENTAREAANIMATION` = False ⇒
  `reduce_motion`, ripple không chạy, không in `FRAMES`) — bẫy đã ghi ở materiant-gd1_07.
- **Case**: C1–C5 ✅ (`theme::tests::{default_dark_is_neutral_gray, text_contrast_meets_wcag,
  layer_over_surface_matches_neutral, default_light_unchanged}`, `window::tests::{translucent_options_blur_and_keep_frame_rate,
  translucent_surface_keeps_contrast}` — nền mờ trên trắng: chữ phụ vẫn ≥ 3:1). Test cũ đổi số theo chữ tối mới:
  `button::tests::matches_chrome_reference` (2 ca tối), `derived_input_borders_match_css` (focus tối). C6 ✅ chụp
  PrintWindow 11 trang ở tối, đọc rõ, không còn ánh xanh (ảnh đã xoá). C7 ✅ bảng trên. C8 `[owner-qa]` chờ kiểm tay:
  PrintWindow chỉ chụp nội dung cửa sổ, không có desktop nhoè phía sau.
- Soát xanh: materiant 168 test, clippy, deny; fastcast 113 test, clippy, deny, `fmt --check -p fastcast-ui`.
  `foreground_unchanged=True` mọi lượt chạy thử.
- **Kiểm tay** (C8): `pwsh start.ps1 docs` ở chế độ tối (Ctrl+T) — mọi trang đen trung tính; bật launcher fastcast
  (`fastcast-ui --endpoint dev --command open_launcher` với `fake_daemon`, hoặc Alt+Space của bản thật) đặt trên một
  cửa sổ sáng / ảnh nền sặc sỡ ⇒ thấy nền đen hơi trong, phía sau nhoè; kéo thanh trên không giật; chữ vẫn nét.
- Opus chọn 30/10/2026 (D-9, ghi `plan/confirm.md`): màu nền cụ thể, `layer` thay vì đổi cả thang sang alpha, `Blurred`
  + sáng giữ đục, ô tìm launcher vẫn nền đặc.

## 10. Đề xuất cải tiến

Bảo mật / riêng tư: không áp (chỉ màu / nền cửa sổ). RAM: không thêm (bảng mục 9).

- [ux] Ô tìm của launcher có khung + nền đặc, Raycast dùng ô trần trên nền mờ — `launcher/view.rs` `TextField` +
  `field/shell.rs:208` nền `f.bg` đặc — thêm `TextField::bare()` (không viền, nền trong, không vòng `ring_shadow`) và
  dùng ở launcher — giống mẫu hơn — S — P3 (đổi bố cục, để chủ dự án chọn sau khi nhìn bản này).
- [ux] Dựng cửa sổ launcher mới chậm thêm ~27 ms với nền mờ — bảng mục 9 — chấp nhận (bản dựng sẵn 0,2 ms); nếu thấy
  trễ khi mở lần đầu sau nhả GPU thì đặt acrylic sau khung đầu — S — P3.
- [pro] Độ mờ / màu nền launcher tuỳ chỉnh (Settings → Appearance) — chỗ hợp huy hiệu "Pro" — chỉ ghi (D-4).
