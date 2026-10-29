# materiant-gd1_01 — Theme: sáng / tối / hệ thống, màu, chữ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | materiant |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | materiant-gd0_01 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/theme/mod.rs` SỬA · `src/theme/color.rs` MỚI (oklab / oklch, trộn) · `src/theme/palette.rs` MỚI (theme có tên, thang trung tính) · `src/lib.rs` SỬA (`init`) · `examples/gallery/main.rs` SỬA (nút sáng / tối) · `examples/gallery/pages/theme.rs` SỬA |

Nằm trên **trục tuần tự** (ROADMAP): mọi task sau đọc màu qua đây.

## 1. Làm gì

- `MateriantTheme` (struct dữ liệu) → `Theme` (GPUI `Global`): 4 màu nhấn (`primary`, `danger`, `warning`, `success`) +
  5 màu trung tính (`surface`, `text`, `muted`, `border`, `input`) như `THEME_ACCENT_KEYS` / `THEME_NEUTRAL_KEYS`.
- Chế độ `Light` / `Dark` / `System`; `System` theo `window.appearance()` và tự đổi khi OS đổi (observe appearance).
- Màu `on-*` theo ngưỡng OKLCH L `ON_COLOR_LIGHTNESS_THRESHOLD` = 0,7. Thang trung tính 50–900 trộn oklab theo
  `THEME_NEUTRAL_RAMP`. Theme có tên port từ `BLACK_PINK_THEME`, `ROSE_RED_THEME`, `REBECCA_PURPLE_THEME`
  (`MATERIANT_THEMES`); màu chuỗi `THEME_SERIES_COLORS` để dành cho chart (chỉ port hằng).
- Token phụ: viền ô nhập hover / focus, `radius-field` 10 px, `shadow-card-md`, `text-caption`, cỡ chữ gốc chỉnh được
  (fastcast Settings → Cỡ chữ, mặc định 14).
- `set_theme(patch)` cộng dồn như bản web (chỉ ghi đè trường có trong patch) + `Theme::global(cx)`; đổi theme ⇒
  `cx.refresh_windows()`.
- `materiant::init(cx)` đăng ký theme mặc định. Gallery: nút sáng / tối / hệ thống, trang `theme` vẽ bảng màu + thang +
  mẫu chữ.

## 2. Không làm trong task này

- Không có trait style (`bg_surface()`…) — gd1_02. Không có component.
- Không đọc / ghi config của app (fastcast tự truyền chế độ + cỡ chữ vào).

## 3. Kiểu dữ liệu

`ThemeMode { Light, Dark, System }`; `MateriantTheme { accents, neutrals, radius, font_size, … }` (serde được, khoá
camelCase — app có thể lưu theme tuỳ biến); `Theme { mode, resolved: ResolvedColors, … }`. Màu nội bộ là `Oklab` /
`Oklch` + đổi sang `gpui::Hsla` ở cuối.

## 4. Code

- Port từ `E:\codex\xbds\materiant\projects\common\theme\src\lib\` — `theme.const.ts`, `theme.type.ts`, `theme.util.ts`
  (+ `theme.util.spec.ts` làm nguồn ca test). Đọc `common/theme/README.md`, `API.md`.
- Công thức `color-mix(in oklab, a p%, b)` = nội suy tuyến tính trong oklab (cả alpha) — viết hàm thuần `mix`.

## 5. Đo

- Đổi sáng / tối trong gallery: không nháy (nhìn), không cấp phát lại cửa sổ.

## 6. Nghiệm thu

- C1 `[opus-unit]` `mix` khớp `color-mix(in oklab)` cho ≥ 4 cặp lấy từ `theme.util.spec.ts` (sai số ≤ 1/255 mỗi kênh).
- C2 `[opus-unit]` `on_color` chọn đen / trắng đúng hai phía ngưỡng L 0,7 (ca biên 0,699 / 0,7).
- C3 `[opus-unit]` thang trung tính 50–900 khớp `THEME_NEUTRAL_RAMP`; `set_theme` cộng dồn không xoá trường cũ.
- C4 `[opus-run]` gallery đổi Light / Dark / System; System đổi theo OS khi bật / tắt chế độ tối Windows.
- C5 `[owner-qa]` so trang `theme` của gallery với trang tài liệu theme của materiant web ở cả sáng / tối.

## 7. Ghi chú UI

Trang `theme`: hàng màu nhấn (ô + `on-*` chữ mẫu), hàng trung tính, thang 50–900, mẫu `text-caption` / cỡ gốc.

## 8. Nợ chuyển task khác

- gd1_02: trait style đọc `Theme::global(cx)`.

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
