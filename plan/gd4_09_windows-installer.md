# gd4_09 — bản cài Windows

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Repo | fastcast |
| Cỡ | M — ~400 dòng script |
| Phụ thuộc | gd4_06, gd4_07, gd4_08 |
| Quyết định áp dụng | D-2, D-6, F-5, F-9 |
| Phụ thuộc mới | Công cụ dev NSIS (zlib / libpng, cài bằng `winget install NSIS.NSIS`), không vào exe |
| File đụng tới | MỚI `installer/windows/fastcast.nsi`, `tools/build-installer.ps1`, `tools/installer-e2e.ps1`; SỬA `tools/fetch-ocr-models.ps1`, `spikes/ocr/results/manifest.int8-mix.toml`, `crates/ocr/src/engine/mod.rs`, `crates/daemon/src/cli.rs` |

## 0. Bàn giao từ gd4_06 (30/10/2026)

<!-- handoff: gd4_06 -->

- **Đã có sẵn để dùng**: `pwsh tools/gen-licenses.ps1 -Out <thư mục>` ra `third-party.html`; cần `cargo install cargo-about --locked --features cli`. Không cần mạng ngoài `cargo fetch`.
- **Việc của task này**: trang Giới thiệu tìm đúng `licenses/third-party.html` cùng thư mục `fastcast-ui` (`page_about.rs::licenses_path`); thiếu thì báo `about_licenses_missing`.
- **Bẫy đã gặp**: `cargo install cargo-about` không kèm `--features cli` vẫn exit 0 mà không ra exe. `cargo fmt` đụng `record/frame.rs`: soát `git status`.
- **Soát lại khi làm**: mở trang trong bản cài, bấm ba nút. Chi tiết: `plan/gd4_06_about-licenses.md` mục 9.

## 0. Bàn giao từ gd4_07 (30/10/2026)

<!-- handoff: gd4_07 -->

- **Đã có sẵn để dùng**: `assets/icon/app-icon.ico` (16–256) cho `MUI_ICON` / `MUI_UNICON` và `DisplayIcon`; `fst.exe`, `fastcast-ui.exe` đã nhúng icon, hai worker thì không.
- **Đổi so với lúc viết spec này**: `fst.exe` có manifest PerMonitorV2 (`crates/daemon/res/app.manifest`).
- **Bẫy đã gặp**: build exe cần `rc.exe` của Windows SDK; thiếu thì build đỏ, không ra exe mất icon.
- **Soát lại khi làm**: `cargo test -p fastcast-daemon --test exe_icon`. Chi tiết: `plan/gd4_07_app-icon.md` mục 9.

## 1. Làm gì

- Chốt công cụ: **NSIS**. Vì sao: giấy phép Zlib nằm trong D-2, cài theo người dùng không cần quyền admin, một tệp `setup.exe`. Đóng câu hỏi mở ở `ROADMAP.md`; ghi `plan/confirm.md`.
- `build-installer.ps1`: `cargo build --release --locked` (không `dev-env`) → soát `cargo deny` → `gen-licenses.ps1` → `fetch-ocr-models.ps1` → soát sha256 → `makensis`. Ra `dist/fastcast-<version>-setup.exe`.
- Cài vào `%LOCALAPPDATA%\Programs\fastcast`: bốn exe, `models/`, `licenses/`. Có lối tắt Start Menu, mục Apps & Features. Cuối bộ cài có ô "chạy fastcast".
- Gỡ: `fst quit`, `fst autostart off` (thêm lệnh nếu thiếu), xoá thư mục cài. Giữ `config.json` + ảnh, video của người dùng.
- Cài đè bản cũ: tắt daemon + UI trước, giữ cấu hình.
- Đóng gói OCR (backlog gd3_02): đưa `onnxruntime.dll` vào sổ sha256, sửa nhãn `+int8-all` / "(all)" của sổ. Soát lại sha zip ONNX Runtime từ nguồn độc lập (`confirm.md` gd3_03).

## 2. Không làm trong task này

Ký mã (dịch vụ trả phí, chủ dự án quyết: ghi backlog, chưa ký thì SmartScreen cảnh báo). Tự cập nhật. Máy chủ tải. Push, phát hành lên mạng.

## 4. Code

`cargo vendor` theo D-6: `build-installer.ps1 -Vendor` chỉ dùng lúc phát hành thật, không commit thư mục `vendor/`. Tiến trình bật từ app Claude bị ảo hoá AppData + registry (memory `msix-appdata-virtualization`): test soát đường dẫn thực tế, đừng so với `%LOCALAPPDATA%` thật.

## 5. Đo

Cỡ `setup.exe` (dự kiến ~110–130 MB với model 78 MB + dll 17 MB), thời gian build, thời gian cài.

## 6. Nghiệm thu

**An toàn máy thật**: test chỉ dùng cài im lặng vào thư mục tạm (`setup.exe /S /D=<tạm>`), **không chạy `fst` đã cài**, không mở cửa sổ bộ cài (bộ cài NSIS mở ở màn chính).

- [ ] `installer-e2e.ps1`: cài im lặng → đủ tệp, sha256 khớp, `fst --version` không đăng ký phím → `fastcast-ocr` thật đọc một ảnh tổng hợp qua `tools/ocr-e2e.ps1` → gỡ im lặng → thư mục cài mất, không còn tác vụ Task Scheduler, mục Uninstall.
- [ ] Không có tên biến `FASTCAST_OCR_EXE`, `FASTCAST_REC_WINDOW` trong exe phát hành.
- [ ] `licenses/third-party.html` có trong bản cài; nút Giới thiệu trỏ đúng đường dẫn tương đối.
- [ ] `[owner-qa]` Cài thật bằng bộ cài có giao diện: SmartScreen, chạy, khay, phím tắt, khởi động lại máy, gỡ, cài đè bản cũ.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
