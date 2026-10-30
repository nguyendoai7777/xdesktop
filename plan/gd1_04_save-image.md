# gd1_04 — Lưu ảnh: Ctrl/Cmd+S và Ctrl/Cmd+Shift+S

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | S — ~300 dòng |
| Phụ thuộc | gd1_03 · materiant-gd1_09 (`Toast` — chưa có thì log + bỏ toast, ghi nợ) |
| Quyết định áp dụng | F-8 |
| Phụ thuộc mới | `image` (MIT / Apache-2.0, chỉ PNG) — đã có trong cây qua xcap |
| File đụng tới | `crates/ui/src/save.rs` MỚI · `crates/core/src/naming.rs` MỚI · `crates/core/src/lib.rs` SỬA · `crates/ui/src/overlay/view.rs` SỬA · `i18n/{vi,en}.toml` SỬA |

## 0. Bàn giao từ gd1_03 (30/10/2026)

<!-- handoff: gd1_03 -->

- **Đã có sẵn để dùng**: phím + nút đã nối — `OverlaySession` là `EventEmitter<ToolbarAction>` (`overlay/toolbar.rs`:
  `Save | SaveAs | Copy | Close`); Ctrl/⌘+S ⇒ `Save`, Ctrl/⌘+Shift+S ⇒ `SaveAs`, nút trên thanh cũng vậy (log
  `overlay: action save`). Chỉ cần `cx.subscribe(&session, …)` trong `overlay::open` (cạnh `dev::run_script`) rồi gọi
  `save.rs` — **không** cần sửa `view.rs` cho phím nữa.
- Vùng: `session.selection.selected()` (đã chọn xong, kể cả lúc đang kéo chỉnh — `action` đã chặn khi `grabbing()`), cắt
  bằng `session.crop(rect)` (RGBA, ghép nhiều màn, khe trong suốt) — gỡ `#[cfg_attr(not(test), expect(dead_code))]` của
  `crop`. Đóng overlay: `session.close(cx)` (đã hoãn `defer`).
- **Đổi so với spec này**: phím đã ở `view.rs::on_key` qua `ToolbarAction::for_key`; dòng "File đụng tới" sửa
  `view.rs` có lẽ không cần — thêm `overlay/mod.rs` (subscribe) thay vào. Vùng chỉnh có thể nằm một phần trong khe giữa
  các màn (kẹp theo hình bao desktop) — PNG giữ phần đó trong suốt.
- **Huỷ hộp thoại ⇒ quay lại overlay**: overlay thật luôn-trên-cùng có thể đè hộp thoại hệ thống — soát `prompt_for_new_path`
  khi cửa sổ PopUp topmost đang mở (màn giả không lộ được lỗi này ⇒ [owner-qa]).
- **Bẫy đã gặp**: kịch bản dev `key` giờ phát cả key-up (nút GPUI chỉ bấm bằng Enter / Space lúc nhả phím) — test bấm nút
  bằng bàn phím: `key 0 tab` ×n rồi `key 0 enter`; Esc khi focus ở nút phải trả focus về gốc (đã sửa). Thanh công cụ
  chỉ dựng ở cửa sổ của màn chứa góc dưới phải vùng, log `overlay: toolbar on <màn> at x,y size WxH`.
- **Soát lại khi làm**: `cargo test -p fastcast-ui --test overlay` (5 test màn giả, mẫu `fake_overlay_edit_selection_and_toolbar`
  dùng `key 0 ctrl-s`); chi tiết `plan/gd1_03_selection-edit.md` mục 9.

## 1. Làm gì

- **Ctrl/Cmd+S** (và nút Lưu): cắt `Frozen::crop(vùng)` → PNG vào `save.imageDir` (mặc định Pictures của OS) tên
  `fastcast_YYYY-MM-DD_HH-mm-ss.png` giờ địa phương; trùng tên ⇒ `_2`, `_3`… (không bao giờ ghi đè). Đóng overlay.
- **Ctrl/Cmd+Shift+S** (và nút Lưu thành…): hộp thoại lưu của hệ thống (`cx.prompt_for_new_path`) mở ở
  `save.lastImageDialogDir` (chưa có ⇒ `imageDir`), nhớ thư mục vừa chọn. Huỷ hộp thoại ⇒ quay lại overlay.
- Mã hoá PNG + ghi file ngoài luồng UI; ghi qua file tạm cùng thư mục rồi đổi tên.
- Thư mục không còn / không ghi được ⇒ thông báo lỗi có đường dẫn, gợi ý Lưu thành…; không mất vùng chọn.
- Toast "Đã lưu <tên tệp>" (bấm ⇒ mở thư mục chứa).
- `naming.rs` (core): tên tệp theo giờ + tìm hậu tố không trùng — hàm thuần, video ở GĐ3 dùng lại.

## 2. Không làm trong task này

- Lưu video (GĐ3). Chọn định dạng khác PNG.

## 3. Kiểu dữ liệu · IPC · cấu hình

Đọc `save.imageDir`, ghi `save.lastImageDialogDir`. **Ghi cấu hình**: đọc lại `config.json` ngay trước khi ghi rồi
chỉ đổi trường của mình (tránh đè thay đổi của `fst autostart` / Settings), ghi qua `config::save`.

## 4. Code

Phím Ctrl/Cmd: dùng `secondary` của GPUI (Cmd trên macOS, Ctrl nơi khác).

## 5. Đo

Thời gian từ Ctrl+S tới file nằm trên đĩa với vùng 3840 × 1080.

## 6. Nghiệm thu

- Ảnh lưu đúng pixel vật lý của vùng (so `Frozen::crop`), kể cả vùng vắt hai màn.
- Lưu hai lần trong cùng một giây ⇒ hai tệp, không ghi đè.
- `lastImageDialogDir` nhớ qua lần khởi động sau.
- Test đơn vị `naming` (đổi ngày, hậu tố, ký tự tiếng Việt trong đường dẫn).

## 7. Ghi chú UI

Khoá i18n: `save.saved`, `save.failed`, `save.open_folder`.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
