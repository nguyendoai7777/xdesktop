# materiant-gd0_01 — Dựng crate `materiant` + khung song song cho GĐ1

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (29/10/2026) |
| Repo | materiant |
| Cỡ | S — ~350 dòng (phần lớn là stub + gallery) |
| Phụ thuộc | — · **chủ dự án chốt giấy phép `CC0-1.0`** (mục 9 / `docs/decisions.md` D-2) trước khi bắt đầu |
| Quyết định áp dụng | D-1 (tên), D-2 (giấy phép), D-6 (nền GPUI), D-7 (bố cục plan + spike) |
| Phụ thuộc mới | `gpui-kit` =0.8.1, `default-features = false` (⇒ `gpui-pre` 0.3.10 + `gpui-base` 0.8.1; Apache-2.0) |
| File đụng tới | `Cargo.toml` MỚI · `Cargo.lock` MỚI · `rustfmt.toml` MỚI · `deny.toml` MỚI · `.gitignore` SỬA · `CLAUDE.md` VIẾT LẠI · `src/lib.rs` + mọi stub module (mục 3) MỚI · `examples/gallery/main.rs` + `examples/gallery/pages/*.rs` MỚI |

GĐ0 của materiant = mọi thứ **setup** để các task GĐ1 (port component) giao song song cho nhiều session mà không
đụng nhau. Lộ trình + sơ đồ làn: `materiant/ROADMAP.md`.

## 1. Làm gì

- `Cargo.toml`: package `materiant`, edition 2024, `rust-version = "1.96"`, `publish = false`, license
  `LicenseRef-materiant-proprietary` (mã đóng, D-2); `gpui-kit = { version = "=0.8.1", default-features = false }` —
  soát `cargo tree -e features` thật sự không kéo `gpui-component`. Profile release giống fastcast (strip, lto thin,
  `panic = "abort"`). `Cargo.lock` commit (có example).
- `rustfmt.toml` chép `../fastcast/rustfmt.toml`; `deny.toml` chép `../fastcast/deny.toml` + thêm giấy phép chủ dự án
  vừa chốt (dự kiến `CC0-1.0`, kèm chú thích crate nào cần) ⇒ `cargo deny check licenses` xanh trên cả 3 target.
- `src/lib.rs`: `pub fn init(cx: &mut App)` (rỗng, gd1_01 điền) + khai **sẵn mọi module GĐ1** (mục 3), mỗi module là
  stub một dòng doc `//! <component> — materiant-gd1_NN (chưa làm)`. Tên module / tệp chốt ở đây; task GĐ1 không thêm.
- `examples/gallery/`: cửa sổ GPUI một sidebar trái liệt kê **mọi trang** (mục 3) + vùng nội dung; mỗi trang một tệp
  `pages/<trang>.rs` có hàm `render(window, cx) -> impl IntoElement` trả chữ "chưa làm". Thanh trên: nút đổi sáng / tối
  (gd1_01 nối vào theme; ở đây chỉ đổi cờ) + nhãn RAM (đọc private working set, mẫu ở spike `gpui-proto`).
- `CLAUDE.md` viết lại đầy đủ: bố cục module, API builder, luật tệp chung khi làm song song (ROADMAP mục Nguyên tắc),
  luật màu / số đo chỉ qua theme + `style.rs`, component không chứa chữ cố định, lệnh soát, bẫy (mục 4), bảng spike.
- Soát spike `spikes/ui-foundation/gpui-proto` vẫn `cargo build` được khi gốc đã là package (cargo dò workspace ngược
  lên); lỗi thì thêm `[workspace]` rỗng vào `Cargo.toml` của spike.
- Đo cỡ exe gallery release + thời gian build nguội (mục 5) — rủi ro "gpui-base kéo crate editor" trong ROADMAP.

## 2. Không làm trong task này

- Không có component, không có theme thật (gd1_01). Không tạo `ROADMAP.md` (đã có).
- Không thêm crate khác ngoài `gpui-kit` — task GĐ1 cũng không được thêm (cần thì dừng hỏi), nên nếu thấy chắc cần
  (vd `smallvec` đã dùng ở spike) thì thêm luôn ở đây và ghi lý do.
- Không bê output style `terse` (còn ở `plan/_backlog.md`).

## 2b. Phân vai

Cả task `[opus]` (chốt tên module + khung gallery cho mọi task sau). `[owner-qa]`: nhìn gallery mở được.

## 3. Kiểu dữ liệu · module · trang gallery

Module (tệp stub) ⇄ task ⇄ trang gallery:

