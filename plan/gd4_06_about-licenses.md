# gd4_06 — trang giấy phép bên thứ ba + Giới thiệu

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | D-2 |
| Phụ thuộc mới | Công cụ dev `cargo-about` (MIT / Apache-2.0), không vào exe |
| File đụng tới | MỚI `about.toml`, `tools/licenses/{template.hbs,extra.toml}`, `tools/gen-licenses.ps1`, `crates/ui/tests/settings_about.rs`; SỬA `crates/ui/src/settings/page_about.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- `tools/gen-licenses.ps1 -Out <thư mục>` sinh `third-party.html`: cả cây phụ thuộc của 6 target phát hành (cùng danh sách `deny.toml`), gộp theo giấy phép, đủ văn bản.
- `extra.toml`: thứ cargo không thấy: ONNX Runtime + `ThirdPartyNotices.txt` (gd3_03), model PP-OCRv6 + VietOCR (sổ `manifest.toml`), bộ icon, Lucide (ISC), GPUI + `gpui-kit`.
- Trang Giới thiệu: phiên bản, nút mở trang giấy phép (`licenses/third-party.html` cạnh exe, thiếu ⇒ `about_licenses_missing`), mở thư mục dữ liệu, mở thư mục log.
- Script dừng nếu `cargo deny check licenses` đỏ.

## 2. Không làm trong task này

Đọc giấy phép dữ liệu huấn luyện model (`_backlog.md`, việc của chủ dự án; trang ghi đúng nhãn hiện có). Sửa nhãn `+int8-all` của sổ: gd4_09. Chép tệp vào bản cài: gd4_09.

## 4. Code

Không nhúng HTML vào exe (RAM + cỡ). Mở bằng trình duyệt mặc định: `cx.open_url`, khi chạy thử thì chỉ ghi log `about: open <loại>`, không mở cửa sổ ngoài (trình duyệt sẽ bật ở màn chính).

## 6. Nghiệm thu

- [ ] Bốn lệnh soát xanh; `gen-licenses.ps1` chạy được hai lần ra cùng nội dung.
- [ ] Soát tệp sinh ra: có `gpui-pre`, `xcap`, `ort`, `windows`, `objc2`; không có GPL / AGPL.
- [ ] Nút mở khi chạy thử chỉ ghi log. `settings-run.ps1 -Page about` chụp sáng / tối. Chỉ màn DELL.

## 7. Ghi chú UI

Không in đường dẫn đầy đủ của người dùng ra log.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
