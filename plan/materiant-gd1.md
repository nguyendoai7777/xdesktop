# materiant (repo `materiant`) — Giai đoạn 1: lõi + component fastcast MVP cần

> Soạn 29/10/2026. Nền: D-6 (`gpui-kit` =0.8.1 → `gpui-pre` + `gpui-base`, không bật `gpui-component`).
> Nguồn port: `E:\codex\xbds\materiant\projects` (Angular 22 + Tailwind v4, token `--mtt-*`).
> Tên: thư mục / repo `materiant`, crate Rust `materiant` (app import `use materiant::…`) — D-1.
> Plan nằm ở `plan/` của repo gốc — một thư mục plan cho cả workspace (chủ dự án chốt 29/10/2026). Thư mục
> `materiant/` đã `git init` 29/10/2026, mới chứa spike UI dời từ repo gốc: `spikes/ui-foundation/gpui-proto`
> (launcher + overlay chạy được), bản vá WARP `spikes/ui-foundation/vendor/gpui-pre-windows`, `bench.ps1`, báo cáo
> `docs/spikes/ui-foundation.md`. T0 dựng crate trên đó. Tách task ra tệp riêng thì đặt tên
> `materiant-gd1_<NN>_<slug>.md` (`plan/_tasking-convention.md`).

## Nguyên tắc

- **Port theo nhu cầu.** GĐ1 chỉ làm lõi + component mà fastcast MVP dùng tới. Còn lại vào danh sách "port khi cần".
- **Một component = primitive `gpui-base` (hành vi) + style materiant (diện mạo).** Không chép API Angular 1:1. Port
  diện mạo, trạng thái (hover / active / focus-visible / disabled / loading), hành vi bàn phím. API viết theo kiểu
  builder của GPUI (`Button::new("save").filled().primary().on_click(…)`).
- **Số đo lấy từ CSS của materiant**: màu, cỡ, bo góc, khoảng cách, thời lượng. Không tự chế giá trị mới.
- **Hover đổi màu tức thì** (gpui-pre không có transition khai báo). Chỉ animate chỗ đáng: ripple, thumb của switch,
  popup hiện / ẩn — bằng `gpui_base::motion`.
- Mỗi task xong khi: component có trong `gallery`, đúng ở cả sáng / tối, bàn phím chạy, `cargo clippy -- -D warnings`
  + `cargo test` xanh (test cho phần logic thuần: màu, hình học ripple, mask số).

## Bố cục repo `materiant/`

```
materiant/
  Cargo.toml            # một crate `materiant` (thư mục / repo `materiant`); gpui-kit =0.8.1, default-features = false (không gpui-component)
  CLAUDE.md             # convention Rust riêng của materiant
  deny.toml             # cargo deny check licenses theo D-2
  src/
    lib.rs              # materiant::init(cx): đăng ký Theme, keybinding, asset
    theme/              # MateriantTheme → Theme (Global); oklab / oklch; thang trung tính; màu on-*
    style.rs            # trait mở rộng: bg_surface(), text_ink(), border_line(), focus_ring()…
    effect/ripple.rs    # PressEffect + Ripple
    icon.rs             # SVG nhúng (chỉ icon có dùng; Lucide — ISC)
    button.rs  field/  checkbox.rs  radio.rs  switch.rs  scroll.rs  list.rs
    tooltip.rs  popover.rs  dialog.rs  menu.rs  select.rs  tabs.rs  toast.rs  kbd.rs
  examples/gallery.rs   # trang xem mọi component, nút đổi sáng / tối, in RAM
  spikes/ui-foundation/ # spike chọn nền UI (đã có): gpui-proto, vendor/gpui-pre-windows, bench.ps1
  docs/spikes/          # báo cáo spike (đã có: ui-foundation.md)
```

## Task