| Module | Task | Trang gallery |
|---|---|---|
| `theme/mod.rs` | gd1_01 | `theme` (bảng màu, thang trung tính, chữ) |
| `style.rs`, `effect/mod.rs` + `effect/ripple.rs`, `window.rs`, `icon.rs` | gd1_02 | `style` (ripple, icon, vùng kéo) |
| `button.rs`, `kbd.rs` | gd1_03 | `button` |
| `field/mod.rs` (`shell.rs`, `input.rs`, `number.rs`) | gd1_04 | `input` |
| `checkbox.rs`, `radio.rs`, `switch.rs` | gd1_05 | `toggles` |
| `scroll.rs`, `list.rs` | gd1_06 | `scroll` |
| `overlay/mod.rs` (`position.rs`, `stack.rs`, `tooltip.rs`, `popover.rs`, `dialog.rs`) | gd1_07 | `overlay` |
| `menu.rs` | gd1_08 | `menu` |
| `select.rs`, `tabs.rs`, `toast.rs` | gd1_09 | `select`, `tabs`, `toast` |

`examples/gallery/pages/mod.rs`: `enum Page { Theme, Style, Button, Input, Toggles, Scroll, Overlay, Menu, Select,
Tabs, Toast }` + `fn render(page, window, cx)` gọi `pages::<trang>::render`. Thêm trang về sau (GĐ2) mới sửa tệp này.

## 4. Code

- Mẫu khởi động GPUI, đọc RAM, cửa sổ: `spikes/ui-foundation/gpui-proto/src/main.rs`. Đường import thật của
  `gpui-kit` (`gpui_kit::gpui`, `gpui_kit::base`… hay tên khác) — soát docs.rs / mã nguồn crate rồi ghi vào `CLAUDE.md`.
- Mẹo GPUI đã kiểm: `docs/spikes/ui-foundation.md`.
- Bẫy ghi vào `CLAUDE.md`: PowerShell không chờ exe GUI (`| Out-Host`); tiến trình chạy từ app Claude bị ảo hoá AppData
  (memory `msix-appdata-virtualization`); build GPUI nguội lâu ⇒ worktree dùng chung `CARGO_TARGET_DIR`.

## 5. Đo

- Cỡ `target/release/examples/gallery.exe` (so với spike `gpui-proto`) + RAM gallery nghỉ (Task Manager, `bench.ps1`).
- Thời gian `cargo build --release --example gallery` nguội — ghi mục 9 cho các session song song biết mà chờ.

## 6. Nghiệm thu

- C1 `[opus-run]` `cargo run --example gallery` mở cửa sổ, bấm từng trang trong sidebar thấy "chưa làm" tương ứng.
- C2 `[opus-run]` `cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test`, `cargo deny check licenses`
  xanh; `cargo tree -i gpui-component` báo không có.
- C3 `[opus-run]` spike `gpui-proto` vẫn build.
- C4 `[owner-qa]` mở gallery trên Windows, cửa sổ hiện, đổi trang được.

## 7. Ghi chú UI

```
┌──────────┬──────────────────────────────── [☀/☾]  RAM 14.2 MB ┐
│ Theme    │                                                    │
│ Style    │   <nội dung trang>                                 │
│ Button   │                                                    │
│ …        │                                                    │
└──────────┴────────────────────────────────────────────────────┘
```

Chữ trong gallery là tiếng Anh cứng (example nội bộ, không phải UI người dùng).

## 8. Nợ chuyển task khác

- gd1_01: nối nút sáng / tối vào theme, đổi nền gallery theo token.

## 9. Bàn giao thực tế

- **Chủ dự án chốt 29/10/2026**: cho phép `CC0-1.0` (chỉ `tiny-keccak`, build-only, Linux — `gpui-pre-linux` → `zed-xim`
  → `ahash` → `const-random-macro`); ghi luôn `0BSD` + `Apache-2.0 WITH LLVM-exception` vào D-2 (`docs/decisions.md`).
  Dò thật: cả cây materiant chỉ vướng CC0-1.0.
- **Commit** `materiant` `431932a` trên `claude/gd0_01`, gộp `master` (`merge --no-ff`).
- **Soát xanh** (cwd = worktree, `CARGO_TARGET_DIR=materiant/target`): `cargo build --all-targets`, `cargo clippy
  --all-targets -- -D warnings`, `cargo test` (1 test: `pages::tests::page_names_round_trip`), `cargo deny check
  licenses` → `licenses ok`, `cargo fmt --check`. `cargo tree -i gpui-component` → "did not match any packages";
  `cargo tree -e features | grep -c gpui-component` = 0.
