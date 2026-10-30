# gd4_09 — bản cài Windows

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ✅ (31/10/2026) — chờ kiểm tay C12 |
| Repo | fastcast |
| Cỡ | M — ~400 dòng script |
| Phụ thuộc | gd4_06, gd4_07, gd4_08 |
| Quyết định áp dụng | D-2, D-6, F-5, F-9 |
| Phụ thuộc mới | Công cụ dev NSIS (zlib / libpng, cài bằng `winget install NSIS.NSIS`), không vào exe |
| File đụng tới | MỚI `installer/windows/fastcast.nsi`, `tools/build-installer.ps1`, `tools/installer-e2e.ps1`; SỬA `tools/fetch-ocr-models.ps1`, `spikes/ocr/results/manifest.int8-mix.toml`, `crates/ocr/src/engine/mod.rs`, `crates/daemon/src/cli.rs`; thêm trong lúc làm: `crates/ocr/src/engine/manifest.rs`, `.gitignore`, `tools/ocr-e2e.ps1` (chú thích) |

## 0. Bàn giao từ gd4_08 (31/10/2026)

<!-- handoff: gd4_08 -->

- **Đã có sẵn để dùng**: `pwsh tools/check-no-dev-env.ps1 -Dir <target>/release` soát bốn exe, thấy tên biến dev thì thoát 1. Build không `dev-env` mới qua.
- **Việc của task này**: `build-installer.ps1` gọi script đó sau bước build, thoát khác 0 thì dừng.
- **Bẫy**: client của `Endpoint::daemon()` từ chối server khác thư mục ⇒ `fst.exe`, `fastcast-ui.exe` phải cài cùng thư mục.

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

## 2b. Phân vai

Toàn bộ `[opus]`: script, NSIS, FFI không có; không có phần ghép UI để giao Sonnet. `[owner-qa]`: C12.

## 2. Không làm trong task này

Ký mã (dịch vụ trả phí, chủ dự án quyết: ghi backlog, chưa ký thì SmartScreen cảnh báo). Tự cập nhật. Máy chủ tải. Push, phát hành lên mạng.

## 4. Code

`cargo vendor` theo D-6: `build-installer.ps1 -Vendor` chỉ dùng lúc phát hành thật, không commit thư mục `vendor/`. Tiến trình bật từ app Claude bị ảo hoá AppData + registry (memory `msix-appdata-virtualization`): test soát đường dẫn thực tế, đừng so với `%LOCALAPPDATA%` thật.

## 5. Đo

Cỡ `setup.exe` (dự kiến ~110–130 MB với model 78 MB + dll 17 MB), thời gian build, thời gian cài.

## 6. Nghiệm thu

**An toàn máy thật**: test chỉ dùng cài im lặng vào thư mục tạm (`setup.exe /S /D=<tạm>`), **không chạy `fst` đã cài**, không mở cửa sổ bộ cài (bộ cài NSIS mở ở màn chính).

Phủ bởi `[opus-run]` = `tools/installer-e2e.ps1`, trừ dòng ghi khác. `fst` luôn là exe giả ghi đối số.

| Case | Cho / Khi / Thì | Phủ | Kết quả |
|---|---|---|---|
| C1 | Thư mục tạm, `setup.exe /S /D=` ⇒ mã 0, bốn exe trùng sha bản build, `uninstall.exe`, không gọi `fst` | run | đạt |
| C2 | Sau cài ⇒ 8 tệp trong sổ (có dll) khớp sha256, `manifest.toml` chính là sổ | run | đạt |
| C3 | `fastcast-ocr` đã cài, `ocr-e2e.ps1` đọc ba ảnh tổng hợp ⇒ ≥ 90 % từ, thoát 0 | run | đạt: 91,6 / 100 / 99,6 % |
| C4 | Exe phát hành + exe đã cài ⇒ `check-no-dev-env.ps1` sạch; `build-installer.ps1` dừng nếu bẩn | run | đạt |
| C5 | `licenses/third-party.html` cạnh exe, nhãn `+int8-mix`; khớp `page_about.rs::licenses_path` | run + unit có sẵn | đạt |
| C6 | Sau cài ⇒ mục Uninstall đúng thư mục, lối tắt trỏ `fst.exe`, không thêm tác vụ tự khởi động | run | đạt |
| C7 | Cài đè ⇒ gọi `quit` của bản cũ, thay exe | run (stub) | đạt |
| C8 | Có tiến trình giữ `fastcast-ui.exe` ⇒ thoát mã 2, không giết, tệp còn nguyên; nhả rồi cài lại được | run | đạt |
| C9 | Gỡ im lặng ⇒ gọi `quit` rồi `autostart off`, thư mục + mục Uninstall + lối tắt mất, tác vụ như trước | run (stub) | đạt |
| C10 | Thư mục có sẵn `models/theirs.txt`, `mine.txt` ⇒ cài không xoá `models/` lạ, gỡ để lại tệp lạ | run | đạt |
| C11 | `fst --version` | unit (parse) | **một phần**: chưa chạy exe thật (luật cấm chạy `fst`), xem C12 |
| C12 | `[owner-qa]` Cài thật bằng bộ cài có giao diện: SmartScreen, chạy, khay, phím tắt, `fst --version | Out-Host` in phiên bản + không đăng ký phím, ba nút Giới thiệu, khởi động lại máy, gỡ (tác vụ Task Scheduler thật phải mất), cài đè bản cũ | chủ dự án | chờ |