| # | Việc | Port từ | Xong khi |
|---|---|---|---|
| T0 | Dựng crate trong repo `materiant` (đã `git init`, có `spikes/` — remote theo Q-2): `Cargo.toml`, `CLAUDE.md` đầy đủ, `deny.toml`, `.gitignore`, `gallery` rỗng mở được trên Windows. Bảng định tuyến `CLAUDE.md` gốc + `init.*` đã có `materiant` | — | `cargo run --example gallery` mở cửa sổ; `cargo deny check licenses` sạch |
| T0b | ~~Bê quy trình xbds sang~~ — **phần lớn đã xong 29/10/2026** (session fastcast): skill `run-task` (gộp khuôn `handoff` vào), `close-phase`, khung `plan/_tasking-convention.md`, worktree + `merge --no-ff`. Còn: output style `terse` | `xbds/.claude` | Chạy được một task mẫu theo quy trình |
| T1 | **Theme**: chế độ `light` / `dark` / `system` (`system` theo giao diện OS, tự đổi khi OS đổi); 4 màu nhấn + 5 màu trung tính; `on-*` theo ngưỡng OKLCH L 0,7; thang trung tính 50–900 trộn oklab theo `THEME_NEUTRAL_RAMP`; viền ô nhập hover / focus; `radius-field` 10 px; `shadow-card-md`; `text-caption`; `set_theme()` cộng dồn như bản web; cỡ chữ gốc chỉnh được (Settings → Cỡ chữ) | `common/theme` | Test so màu với công thức `color-mix(in oklab, …)` cho vài cặp; gallery đổi sáng / tối không nháy |
| T2 | **Style + Ripple**: trait token (`bg_surface`, `text_ink`, `border_line`, `focus_ring`…). Ripple theo Material: bán kính tới góc xa nhất, lan 400 ms, mờ = 2/3 thời lượng, giữ khi đè chuột, nhả khi thả chuột ở bất kỳ đâu hoặc cửa sổ mất focus, opacity 0,12 (tông tối) / 0,16 (tông sáng), tuỳ chọn `center` / `radius`, tắt khi OS bật giảm chuyển động. Gắn được lên mọi phần tử có id: `.ripple(cfg)`. Kèm helper `.drag_region()` cho cửa sổ không viền: `window_control_area(Drag)` (Windows) + `start_window_move` khi nhấn chuột (macOS / Wayland / X11); phần tử tương tác bên trong bọc `.occlude()` để bấm vào không bị kéo — cách đã kiểm ở spike `spikes/ui-foundation/gpui-proto` | `effect/ripple`, `effect/press-effect` | Test hình học; nhìn trên nút ở gallery. Khác web: không có blend `plus-lighter` ⇒ tông sáng là trắng có alpha |
| T3 | **Icon + Button + Kbd**: `Button` / `IconButton` — dáng `text` / `filled` / `tonal` / `outlined` / `dashed` / `elevated`, cỡ `lg` / `md` / `sm` (icon 38 / 32 / 24 px), màu `primary` / `base` / `danger` / `warning` / `success` / tuỳ ý (hover / active trộn oklab y như `color-mix`), `loading` (vòng quay circular), `disabled`, bo góc; dựng trên `gpui_base::Button` + ripple. `Kbd` (chip phím tắt — riêng materiant, cho launcher) | `button`, `common/icon` | Đủ ma trận dáng × màu × cỡ trong gallery; Tab / Space / Enter bấm được |
| T4 | **Ô nhập**: field-shell (nhãn, gợi ý, lỗi), ô chữ trên `gpui_base::Input`, ô số (FPS 1–60, cỡ chữ) với mask số | `form/ui/field-shell`, `form/ui/input`, `form/headless/numeric-mask` | Chủ dự án gõ thử Unikey / EVKey (Telex) + bộ gõ IME; chọn chữ, undo, dán |
| T5 | **Checkbox, Radio, Switch** trên primitive cùng tên của gpui-base | `form/ui/{checkbox,radio,switch}` | Bàn phím + trạng thái disabled / indeterminate |
| T6 | **Cuộn + danh sách**: vùng cuộn kiểu `scroll` của materiant (thanh mảnh, hiện khi rê / khi cuộn) trên `gpui_base::Scrollbar`; danh sách ảo trên `VirtualList` (launcher, lịch sử ảnh) | `scroll`, `virtual-scroll` | 10 000 dòng cuộn mượt, RAM không tăng theo số dòng |
| T7 | **Overlay**: `Tooltip`, `Popover`, `Dialog` (bẫy focus, Esc, bấm ra ngoài thì đóng, trả focus về chỗ cũ), `Menu` — dropdown + menu chuột phải, ↑ ↓ Enter, nhóm, vạch ngăn, phím tắt canh phải (chính panel Ctrl+K của launcher). gpui-base không có menu ⇒ dựng trên `Popover` + điều hướng danh sách, tham khảo `menu` của gpui-component (Apache-2.0) | `overlay/{tooltip,popover,overlay-dialog}`, `menu` | Popup lật cạnh đúng khi sát mép màn hình; nhiều tầng popup chồng nhau đóng đúng thứ tự |
| T8 | **Dropdown (select)** trên `gpui_base::Select`; **Tabs** (ngang + dọc cho sidebar Settings); **Toast** ("Đã chép", "Đã lưu") | `form/ui/dropdown`, `tabs`, `toast` | Gõ chữ để nhảy tới mục (typeahead); toast tự ẩn, chồng nhiều cái |
| T9 | **Nghiệm thu GĐ1**: dựng lại launcher của spike bằng materiant — Esc / bấm ra ngoài thì ẩn, kéo được bằng thanh trên (ô nhập không kéo), vị trí kéo tới được nhớ cho lần mở sau — đo RAM so với spike (15,7 MB Task Manager); so ảnh gallery với trang tài liệu materiant ở cả sáng / tối; chạy thử gallery trên macOS và Ubuntu (D-3) | — | Báo cáo `materiant/docs/gd1-report.md` |

T1 → T2 → T3 là lõi, phải đi trước. Từ T4 trở đi độc lập nhau, làm theo thứ tự fastcast cần.

## Port khi cần (không làm ở GĐ1)

slider, progress, skeleton, expandable, paginator, datepicker, chart, carousel, media (lightbox, video player), sheet,
dragdrop, gesture.

## Không port

`editor`, `code`, `effect/wave`, `effect/glass`, `effect/edge-lighting`, `effect/shimmer-text`, `seo`, `observe` (đặc
thù web), `vendor`. Tính năng editor / code editor có sẵn trong gpui-base cũng không dùng.

## Rủi ro cần canh

- `gpui-base` kéo theo crate của phần editor (html5ever, markdown, lsp-types, ropey…). Nhiều khả năng chỉ tốn thời gian
  build, không vào exe nếu không gọi tới — T0 đo cỡ exe của gallery; phình thì vendor rồi cắt module.
- gpui-pre không có blend mode ⇒ ripple tông sáng hơi khác bản web.
- gpui-base chưa chạy lần nào trên macOS / Ubuntu — T9 mới thử. Lỗi nền tảng phát hiện muộn ⇒ nếu cần, chạy sớm
  gallery trên Mac sau T3.

## Câu hỏi cho chủ dự án

- Q-2 (`docs/decisions.md`): URL remote cho `materiant`. Chưa có thì cứ làm local.
- ~~T0b làm ngay hay dời?~~ — đã làm cùng lúc dọn plan 29/10/2026 (còn output style `terse`).