- **C1** `[opus-run]` xanh: `gallery.exe` (release), giả lập ↓ ×11 + ↑ ⇒ stdout `PAGE theme … toast → theme → toast`
  đủ 11 trang; chuột bấm sidebar ⇒ `PAGE button / tabs / toggles`; Ctrl+T và nút Dark ⇒ `DARK false`, ảnh chụp thấy
  nền sáng; đóng cửa sổ ⇒ thoát mã 0. Chữ trang là `Not done yet — materiant-gd1_NN` (tiếng Anh theo mục 7, không
  phải "chưa làm").
- **C2** xanh (trên). **C3** xanh: `spikes/ui-foundation/gpui-proto` `cargo build` được, không cần `[workspace]` rỗng
  (gốc là package, không phải workspace ⇒ cargo không nhận spike làm thành viên).
- **C4** `[owner-qa]` chờ kiểm tay: `cargo run --example gallery` trong `materiant/` → cửa sổ hiện, bấm từng mục
  sidebar đổi trang, ↑ / ↓ đổi trang, nút Dark / Ctrl+T đổi nền, nhãn RAM nhảy số.
- **Đo** (Windows 10 19045, máy nhà): exe gallery release **7,0 MB** (spike `gpui-proto` có gpui-component + assets:
  23,2 MB) ⇒ rủi ro "gpui-base kéo crate editor làm phình exe" không xảy ra — LTO + strip bỏ hết phần không gọi.
  RAM gallery nghỉ **13,3–13,5 MB** (Task Manager = `WorkingSetPrivate`); nhãn trong app 13,4 MB — khớp.
  **Build nguội**: `cargo build --release --example gallery` ≈ **5 phút** (240 s phụ thuộc + ~60 s crate + LTO thin);
  `cargo build --all-targets` debug sau đó 2 m 33 s; release lặp lại khi chỉ sửa crate ≈ 50–60 s (LTO).
- **Quyết định trong task** (interface cho GĐ1):
  - `materiant::init(cx)` gọi `gpui_kit::init` (= `gpui_base::init`) — app chỉ gọi một hàm; gd1_01 thêm theme vào đây.
  - `pub use gpui_kit;` ở gốc — app (fastcast) dùng `materiant::gpui_kit` khỏi ghim GPUI lần hai.
  - Module con trong `field/`, `overlay/`, `effect/` đã `pub mod` sẵn; task GĐ1 được thêm tệp con trong thư mục của mình
    (gd1_01 cần `theme/color.rs`, `theme/palette.rs`) nhưng không thêm module cấp gốc.
  - Trang gallery: `pub fn render(window: &mut Window, cx: &mut App) -> impl IntoElement`; state qua
    `window.use_keyed_state`. `Page::name()` là nhãn sidebar + giá trị `--page`.
  - Gallery thêm ngoài spec: `--page <tên>`, ↑ / ↓, Ctrl+T, in `PAGE` / `DARK` ra stdout — để session song song chạy
    thẳng trang mình và soát bằng log.
  - `[[example]] test = true` để `cargo test` chạy test trong gallery.
- **Không thêm crate nào ngoài `gpui-kit`** (cả `smallvec`: spike dùng cho `RenderImage` — component GĐ1 không cần).
  Nhãn RAM đọc bằng FFI tay (`K32GetProcessMemoryInfo` + `PROCESS_MEMORY_COUNTERS_EX2`), không kéo `windows-sys`.
- `.gitignore` không phải sửa (đã đủ `/target/`). `ROADMAP.md`: bỏ câu hỏi mở CC0.
- **Bẫy**: chạy `gallery.exe` bằng `Start-Process` thường ⇒ exe console mở cửa sổ console riêng, `MainWindowHandle` là
  console và phím giả lập rơi vào đó — dùng `-NoNewWindow`. `Window::focus` của gpui-pre 0.3.10 nhận `(handle, cx)`.

## 10. Đề xuất cải tiến

Soi bốn lăng kính — bảo mật: không áp (không tệp, không IPC; FFI một lời gọi, đúng bố cục C); Pro: không áp.

- [ux] Component chưa có cách kiểm bàn phím / focus tự động — ROADMAP chỉ đòi test logic thuần, gd1_03…09 lại cấm sửa
  `Cargo.toml` — bật `gpui-kit` feature `test-support` trong `[dev-dependencies]` ngay (một dòng, cùng crate; soát lại
  `cargo deny`) để các task GĐ1 viết test `#[gpui_kit::test]` cho ↑ ↓ Enter Esc — bắt hồi quy bàn phím mà không cần
  chạy tay — S — P2.
- [ram] Nhãn RAM của gallery trên macOS hiện `RAM —` (`examples/gallery/main.rs` mod `ram`) — thêm `task_info`
  `phys_footprint` (cột Memory của Activity Monitor) cho gd1_10 đo RAM trên Mac — S — P3.
