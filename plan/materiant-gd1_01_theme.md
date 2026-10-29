# materiant-gd1_01 — Theme: sáng / tối / hệ thống, màu, chữ

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (29/10/2026) |
| Repo | materiant |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | materiant-gd0_01 |
| Quyết định áp dụng | D-6 |
| Phụ thuộc mới | — |
| File đụng tới | `src/theme/mod.rs` SỬA · `src/theme/color.rs` MỚI (oklab / oklch, trộn) · `src/theme/palette.rs` MỚI (theme có tên, thang trung tính) · `src/lib.rs` SỬA (`init`) · `examples/gallery/main.rs` SỬA (nút sáng / tối) · `examples/gallery/pages/theme.rs` SỬA |

## 0. Bàn giao từ materiant-gd0_01 (29/10/2026)

<!-- handoff: materiant-gd0_01 -->

- **Đã có sẵn để dùng**: `src/theme/mod.rs` (stub một dòng doc) — thêm `color.rs`, `palette.rs` bên trong `theme/` là
  đúng luật (task GĐ1 chỉ cấm thêm module cấp gốc). `src/lib.rs` đã `pub mod theme;` + `pub use gpui_kit;`.
- `materiant::init(cx)` hiện chỉ gọi `gpui_kit::init(cx)` (= `gpui_base::init`) — giữ dòng đó, thêm đăng ký `Theme`
  global SAU nó (gpui-base tự `Theme::global_mut` của nó; đặt tên kiểu khác để khỏi lẫn với `gpui_kit::base::Theme`).
- **Nợ chuyển sang đây**: gallery `examples/gallery/main.rs` có `struct Palette` + `fn palette(dark)` màu tạm và cờ
  `Gallery::dark` — thay bằng token theme, nút `Dark` / `Light` thành ba chế độ Light / Dark / System. Ctrl+T (action
  `ToggleDark`) đang lật cờ — cho nó xoay vòng ba chế độ hoặc đổi tên action.
- Trang `examples/gallery/pages/theme.rs`: hàm `render(window, cx) -> impl IntoElement` đang trả
  `super::todo(…)`; state giữ qua khung dùng `window.use_keyed_state`.
- **Bẫy đã gặp**: import qua `gpui_kit::{…}` + `gpui_kit::prelude::*` (bảng đường import ở `materiant/CLAUDE.md`);
  `gpui_kit::actions!` thay `actions!` của GPUI. `Window::focus(&handle, cx)` nhận hai tham số. Chạy exe bằng
  `Start-Process` phải `-NoNewWindow`, không thì phím giả lập rơi vào cửa sổ console.
- Build: `export CARGO_TARGET_DIR=<gốc>/materiant/target` — cache đã có sẵn (release + debug); release lặp lại ≈ 1 phút
  vì LTO thin, soát nhanh bằng debug.
- **Soát lại khi làm**: `cargo run --example gallery -- --page theme`; stdout in `PAGE <tên>` / `DARK <bool>` — đổi
  dòng `DARK` thành `MODE <light|dark|system>` để C4 soát bằng log. Cột Memory Task Manager lúc nghỉ trước task:
  13,3–13,5 MB (so sau khi có theme).

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

- C1 `[opus-unit]` `mix` khớp `color-mix(in oklab)` cho ≥ 4 cặp (sai số ≤ 1/255 mỗi kênh) — số tham chiếu đo bằng
  Chrome (spec web không có cặp số nào, mục 9).
- C2 `[opus-unit]` `on_color` chọn đen / trắng đúng hai phía ngưỡng L 0,7 (ca biên 0,699 / 0,7).
- C3 `[opus-unit]` thang trung tính 50–900 khớp `THEME_NEUTRAL_RAMP`; `set_theme` cộng dồn không xoá trường cũ.
- C4 `[opus-run]` gallery đổi Light / Dark / System; System đổi theo OS khi bật / tắt chế độ tối Windows.
- C5 `[owner-qa]` so trang `theme` của gallery với trang tài liệu theme của materiant web ở cả sáng / tối.

## 7. Ghi chú UI

Trang `theme`: hàng màu nhấn (ô + `on-*` chữ mẫu), hàng trung tính, thang 50–900, mẫu `text-caption` / cỡ gốc.

## 8. Nợ chuyển task khác

- gd1_02: trait style đọc `Theme::global(cx)`.

## 9. Bàn giao thực tế

- **Chủ dự án chốt 29/10/2026**: (1) thêm `serde` (derive) làm phụ thuộc trực tiếp — đã có trong cây qua gpui-pre;
  (2) theme mặc định = màu nhấn theo cặp của Black Pink (primary `#c71585` / `#ff1493`) KHÔNG ghim nền, trung tính
  slate của trang tài liệu (`surface #ffffff/#0f172a`, `text #0f172a/#f8fafc`, `muted #64748b/#94a3b8`,
  `border #e2e8f0/#334155`, `input #d1d9e0/#3d444d`) — `DEFAULT_SEEDS` ở `src/theme/palette.rs`.
- **Backlog gộp vào task này** (chủ dự án chọn sau gd0_01): (a) test UI — dev-dependency `gpui` = `gpui-pre` =0.3.10
  feature `test-support` + `serde_json` (chỉ test JSON). Bật qua `gpui-kit` feature `test-support` KHÔNG được: nó kéo
  `gpui-fast` ⇒ xung đột `taffy` =0.15.0 / 0.15.1. (b) Gallery đọc RAM macOS bằng `task_info(TASK_VM_INFO)`
  `phys_footprint` — **chưa build được trên Mac** (máy không có target darwin), chờ gd1_10.
