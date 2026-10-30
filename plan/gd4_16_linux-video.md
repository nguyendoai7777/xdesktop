# gd4_16 — Ubuntu: quay vùng + OCR

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ — chờ gd0_07 |
| Máy | Ubuntu 26.04 GNOME Wayland |
| Repo | fastcast |
| Cỡ | M — ~850 dòng; vượt trần ⇒ tách âm thanh trước khi code |
| Phụ thuộc | gd4_01, gd0_07 |
| Quyết định áp dụng | D-2, D-3, F-6, F-7 |
| Phụ thuộc mới | **Dừng phần này chờ chủ dự án**: GStreamer là LGPL, D-2 đòi link động + hỏi trước. Phương án thay: gọi `gst-launch` / exe hệ thống qua tiến trình con, không link |
| File đụng tới | SỬA `crates/video/src/linux/mod.rs`, `crates/video/src/session.rs` (nhánh `cfg`), `crates/video/src/audio.rs` (nhánh `cfg`), `crates/video/src/source/mod.rs` (khai báo), `crates/video/Cargo.toml`, `crates/ocr/src/main.rs` (đường tìm `.so`); MỚI `crates/video/src/linux/{portal,encoder}.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Portal `ScreenCast` → PipeWire → H.264 VAAPI (`vah264enc`), dự phòng OpenH264 tải khi cần (F-7), không x264.
- Âm hệ thống / micro qua PipeWire.
- `fastcast-ocr` chạy trên Ubuntu.

## 2. Không làm trong task này

Sửa nhánh Windows, macOS. Link GStreamer khi chưa có đồng ý: mục cấm của D-2, D-9 không thay luật cứng.

## 5. Đo

720p30: CPU, RAM, tệp mở bằng Totem + trình duyệt + Media Player Windows.

## 6. Nghiệm thu

- [ ] Trên Ubuntu: bốn lệnh xanh, `cargo deny` xanh, quay vùng thật kèm tiếng, OCR tiếng Việt.
- [ ] Chờ quyết định LGPL ⇒ ghi `plan/confirm.md` + `_backlog.md`, làm phần còn lại, không link.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
