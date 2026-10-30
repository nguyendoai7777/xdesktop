# gd4_02 — Settings: Chung (ngôn ngữ, giao diện, cỡ chữ, tự khởi động)

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (30/10/2026) — chờ kiểm tay autostart |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd4_01 |
| Quyết định áp dụng | F-2, F-5, D-4, D-9 |
| Phụ thuộc mới | — |
| File đụng tới | SỬA `crates/ui/src/settings/page_general.rs`, `crates/ui/src/app.rs` (`apply_general`); MỚI `crates/ui/tests/settings_general.rs` |

## 0. Bàn giao từ gd4_01 (30/10/2026)

<!-- handoff: gd4_01 -->

- **Đã có sẵn để dùng**: `settings/{mod,view,store,row,page_*}.rs`, `dev::{test_display,is_test_run,pick_dir_answer,run_keys}`, `fastcast_core::entitlement`, `general.themePreset`, `clipboard.excludeFromHistory`, đủ khoá i18n mục 7 của gd4_01. Trang là view stub: điền thân `render` + `new`, tiêu đề trang do `view.rs` vẽ.
- **Đổi so với spec gd4_01**: `store::update` đòi `change: FnOnce(&mut Config) + Send + 'static`. `row::row(label, desc: Option<SharedString>, control)`. Tách OS: `ui/src/platform/{windows,macos,linux}.rs`, `daemon/src/platform/{macos,linux}.rs`, `video/src/{macos,linux}/mod.rs`.
- **Bẫy đã gặp**: `#[derive(IntoElement)]` trong bin cần `use materiant::gpui_kit as gpui;` (mẫu `settings/row.rs`). `cargo fmt` đụng `record/frame.rs` của làn khác: soát `git status` trước khi commit. Máy không có Python.
- **Soát lại khi làm**: `cargo build -p fastcast-ui --bin fastcast-ui --example fake_daemon` rồi `pwsh tools/settings-run.ps1 -Page <trang> -Keys "…" -Theme light -Lang en` (exit 1 nếu sai màn hoặc giành foreground; đọc `CARGO_TARGET_DIR`). Test tích hợp mở cửa sổ thật: đặt `("FASTCAST_SETTINGS_STUB", "0")`, mẫu `tests/settings.rs`.

## 1. Làm gì

- Ngôn ngữ (`Select`), giao diện sáng / tối / hệ thống (`RadioGroup`), preset màu (`Select`), dòng khoá `CustomTheme`.
- Cỡ chữ 12–20 (`NumberField`), áp ngay; `app.rs` đang kẹp 10–32 cho file sửa tay, giữ nguyên.
- Tự khởi động: `Switch` + trễ 0–120 giây; daemon áp qua `ReloadConfig`. Đọc trạng thái thật qua `StatusRequest` nếu đã có trường, không thì theo config.
- Đổi là có tác dụng ngay ở mọi cửa sổ đang mở, không có nút Lưu. `apply_general` áp thêm `themePreset`; đổi preset về `Default` phải trả được màu (`reset_theme` rồi áp lại).
- Ngôn ngữ đổi ⇒ chữ trong Settings đổi ngay; tên lệnh ở launcher đọc lại lúc mở (đã có).

## 2. Không làm trong task này

Theme tuỳ biến thật (chỉ dòng khoá). Nhãn thước theo cỡ chữ lớn (`gd1_08` mục 10): soát ở gd4_18.

## 2b. Phân vai

| Phần | Vai |
|---|---|
| `page_general.rs`, `apply_general`, `tests/settings_general.rs` | `[opus]` (một trang nhỏ, không tách Sonnet) |
| Khởi động lại máy thật | `[owner-qa]` |

## 5. Đo

Đổi cỡ chữ 14 ⇒ 20: một lần vẽ lại dưới 50 ms từ log; không tăng RAM sau 10 lần đổi.

## 6. Nghiệm thu

