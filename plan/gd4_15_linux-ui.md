# gd4_15 — Ubuntu: UI, overlay, chụp màn

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 GNOME Wayland |
| Repo | fastcast |
| Cỡ | M — ~600 dòng |
| Phụ thuộc | gd4_01, gd0_07 |
| Quyết định áp dụng | D-3, F-3, F-4 |
| Phụ thuộc mới | `ashpd` (MIT) nếu gd0_07 chọn portal |
| File đụng tới | SỬA `crates/ui/src/platform/linux.rs`, `crates/capture/src/lib.rs` (nhánh `cfg`), `crates/capture/Cargo.toml`, `crates/ui/Cargo.toml`; MỚI `crates/capture/src/portal.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Đóng băng từng màn qua portal theo kết luận gd0_07 (hỏi quyền, `restore_token`, hình học output); thiếu thì ghi rõ thứ phải đổi ở F-3 vào `confirm.md`.
- Overlay toàn màn từng output trên GNOME không có layer-shell: phủ thanh trên, không nhảy focus.
- `platform/linux.rs`: `hide` / `show`, `cursor_display` (Wayland không cho đọc con trỏ toàn cục ⇒ dùng màn đang focus), `set_cursor_pos` (Wayland không cho ⇒ mũi tên chỉ dời điểm nhắm), `exclude_from_capture` no-op.
- Soát font `Noto Sans` (nợ gd2_04), IBus / Fcitx gõ tiếng Việt, hộp thoại lưu, chép ảnh.

## 2. Không làm trong task này

Quay (gd4_16). Sửa nhánh Windows.

## 5. Đo

Overlay 2 màn, khung đầu, thời gian chụp qua portal so với 57 ms của Windows.

## 6. Nghiệm thu

- [ ] Trên Ubuntu: bốn lệnh xanh; danh sách kiểm tay `docs/gd1-report.md` mục 4 + `docs/gd2-report.md` mục 4, hai màn khác scale.
- [ ] Bốn lệnh trên Windows vẫn xanh trước khi gộp.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
