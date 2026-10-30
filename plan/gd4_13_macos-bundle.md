# gd4_13 — macOS: `.app` + `.dmg`

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái | ☐ |
| Máy | Mac (`hdiutil`, `codesign` không chạy trên Windows) |
| Repo | fastcast |
| Cỡ | S — ~200 dòng script |
| Phụ thuộc | gd4_06, gd4_07, gd4_10, gd4_11, gd4_12 |
| Quyết định áp dụng | D-2, F-5 |
| Phụ thuộc mới | — |
| File đụng tới | MỚI `installer/macos/Info.plist`, `installer/macos/entitlements.plist`, `tools/build-macos.sh` |

## 0. Bàn giao từ gd4_10 (30/10/2026)

<!-- handoff: gd4_10 -->

- **Đã có sẵn để dùng**: `fst` chạy được làm exe chính của `.app`: `Accessory`, tìm `fastcast-ui` cạnh nó trong `Contents/MacOS/`. Autostart tự nhận `.app` (`autostart.rs::launchd::in_app_bundle`).
- **Đổi so với spec**: `SMAppService` không có độ trễ cấu hình; bản chưa ký có thể bị từ chối và rơi về LaunchAgent `com.fastcast.daemon`. Bundle id khác thì sửa `launchd::LABEL`.
- **Soát lại khi làm**: chưa dòng nào chạy trên Mac, trước hết làm gạch `gd4_10` trong `plan/_backlog.md`. Trong `.app` đã ký ad-hoc: `fst autostart on` in cách đăng ký, đăng nhập lại chỉ có một daemon, launcher không tự bật. Chi tiết: `plan/gd4_10_macos-daemon.md` mục 9.

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