- C1 `[opus-run]` Khi chạy bốn lệnh soát ⇒ xanh.
- C2–C7 `[opus-unit]` Cho cấu hình tạm, khi đổi bằng phím ngôn ngữ / giao diện / bảng màu / cỡ chữ / tự khởi động / độ trễ ⇒ tệp chỉ khác đúng khoá đó (`tests/settings_general.rs`).
- C8 `[opus-unit]` Cho tệp chỉ đọc, khi đổi cỡ chữ ⇒ log lỗi + `general reverted`, tệp nguyên vẹn. Toast `settings.save_failed` chưa nhìn bằng mắt: test chỉ soát log.
- C9 `[opus-unit]` Preset về `Default` ⇒ trả màu gốc, giữ sáng / tối + cỡ chữ (`app::tests`).
- C10 `[opus-run]` `settings-run.ps1 -Page general` chụp vi / en × sáng / tối × cỡ 12 / 20: không tràn, không cắt chữ. Chỉ màn DELL.
- C11 `[owner-qa]` Bật tự khởi động, khởi động lại máy: daemon lên sau đúng độ trễ.

## 7. Ghi chú UI

Dùng hết bằng bàn phím: Tab qua từng điều khiển, Space / Enter đổi. Khoá i18n có sẵn từ gd4_01.

## 8. Nợ chuyển task khác

- Khoá `settings.autostart_failed` chưa dùng: `autostart::apply` của daemon chỉ ghi log, `ReloadConfig` vẫn trả `Ok`, GĐ4 không thêm IPC. Xem mục 10.
- `gd4_18` (phụ thuộc task này): số đo chính thức.

## 9. Bàn giao thực tế

- **Mã**: `settings/page_general.rs`, `app::apply_general` (reset rồi áp preset + chế độ + cỡ chữ), `tests/settings_general.rs`.
- **Sửa ngoài tệp sở hữu (đã ghi `confirm.md`)**: `store::update` áp vào `UiState` trước khi chờ daemon, `dev::run_keys` phát cả `KeyUp`.
- **Opus chọn 30/10/2026**: trạng thái tự khởi động theo config (`DaemonStatus` không có trường này); độ trễ hoãn ghi 500 ms; gợi ý cỡ chữ đặt ở mô tả dòng.
- **Số đo** (debug, các làn khác đang build, không phải số chính thức): đổi cỡ chữ từ log `general applied` 17–30 ms lúc máy rảnh, có lần tới 104 ms lúc máy bận. RAM 17,6–17,9 MB chưa đổi, 19,2 MB sau 12 lần, 18,9 MB sau 48 lần: tăng một lần rồi không tăng theo số lần đổi.
- **Lệnh soát** (sau khi gộp `master` tới `87ddfcd`): build, clippy, deny xanh; `settings_general` 7/7. `cargo test` đủ còn đỏ chập chờn ngoài phần sửa: `ocr::each_failure_code_shows_its_message` (trước khi gộp, chạy riêng xanh); `fastcast-video --test session`: `low_fps_stops_without_waiting_for_the_slot`, rồi `source_lost_midway_reports_failed_and_keeps_the_video` (3 lần chạy: 2 đỏ, 1 xanh; nhánh không sửa `crates/video`). Ghi `_backlog.md`.
- **Chờ kiểm tay**: C11; nhìn toast của C8.
- **Soi cải tiến**: bảo mật không áp (không IPC mới, log không ghi đường dẫn). UX: bàn phím đủ, 8 tổ hợp đạt. RAM: trên. Pro: dòng khoá `CustomTheme` đã đặt.

## 10. Đề xuất cải tiến

- [ux] Bật tự khởi động hỏng mà người dùng không biết — `daemon.rs::reload` bỏ qua lỗi `autostart::apply` — trả `Message::Error` để hiện `settings.autostart_failed` — báo đúng lỗi — S — P2. Chưa làm: tệp daemon ngoài làn, đổi ngữ nghĩa `ReloadConfig`; vào `_backlog.md`.
- [ux] Sidebar không theo cỡ chữ — ảnh cỡ 20: nhãn sidebar giữ nguyên — `Tabs` của materiant đọc `font_size` — nhất quán — S — P3. Chưa làm: repo materiant, soát cùng gd4_18.
