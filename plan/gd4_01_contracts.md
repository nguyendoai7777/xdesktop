# gd4_01 — chốt hợp đồng + khung tệp cho các làn GĐ4

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~600 dòng, phần lớn là kiểu dữ liệu, stub, khoá i18n, dời nguyên mã |
| Phụ thuộc | nên sau gd3_13 (cùng sửa `CLAUDE.md`, không chặn: xung đột thì giữ cả hai phía) |
| Quyết định áp dụng | D-2, D-3, D-4, D-9, F-2, F-5, F-8, F-12 |
| Phụ thuộc mới | — (crate của OS khác do làn OS đó thêm trong khối `[target.…]`) |
| File đụng tới | MỚI `crates/core/src/entitlement.rs`, `crates/ui/src/settings/{mod,view,store,row,page_general,page_hotkeys,page_capture,page_pro,page_about}.rs`, `crates/ui/src/dev.rs`, `crates/ui/src/hotkey_dialog.rs` (stub, khai sẵn trong `main.rs` cho gd4_03), `crates/ui/src/platform/{mod,windows,macos,linux}.rs`, `crates/daemon/src/platform/{macos,linux}.rs`, `crates/video/src/{macos,linux}/mod.rs`, `tools/settings-run.ps1`, `crates/ui/tests/settings.rs`; SỬA `crates/core/src/{lib,config}.rs`, `crates/ui/src/{main,commands,notice}.rs`, `crates/ui/src/launcher/mod.rs`, `crates/ui/src/overlay/dev.rs`, `crates/ui/tests/{ipc.rs,common/mod.rs}`, `crates/ui/examples/fake_daemon.rs`, `crates/daemon/src/platform/mod.rs`, `crates/video/src/lib.rs`, `i18n/{vi,en}.toml`, `CLAUDE.md`; XOÁ `crates/ui/src/platform.rs`, `crates/daemon/src/platform/other.rs` |

## 1. Làm gì

Task này tồn tại để các làn sau **không phải sửa chung tệp nào**. Xong task: mọi kiểu, khoá config, khoá i18n, tệp stub của GĐ4
đã có và biên dịch được; mỗi làn chỉ điền phần thân tệp của mình.

- `fastcast_core::entitlement`: mục 3, có test.
- Config: `general.themePreset`, `clipboard.excludeFromHistory` (mục 3), có `#[serde(default)]`, test đọc file cũ.
- `settings/`: cửa sổ thật mở được từ `open_settings`, sidebar + năm trang stub, `store::update`, `row::*`. Từng trang là tệp riêng.
- **Bảo vệ test cũ**: `open_settings` giờ mở cửa sổ. Test `ipc.rs` đang dùng nó làm "lệnh không có cửa sổ" (`wait_log("open_settings: not implemented yet")`, giữ ấm, nhả GPU). Thêm `FASTCAST_SETTINGS_STUB=1` (đặt ở `tests/common`): lệnh chỉ ghi đúng dòng log cũ, không mở cửa sổ. Cập nhật `CLAUDE.md` dòng 50, 134.
- **Một chỗ duy nhất chọn màn chạy thử** — `crate::dev` (mục 3). Launcher `--background`, thông báo, Settings, màn giả đều gọi nó.
- `tools/settings-run.ps1`: mục 4. Làn UI chỉ chạy Settings qua script này.
- Tách mã theo OS: `ui/src/platform.rs` thành `platform/{mod,windows}.rs` (dời nguyên, không đổi hành vi) + stub `macos.rs`, `linux.rs`. `daemon/src/platform/other.rs` thành `macos.rs`, `linux.rs` (cùng nội dung stub). `video/src/{macos,linux}/mod.rs` rỗng, khai trong `lib.rs` theo `cfg`.
- i18n: toàn bộ khoá mục 7 trong `vi.toml` + `en.toml`.
- `CLAUDE.md`: luật màn DELL (mục 7), cách chạy Settings, biến mới, bảng tệp sở hữu trỏ về `ROADMAP.md` mục GĐ4.

## 2. Không làm trong task này

Nội dung thật của trang nào. Thanh toán, kiểm tra giấy phép Pro (D-4 chỉ đặt chỗ). Mã macOS / Linux thật. Sửa `overlay/` ngoài `dev.rs`.

## 2b. Phân vai

Toàn bộ `[opus]`: đây là interface giữa các làn, sai ở đây thì mọi làn sai theo.

## 3. Kiểu dữ liệu · IPC · cấu hình

**Không thêm thông điệp IPC.** Settings ghi `config.json` rồi `ReloadConfig` như gd1_07; daemon đã tự áp phím tắt, ngôn ngữ, autostart. Daemon không đổi ⇒ không đo lại RAM ở task này.

