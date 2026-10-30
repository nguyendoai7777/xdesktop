# gd4_07 — icon app cho exe + khay

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ 30/10/2026 — chờ kiểm tay C7 |
| Repo | fastcast |
| Cỡ | S — ~150 dòng |
| Phụ thuộc | — (không đụng tệp của gd4_01, chạy cùng đợt 0) |
| Quyết định áp dụng | F-10, D-2 |
| Phụ thuộc mới | `build-dependency`: `embed-resource` (MIT, chỉ lúc build); soát `cargo deny`. Icon khay giải mã bằng `resvg` hay PNG sẵn: chọn cách không thêm crate vào daemon lúc chạy |
| File đụng tới | MỚI `assets/icon/app-icon.{ico,icns,png}`, `tools/export-icon.ps1`, `crates/daemon/build.rs`, `crates/ui/build.rs`, `crates/daemon/res/app.rc`, `crates/ui/res/app.rc`; SỬA `crates/daemon/src/tray.rs`, `crates/daemon/Cargo.toml`, `crates/ui/Cargo.toml`, `Cargo.lock` |

## 1. Làm gì

- Xuất từ `design/fastcast-icon/app-icon.svg` (F-10): `.ico` 16–256, `.icns`, PNG 512. Tệp sinh ra commit vào repo, script chỉ chạy lại khi đổi icon.
- Nhúng vào `fst.exe`, `fastcast-ui.exe` qua resource Windows. Hai worker chạy ẩn, không cần.
- Icon khay: đọc từ resource / RGBA nhúng cỡ 16, 20, 24, 32 theo DPI, thay icon tạm hiện tại.

## 2. Không làm trong task này

Bản cài (gd4_09). Icon `.app` (gd4_13), `.desktop` (gd4_17).

## 2b. Phân vai

| Phần việc | Ai |
|---|---|
| Công cụ xuất, resource, khay, test | `[opus]` |
| Khay + Explorer + Alt+Tab ở từng tỉ lệ | `[owner-qa]` |

## 5. Đo

Icon khay nằm trong daemon: RAM phải giữ ≤ 5 MB. Máy nhà không chạy `fst` thật khi thử ⇒ đo ở gd4_18; ở làn này đo cỡ `fst.exe` trước / sau, tăng không quá 150 KB.

## 6. Nghiệm thu

- C1 `[opus-unit]` Cho `fst.exe`, `fastcast-ui.exe` đã build / Khi gọi `ExtractIconExW` / Thì có một icon lớn + một icon nhỏ (`crates/{daemon,ui}/tests/exe_icon.rs`, không mở cửa sổ).
- C2 `[opus-unit]` Cho bốn tệp `tray-*.rgba` / Khi `Icon::from_rgba` / Thì nhận cả 16, 20, 24, 32; góc trong suốt, hình chạm mép trên + dưới, lớp trên đỏ đặc.
- C3 `[opus-unit]` Cho DPI 96, 120, 144, 168, 192, 384 / Khi chọn cỡ / Thì 16, 20, 24, 32, 32, 32; lệch 1 DPI không phóng to.
- C4 `[opus-unit]` Cho `.ico`, `.icns`, `.png` / Khi đọc đầu tệp / Thì ICO có 16–256, ICNS có `ic07`–`ic10`, PNG 512.
- C5 `[opus-run]` Bốn lệnh soát + `cargo deny` xanh; `fst.exe` tăng ≤ 150 KB.
- C6 Không bật khay trên máy nhà trong làn này (icon khay nằm ở taskbar màn LG).
- C7 `[owner-qa]` Khay + Explorer + Alt+Tab hiện đúng icon ở 100 %, 125 %, 150 %.

## 8. Nợ chuyển task khác

- gd4_09, gd4_13, gd4_17: dùng icon ở `assets/icon/` (khối bàn giao trong từng tệp).
- gd4_18: đo RAM daemon ≤ 5 MB với icon + manifest DPI mới.

## 9. Bàn giao thực tế

- Opus chọn 30/10/2026: khay nhúng RGBA thẳng (`include_bytes!`), không decoder, không crate lúc chạy — vì đọc từ resource sẽ ra icon có ô nền, trái thiết kế khay chỉ vẽ hình.
- Opus chọn 30/10/2026: công cụ xuất là crate Rust ngoài workspace `tools/export-icon/` (`resvg`) do `export-icon.ps1` gọi — vì máy không có ImageMagick / rsvg / Python; không vào bản phát hành. Thêm `assets/icon/tray-glyph.svg` làm nguồn icon khay.
- Thêm ngoài danh sách tệp: `crates/daemon/res/app.manifest` khai báo PerMonitorV2. Không có nó `GetDpiForSystem` của daemon luôn ra 96, khay luôn cỡ 16. Hệ quả: menu khay cũng vẽ theo DPI thật, cần xem ở C7.
- Đo: `fst.exe` release 1.266.688 → 1.297.920 byte (+30,5 KB, trần 150 KB). RAM chưa đo (gd4_18). Kiểm thử `aarch64-apple-darwin` của daemon xanh: build.rs bỏ qua resource khi đích không phải Windows.
- Chờ kiểm tay: C7, ghi `plan/_backlog.md`. Khay chưa bật lần nào trong làn này.

## 10. Đề xuất cải tiến

- [ux] Đổi tỉ lệ màn khi daemon đang chạy thì icon khay giữ cỡ cũ — `tray.rs` `app_icon` chỉ gọi lúc tạo khay — bắt `WM_DPICHANGED` rồi `set_icon` — nét hơn sau khi đổi tỉ lệ — S — P3. Vào backlog: máy nhà không được bật khay nên không thử được.
- Bảo mật / riêng tư: không áp (không IPC, không tệp lúc chạy). RAM: RGBA 9 KB nằm trong exe, chỉ một cỡ được chép ra lúc tạo khay. Pro: không áp.
