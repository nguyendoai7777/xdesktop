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