Đường `fst quit`, `fst autostart off` thật chỉ có ở C12: e2e chỉ chứng minh bộ cài gọi đúng lệnh, đúng thứ tự.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

Commit: xem `git -C fastcast log --grep gd4_09`. Soát xanh trên nhánh: `cargo build`, `clippy --all-targets -D warnings`, `cargo test -- --test-threads=4`, `cargo deny check licenses`.

**Số đo** (máy bận vừa, số chính thức ở gd4_18): `setup.exe` 65,1 MB (dự kiến 110–130 MB; LZMA đặc nén model tốt hơn dự kiến), build bản cài 95 s khi đã có `target` (build release nguội vài phút), `makensis` ~43 s, cài im lặng 6,2 s, OCR từ bản cài `Ready` 0,9–5,6 s, RAM đỉnh 319–327 MB. sha256 lần cuối: `ea643ee88e57083420b2960072a4aa89ee920fa8e6d2db7a9c61ff006f45b1aa`.

**Sha ONNX Runtime đã soát độc lập**: zip khớp trường `digest` của GitHub API (`5869e26b…`); `onnxruntime.dll` trong zip khớp từng byte `runtimes/win-x64/native/onnxruntime.dll` của gói NuGet `Microsoft.ML.OnnxRuntime` 1.31.1 (`cb2fa518…`). Hai nguồn cùng Microsoft nhưng khác kênh phát hành.

**Chốt**:
- NSIS 3.13 cài bằng tệp `winget download` (đã soát hash) + `__COMPAT_LAYER=RunAsInvoker`, `/S /D=E:\codex\tools\nsis`, vì `winget install` đòi UAC, hộp UAC sẽ chiếm màn LG khi chủ dự án vắng. Máy chưa có thì `build-installer.ps1 -Makensis <đường dẫn>` hoặc đưa lên PATH.
- `models/` dựng từ `-ModelsSource fastcast/target/release/models`, Docker không cần tới. Đường `-Vnocr` (Docker) không chạy lại trong task: mã không đổi ngoài regex + soát dll, sha model giữ nguyên.
- `[[runtime]]` đứng trước `[[model]]`; engine soát sha dll TRƯỚC khi nạp (`Store::check_runtime`), sai ⇒ `ModelCorrupt`; sổ không ghi dll ⇒ cho qua + log (Mac chưa đo, thư mục dev cũ), bản cài bị `build-installer.ps1` bắt phải có mục.
- Paddle trong sổ: nhãn `+int8-mix` (khớp thứ `quantize.py mix` sinh), `source` ghi rõ giữ fp32.

**Bẫy gặp, đã chặn trong script**: `fst autostart off` xoá tác vụ `fastcast-<user>` chung của máy, không theo exe nào; `taskkill /IM` sẽ giết bản ở thư mục khác (làn song song) ⇒ bộ cài không giết theo tên, e2e dùng exe giả. `FileOpen … a` tạo tệp nếu chưa có ⇒ soát `IfFileExists` trước. Tiến trình bật từ app Claude: mục Uninstall, lối tắt thử bị ảo hoá vào LocalCache, e2e đọc cùng ngữ cảnh.

**Chưa chạy**: `fst --version` từ exe thật, `fst quit` / `autostart off` thật, giao diện bộ cài, `-Vendor` chỉ chạy tới `cargo vendor` (ra 769 thư mục), chưa build `--offline` từ đó; đã ghi `plan/_backlog.md`.

**Soi cải tiến**: bảo mật: tìm ra rủi ro `/D=` trỏ thư mục có sẵn `models/` ⇒ đã sửa (C10), sha dll trước khi nạp đã thêm. UI/UX: chữ bộ cài vi / en; bộ cài báo rõ khi app còn chạy. RAM: không áp, không có phụ thuộc mới; `--version` không vào đường daemon. Pro: không áp.

## 10. Đề xuất cải tiến

- [ux] Bộ gỡ tắt tự khởi động bằng `fst autostart off`, ghi luôn `autostart.enabled=false` vào `config.json` được giữ lại — `autostart.rs:83` — cài lại thì tự khởi động đang tắt — cỡ S — P3, chờ chủ dự án xem có thấy khó chịu ở C12.
- [ux] Trang giấy phép chưa nêu NSIS (giấy phép Zlib không bắt buộc ghi ở bản nhị phân) — `tools/licenses/extra.toml` — thêm cho đủ nếu muốn — cỡ S — P3.
