# gd4_13 — macOS: `.app` + `.dmg`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Mac (`hdiutil`, `codesign` không chạy trên Windows) |
| Repo | fastcast |
| Cỡ | S — ~200 dòng script |
| Phụ thuộc | gd4_06, gd4_07, gd4_10, gd4_11, gd4_12, gd4_19 |
| Quyết định áp dụng | D-2, F-5 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `installer/macos/Info.plist`, `installer/macos/entitlements.plist`, `tools/build-macos.sh` |

## 0. Bàn giao từ gd4_11 (31/10/2026)

<!-- handoff: gd4_11 -->

- **Đã có sẵn để dùng**: `platform/macos.rs` đủ hàm, `fastcast_capture::macos::{has_screen_access, request_screen_access}`; thiếu quyền thì `overlay::report_capture_error` báo + mở System Settings đúng trang.
- **Bẫy**: chưa có `.app` nên quyền ghi màn gắn theo tiến trình cha (terminal, app Claude). Soát lại C5, C6 của `gd4_11` khi có `.app`: tên fastcast phải hiện trong danh sách quyền; cấp xong có thể phải mở lại tiến trình.
- **Nợ chuyển sang đây**: `NSMicrophoneUsageDescription` trong `Info.plist`; mục `[gd4_19 · ux P2] xin quyền micro` chưa làm, thử cùng lúc khi có `.app`. `LSUIElement` để không hiện Dock: bin thô đang là app thường.
- **Soát lại khi làm**: `cargo test -p fastcast-ui` trên Mac chừng 3 phút, không treo; đo RAM bằng `footprint <pid>`. Số nền mục 9 của `gd4_11`.

## 0. Bàn giao từ gd4_10 (31/10/2026)

<!-- handoff: gd4_10 -->

- **Đã có sẵn để dùng**: `fst` đã chạy thật trên Mac; UI bật cạnh exe nên bốn exe phải cùng nằm ở `Contents/MacOS/`.
- **Đã có sẵn để dùng**: autostart trong `.app` đi qua `SMAppService.mainApp`, chưa ký mà bị từ chối thì dự phòng `~/Library/LaunchAgents/com.fastcast.daemon.plist`. Nhãn này do gd4_10 tự chọn, đổi nếu task này chốt bundle id khác.
- **Đổi so với lúc viết spec này**: daemon tự `exec` lại chính nó với `MallocSpaceEfficient=1` (`platform/macos.rs`), không cần `LSEnvironment` trong `Info.plist`. Sau khi ký, soát lại cờ này vẫn có: `ps eww -p <pid>`.
- **Bẫy**: bản exe rời đã là `UIElement` nhờ `setActivationPolicy`; `.app` cũng nên có `LSUIElement` để không nháy icon Dock lúc khởi động.
- **Bẫy**: từ macOS 26 cửa sổ status item thuộc `Control Center`, không soát khay bằng danh sách cửa sổ theo pid.
- **Soát lại khi làm**: trong `.app` chạy `fst autostart on` rồi `off`, không bật hai lần, không sót plist (C6b của `plan/gd4_10_macos-daemon.md`); `footprint <pid>` sau ≥ 10 s, mốc exe rời 7,7–7,9 MB.

## 0. Bàn giao từ gd4_12, gd4_19 (31/10/2026)

<!-- handoff: gd4_12 -->
<!-- handoff: gd4_19 -->

- **Đã có sẵn để dùng**: `libonnxruntime.dylib` arm64 1.31.1, sha256 `17500d6b1e37e70f43a2c57d94233a1bc29fbcb297be0a5f8c7c13184f3307ba`. Gói nguồn và sha gói ở `tools/fetch-ocr-models.ps1`. Thêm mục `[[runtime]]` `os = "macos"` vào `spikes/ocr/results/manifest.int8-mix.toml`, không thì `check_runtime` chỉ cảnh báo, không chặn dylib lạ.
- **Đã có sẵn để dùng**: `fastcast/target/ocr-models` có dylib, `onnxruntime-licenses/`, `manifest.toml`; thiếu `onnx/`.
- **Bẫy**: máy không có `pwsh`; `tools/build-macos.sh` không nên gọi `fetch-ocr-models.ps1`. Dylib đang ký adhoc, ký lại cùng `.app`. Trong gói có bản `.dSYM` lớn và nhiều tên dylib: chỉ lấy `lib/libonnxruntime.dylib`.
- **Bẫy**: Mac này không có `.onnx`; dựng `.app` có OCR cần chép `onnx/` từ máy Windows (`_backlog.md`, gạch gd4_12).
- **Soát lại khi làm**: quay thật và OCR thật chưa chạy lần nào trên Mac, có thể lộ lỗi ở `crates/video`. `FASTCAST_OCR_MODELS` chỉ hiệu lực với `dev-env`, bản thật đi `Contents/Resources/models` (`crates/ocr/src/main.rs::bundle_models`, mới có unit test).

## 0. Bàn giao từ gd4_06 (30/10/2026)

<!-- handoff: gd4_06 -->