```rust
// crates/core/src/entitlement.rs — D-4: chỉ đặt chỗ. KHÔNG có tệp, khoá, biến môi trường nào bật được Pro.
pub enum Entitlement { Free, Pro }
impl Entitlement { pub fn current() -> Entitlement { Entitlement::Free } }

/// Thứ tự = thứ tự trên trang Pro. Mỗi mục: khoá `pro.<id>` (tên) + `pro.<id>_desc` (mô tả).
pub enum ProFeature {
    CustomTheme, CustomIcons, CustomCommands, NamedRegions, AppHotkeyProfiles,
    FileNameTemplates, CaptureHistory, HighResRecording, RulerSnap, ColorPalette,
}
impl ProFeature { pub const ALL: [ProFeature; 10]; pub fn id(self) -> &'static str; }
```

```rust
// crates/core/src/config.rs
pub struct General { /* cũ */ pub theme_preset: ThemePreset }     // general.themePreset
pub enum ThemePreset { #[default] Default, RoseRed, RebeccaPurple } // snake_case. Black Pink ghim tối nên không vào đây
pub struct ClipboardPrefs { pub exclude_from_history: bool }      // clipboard.excludeFromHistory, mặc định false
```

```rust
// crates/ui/src/settings/mod.rs
pub fn open(cx: &mut App) -> Vec<AnyWindowHandle>;   // gọi từ commands::open, đã nằm trong with_gpu

// crates/ui/src/settings/store.rs — mọi trang ghi cấu hình qua đây, không tự gọi config::save
/// Đọc lại đĩa → `change` → ghi nguyên tử → `ReloadConfig` (daemon) → áp vào UiState. Lỗi: Err để trang báo bằng toast.
pub fn update(cx: &mut App, change: impl FnOnce(&mut Config) + 'static, done: impl FnOnce(Result<(), String>, &mut App) + 'static);

// crates/ui/src/settings/row.rs
pub fn section(title) -> impl IntoElement;
pub fn row(label, desc: Option<_>, control: impl IntoElement) -> impl IntoElement;
pub fn locked_row(feature: ProFeature, cx) -> impl IntoElement;   // tên + mô tả + huy hiệu, không bấm được

// crates/ui/src/settings/page_*.rs — mỗi trang một view, làn chỉ sửa tệp của mình
pub struct GeneralPage;  impl GeneralPage { pub fn new(window, cx) -> Self }  impl Render for GeneralPage { … }
// HotkeysPage, CapturePage, ProPage, AboutPage cùng khuôn

// crates/ui/src/dev.rs
/// Màn của mọi cửa sổ chạy thử: màn không phải màn chính (máy nhà: DELL). Dời nguyên `overlay::dev::fake_display`.
pub fn test_display(cx: &App) -> Option<Rc<dyn PlatformDisplay>>;
/// Đang chạy thử: `--background` hoặc `FASTCAST_OVERLAY_FAKE`. Bản dùng thật luôn `false`.
pub fn is_test_run(cx: &App) -> bool;
/// `FASTCAST_SETTINGS_PICK_DIR=<thư mục>|cancel`: trả lời thay hộp thoại chọn thư mục của OS (hộp thoại OS mở ở màn chính).
pub fn pick_dir_answer() -> Option<Option<PathBuf>>;
```

`notice.rs` hiện chọn màn có con trỏ ⇒ thông báo của lần chạy thử có thể bật trên LG: sửa thành `dev::test_display` khi `is_test_run`.

## 4. Code

- `commands.rs::open`: `Command::OpenSettings` ⇒ `settings::open` (hoặc dòng log cũ khi `FASTCAST_SETTINGS_STUB`).
- Cửa sổ: `WindowOptions { .., ..materiant::window::window_options() }`, mở bằng `gpui_kit::open_window`, cỡ ~860 × 600 logic, có thanh tiêu đề của OS. Sidebar = `materiant::tabs::Tabs::vertical`. Bản thật mở giữa màn có con trỏ; `is_test_run` mở ở `test_display`, `focus: false`.
- Phím chạy thử: `FASTCAST_SETTINGS_KEYS="tab enter wait@300 down"` (`window.dispatch_keystroke`, mẫu `FASTCAST_LAUNCHER_KEYS`), `FASTCAST_SETTINGS_PAGE=general|hotkeys|capture|pro|about`.
- `tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light|dark -Lang vi|en -Out <thư mục>`: đặt `FASTCAST_CONFIG_FILE` tạm, bật `fake_daemon` + `fastcast-ui --endpoint <tag> --command open_settings --background`, chụp đúng cửa sổ bằng `PrintWindow`, in RAM. **Dừng + báo lỗi nếu**: tâm cửa sổ không nằm trên màn không-phải-chính, hoặc foreground đổi. Mẫu: `materiant/tools/gallery-run.ps1`.
- Mẫu đọc-áp-ghi: `launcher/actions.rs::commit`. Nền trang đặc (`c.surface`), không dùng `translucent_window_options`.