- **Commit** `materiant` `79b6568` trên `claude/gd1_01`, gộp `master`.
- **Soát xanh** (cwd = worktree): `cargo fmt --check`, `cargo build`, `cargo clippy --all-targets -- -D warnings`,
  `cargo test` (17 unit + 3 `#[gpui::test]` + 1 gallery), `cargo deny check licenses` → `licenses ok`.
- **C1** xanh — đổi nguồn số: `theme.util.spec.ts` không có cặp số nào (chỉ so chuỗi CSS) ⇒ lấy tham chiếu bằng Chrome
  thật: tô `color-mix(in oklab, …)` lên canvas rồi đọc pixel, 7 cặp + 1 cặp với `transparent`, sai số ≤ 1/255. Thêm:
  độ sáng OKLCh của 9 màu ghi trong `theme.const.ts` khớp Chrome ±5e-4.
- **C2** xanh (`ink_flips_at_threshold`, 0,699 trắng / 0,7 đen + các màu web chọn quanh ngưỡng). **C3** xanh (thang khớp
  Chrome, 900 = `text`; cộng dồn ở `ThemeSeeds::apply` + `tests/theme.rs` trên App thật).
- **C4** một phần: tự động — `tests/theme.rs` kiểm System theo OS / Light-Dark ghim bỏ qua OS / Black Pink ghim tối /
  cửa sổ có `Root` mở ra thì đồng bộ ngay (`observe_new::<Root>` đã nối). Chạy thật: gallery release mở, log
  `MODE system dark=true` (OS máy nhà đang tối). **Phần Ctrl+T + nhìn bị huỷ**: lúc chạy, màn hình đang có app khác
  của chủ dự án ở trên cùng — 3 lần Ctrl+T giả lập đã rơi vào app đó, ảnh chụp lọt màn hình riêng ⇒ đã xoá ngay, dừng
  chạy thật (bẫy ghi vào `materiant/CLAUDE.md`). Sự kiện OS đổi sáng / tối không giả lập được trong test
  (`TestAppContext::test_window` là `pub(crate)`).
- **Chờ kiểm tay** (`[owner-qa]`, cũng ở `plan/_backlog.md`): `cargo run --example gallery -- --page theme` →
  Ctrl+T xoay Light / Dark / System (nút trên phải đổi chữ, nền đổi không nháy); bấm 4 preset; ở System bật / tắt chế
  độ tối Windows (Settings → Personalization → Colors) ⇒ gallery đổi theo; C5 so với trang theme của bản web.
- **Đo**: gallery release 7,45 MB (gd0_01: 7,30 MB; +0,1 MB do example kéo dev-dependency `test-support`, phần còn lại
  là theme). RAM nghỉ trang `theme` 15,8 MB (gd0_01 trang stub: 13,4 MB) — chưa tách được phần do trang theme vẽ nhiều
  hơn với phần do `test-support`; đo lại ở gd1_10.
- **Interface đã chốt cho task sau** (`materiant::theme`): `Theme::global(cx)` / `cx.theme()` (`ActiveTheme`) →
  `colors()` (`ThemeColors`: `primary`, `on_primary`, `danger`…, `surface`, `text`, `muted`, `border`, `input`,
  `input_hover`, `input_focus`, `primary_ink`, `series[8]`, `neutral(Neutral::N50…N900)`), `mode()`, `is_dark()`,
  `font_size()`, `caption_size()` (13/14 cỡ gốc), `radius_field()` 10 px, `shadow_card_md()` / `shadow_card_2xs()`.
  `set_theme(&MateriantTheme, cx)`, `reset_theme`, `set_system_appearance`. `color::{mix, on_color, hex, Oklab, Oklch}`.
- **Khác spec mục 3**: `MateriantTheme` phẳng như bản web (`mode`, `primary`…`input`, `series`, `font_size` — đều
  `Option`), không gom `accents` / `neutrals`; bộ đầy đủ đang áp là `ThemeSeeds`. Không có `radius` trong bản vá (bản web
  cũng không). `cx.refresh_windows()` gọi khi đổi theme; OS đổi mà nền thật không đổi (chế độ ghim) thì không vẽ lại.
- Theme của `gpui-base` được đồng bộ (appearance + `ColorTokens`) — `InputBase` (gd1_04) đọc `ring`, `input`… từ đó.

## 10. Đề xuất cải tiến

Bảo mật: không áp (không tệp, không IPC; FFI macOS một lời gọi đọc). 

- [ram] Example gallery là target dùng dev-dependency ⇒ build release của nó cũng mang `gpui` `test-support` (exe +0,1
  MB, chưa rõ RAM) — số RAM gd1_10 đo qua gallery sẽ lệch so với app thật. Đề xuất: gd1_10 đo bằng một `[[bin]]` /
  example không dùng dev-dependency, hoặc so gallery có / không `test-support` một lần — S — P2.
- [ux] Cỡ chữ gốc chỉ tới component qua `theme.font_size()`; kích thước theo `rem` của GPUI (`text_sm()`, `size_4()`…)
  không đổi theo Settings → Cỡ chữ. Đề xuất: `theme` đặt `window.set_rem_size(font_size × 16 / 14)` cho mọi cửa sổ có
  `Root` (cùng chỗ nối `observe_new`) để cả bố cục co giãn theo cỡ chữ — S — P2.
- [pro] Theme tuỳ biến (tự chọn màu nhấn / lưu `MateriantTheme` riêng) hợp huy hiệu "Pro" ở fastcast Settings; preset
  có sẵn để bản miễn phí — chỉ ghi, chưa làm (D-4) — S — P3.