- **Đã có sẵn để dùng**: `pwsh tools/gen-licenses.ps1 -Out <thư mục>` ra `third-party.html`; cần `cargo install cargo-about --locked --features cli`. Không cần mạng ngoài `cargo fetch`.
- **Việc của task này**: trang Giới thiệu tìm đúng `licenses/third-party.html` cùng thư mục `fastcast-ui` (`page_about.rs::licenses_path`); thiếu thì báo `about_licenses_missing`.
- **Bẫy đã gặp**: `cargo install cargo-about` không kèm `--features cli` vẫn exit 0 mà không ra exe. `cargo fmt` đụng `record/frame.rs`: soát `git status`.
- **Soát lại khi làm**: mở trang trong bản cài, bấm ba nút. Chi tiết: `plan/gd4_06_about-licenses.md` mục 9.

## 0. Bàn giao từ gd4_19 (30/10/2026)

<!-- handoff: gd4_19 -->

- **Đã có sẵn để dùng**: quay kèm âm hệ thống / micro trong `fastcast-rec` (`crates/video/src/macos/audio.rs`), mã chưa chạy trên Mac.
- **Bẫy**: `Info.plist` phải có `NSMicrophoneUsageDescription` (bàn giao gd4_12 đã nhắc). Âm hệ thống đi chung quyền Screen Recording, không có quyền riêng.
- **Soát lại khi làm**: chạy các bước gd4_19 trong `_backlog.md` từ trong `.app`, xem hộp thoại xin quyền micro ghi đúng tên app.

## 0. Bàn giao từ gd4_10 (30/10/2026)

<!-- handoff: gd4_10 -->

- **Đã có sẵn để dùng**: `fst` chạy được làm exe chính của `.app`: `Accessory`, tìm `fastcast-ui` cạnh nó trong `Contents/MacOS/`. Autostart tự nhận `.app` (`autostart.rs::launchd::in_app_bundle`).
- **Đổi so với spec**: `SMAppService` không có độ trễ cấu hình; bản chưa ký có thể bị từ chối và rơi về LaunchAgent `com.fastcast.daemon`. Bundle id khác thì sửa `launchd::LABEL`.
- **Soát lại khi làm**: chưa dòng nào chạy trên Mac, trước hết làm gạch `gd4_10` trong `plan/_backlog.md`. Trong `.app` đã ký ad-hoc: `fst autostart on` in cách đăng ký, đăng nhập lại chỉ có một daemon, launcher không tự bật. Chi tiết: `plan/gd4_10_macos-daemon.md` mục 9.

## 0. Bàn giao từ gd4_12 (30/10/2026)

<!-- handoff: gd4_12 -->

- **Đã có sẵn để dùng**: `fastcast-ocr` tìm model ở `Contents/Resources/models` khi exe nằm trong `Contents/MacOS/`. Runtime: `tools/fetch-ocr-models.ps1` trên Mac lấy `libonnxruntime.dylib` arm64.
- **Bẫy**: dylib 44 MB nạp bằng đường dẫn tuyệt đối, phải được ký cùng `.app` (`codesign`, ad-hoc). Thiếu `NSMicrophoneUsageDescription` thì tiến trình bị OS giết khi gd4_19 xin quyền micro.
- **Soát lại khi làm**: quyền Screen Recording tính cho app nào khi `fastcast-rec` là con của `fastcast-ui` trong `.app`; `plan/gd4_12_macos-video.md` mục 9.

## 0. Bàn giao từ gd4_07 (30/10/2026)

<!-- handoff: gd4_07 -->

- **Đã có sẵn để dùng**: `assets/icon/app-icon.icns` (`ic07`–`ic10`, 128–1024, mỗi khối là PNG): chép vào `Contents/Resources/`, trỏ `CFBundleIconFile`.
- **Soát lại khi làm**: `.icns` ghi tay trong `tools/export-icon/src/main.rs`, chưa mở trên Mac lần nào ⇒ xem Finder hiện đúng; `iconutil` hoặc `sips` đọc được tệp. Khay macOS dùng `tray-32.rgba`, không phải template image. Chi tiết: `plan/gd4_07_app-icon.md` mục 9.

## 1. Làm gì

- `fastcast.app`: `fst` là exe chính, kèm `fastcast-ui`, `fastcast-rec`, `fastcast-ocr`, `Resources/models`, `Resources/licenses`, `app-icon.icns`. `LSUIElement = true`. Có `NSScreenCaptureUsageDescription`, `NSMicrophoneUsageDescription` vi / en.
- Ký ad-hoc (`codesign -s -`), `.dmg` kéo vào Applications.
- Bản universal hoặc arm64 + x86_64 riêng: chọn theo cỡ, ghi `confirm.md`.

## 2. Không làm trong task này

Developer ID + notarize: dịch vụ trả phí, chủ dự án quyết, ghi `_backlog.md`. Chưa notarize thì Gatekeeper chặn lần mở đầu, ghi hướng dẫn trong báo cáo.

## 6. Nghiệm thu

- [ ] Trên Mac: cài từ `.dmg`, mở, cấp quyền, khay, phím tắt, chụp, quay, OCR, autostart, gỡ bằng kéo vào Thùng rác.
- [ ] `spctl` + `codesign --verify` báo đúng trạng thái; trang giấy phép mở được từ Giới thiệu.

## 8. Nợ chuyển task khác

## 9. Bàn giao thực tế

## 10. Đề xuất cải tiến