## 5. Đo

`pwsh tools/settings-run.ps1 -Page general` in RAM cửa sổ Settings (ghi số làm mốc, mục tiêu ≤ 25 MB); khung đầu từ log.

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh, `cargo check --locked --target aarch64-apple-darwin -p fastcast-daemon -p fastcast-video -p fastcast-capture -p fastcast-ocr` xanh. `fastcast-ui` không soát chéo được: `gpui-pre-apple` chỉ dựng shader Metal trên Mac, nên stub `ui/src/platform/macos.rs` viết theo đúng chữ ký của `windows.rs`, chưa biên dịch tới gd4_11.
- [ ] Config cũ (không có khoá mới) đọc được; `general.themePreset` lạ ⇒ mặc định, không đổi tên tệp hỏng.
- [ ] `Entitlement::current()` luôn `Free`; `ProFeature::ALL` đủ khoá i18n ở cả hai tệp (test).
- [ ] `tests/ipc.rs` xanh như cũ, không mở cửa sổ nào (`FASTCAST_SETTINGS_STUB`).
- [ ] `tests/settings.rs`: mở, đổi trang bằng phím, lệnh lặp đưa cửa sổ lên chứ không mở thêm, đóng xong giữ ấm + nhả GPU đúng.
- [ ] `settings-run.ps1` báo lỗi khi cố tình đặt cửa sổ lên màn chính (thử một lần với cờ `-SelfTest`, không mở cửa sổ thật trên LG: hàm kiểm nhận toạ độ giả).
- [ ] Dời `platform` không đổi hành vi: `tests/overlay.rs`, launcher vẫn xanh.

## 7. Ghi chú UI

```
┌────────────┬──────────────────────────────────┐
│ Chung      │ tiêu đề trang                    │
│ Phím tắt   │ nhãn            điều khiển       │
│ Lưu và quay│ mô tả                            │
│ Pro        │ ...                              │
│ Giới thiệu │                                  │
└────────────┴──────────────────────────────────┘
```

Khoá i18n (`vi` / `en` đủ trong task này, viết thường trừ đầu câu, memory `feedback-avoid-uppercase-ui`):

- `settings.title`, `settings.page_general`, `page_hotkeys`, `page_capture`, `page_pro`, `page_about`, `settings.save_failed`.
- Chung: `settings.language`, `language_vi`, `language_en`, `theme`, `theme_system`, `theme_light`, `theme_dark`, `theme_preset`, `preset_default`, `preset_rose_red`, `preset_rebecca_purple`, `font_size`, `font_size_hint`, `autostart`, `autostart_desc`, `autostart_delay`, `autostart_failed`.
- Phím tắt: `settings.hotkeys_filter`, `hotkeys_change`, `hotkeys_remove`, `hotkeys_history`, `hotkeys_reset`, `hotkeys_reset_all`, `hotkeys_reset_all_confirm`, `hotkeys_none`, `hotkeys_register_failed`, `hotkeys_open_launcher_note`.
- Lưu và quay: `settings.image_dir`, `video_dir`, `dir_choose`, `dir_default`, `dir_unwritable`, `record_res`, `record_fps`, `record_audio`, `record_cursor`, `keep_warm`, `keep_warm_desc`, `clipboard_history`, `clipboard_history_desc`.
- Pro: `settings.pro_note`, `pro.badge`, `pro.<id>` + `pro.<id>_desc` cho mọi `ProFeature`.
- Giới thiệu: `settings.about_version`, `about_licenses`, `about_licenses_missing`, `about_data_dir`, `about_open_logs`.

Làn thiếu khoá ⇒ không sửa `i18n` trong làn (luật ở `fastcast/ROADMAP.md`).

**Luật màn DELL**, chép vào `fastcast/CLAUDE.md` mục "Bẫy khi chạy thử": cửa sổ thử chỉ mở ở màn DELL (màn phụ, x âm); màn LG (màn chính) không mở cửa sổ, không lấy focus, không giả lập phím, không chụp. Không chạy `fst` thật, bản `isolated` (có icon khay), `SendKeys`, `keybd_event`, `CopyFromScreen` trên máy nhà khi chạy thử.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
