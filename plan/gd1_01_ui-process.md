# gd1_01 — Tiến trình UI trên GPUI: nhận lệnh, giữ ấm

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~450 dòng |
| Phụ thuộc | GĐ0 T2 ✅ (daemon + khung `fastcast-ui`) · materiant-gd1 T0, T1 (crate + theme) |
| Quyết định áp dụng | F-4, D-6, F-2 |
| Phụ thuộc mới | `gpui-kit` =0.8.1 (không bật `gpui-component`) qua `materiant` |
| File đụng tới | `crates/ui/Cargo.toml` SỬA · `crates/ui/src/main.rs` SỬA · `crates/ui/src/app.rs` MỚI · `crates/ui/src/ipc.rs` MỚI · `crates/ui/src/keep_warm.rs` MỚI · `crates/ui/src/commands.rs` MỚI |

## 1. Làm gì

- `fastcast-ui` thành app GPUI: `Application::new().run`, `materiant::init(cx)`, theme / ngôn ngữ / cỡ chữ đọc từ
  `config.json` (`general.*`). Không mở cửa sổ khi chưa có lệnh — tiến trình sống không cửa sổ để giữ ấm.
- Luồng IPC nền (thay vòng `recv_timeout` của khung GĐ0): nhận `Message` từ daemon, đẩy vào vòng GPUI
  (`cx.spawn` + channel / `AsyncApp::update`), không chặn luồng UI.
- `commands.rs`: bảng `Command` → hàm mở tính năng (GĐ1 mới có stub log, các task sau gắn vào). Lệnh lặp khi tính năng
  đang mở ⇒ đưa cửa sổ lên trước, không mở thêm.
- `keep_warm.rs`: hàm thuần — mốc dùng cuối, còn cửa sổ mở thì không tính giờ; hết `keepWarmMins` ⇒ thoát êm. Lệnh
  `Quit` của daemon ⇒ đóng hết rồi thoát.
- `--command <id>` lúc khởi động chạy như một lệnh đến qua IPC.

## 2. Không làm trong task này

- Chưa có cửa sổ tính năng nào (overlay gd1_02, launcher gd1_06).
- Không đổi giao thức IPC.

## 3. Kiểu dữ liệu · IPC · cấu hình

Không thông điệp mới. Đọc `uiProcess.keepWarmMins`, `general.{language, theme, fontSize}`.

## 4. Code

- Mẫu khởi động + đo khung đầu: `materiant/spikes/ui-foundation/gpui-proto/src/main.rs` (`main`, `on_next_frame`).
- Trạng thái app là một `Global` (`UiState`: config, i18n, cửa sổ đang mở theo tính năng).

## 5. Đo

- RAM `fastcast-ui` giữ ấm không cửa sổ (Task Manager, `tools/measure-ram.ps1 -Exe target/release/fastcast-ui.exe`).
- Thời gian từ `fst run capture_region` (UI chưa chạy) tới lúc UI nhận lệnh: nguội và ấm.

## 6. Nghiệm thu

- Lệnh tới qua IPC được ghi log trong ≤ 50 ms khi UI đang ấm.
- Hết giờ giữ ấm ⇒ tiến trình thoát; có cửa sổ mở ⇒ không thoát.
- `fst quit` ⇒ UI thoát theo.
- Test đơn vị cho `keep_warm`.

## 8. Nợ chuyển task khác

- Gắn tính năng vào `commands.rs`: gd1_02 (capture_region), gd1_06 (open_launcher), gd1_08 (ruler), gd1_09 (color_picker).

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
