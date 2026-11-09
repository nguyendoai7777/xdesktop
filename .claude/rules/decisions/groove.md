---
paths:
  - "groove/**"
  - ".claude/worktrees/groove-*/**"
---

# Quyết định đã chốt — groove (Groovex)

Quy ước ghi: `.claude/rules/decisions/workspace.md`.

| Mã | Quyết định | Ngày |
|---|---|---|
| G-1 | **Viết lại groove bằng Rust + GPUI + materiant, bỏ Tauri + Vue** (chủ dự án 02/11/2026: "ta sẽ write lại rồi"). Không debug thêm lỗi riêng của bản Tauri, như nền mờ xám trắng trên macOS; lỗi đó soát lại sau khi viết lại: `groove/plan/_backlog.md`. | 02/11/2026 |
| G-2 | **Chấp nhận `libasound` (LGPL-2.1) cho âm thanh trên Linux** (chủ dự án 02/11/2026, ngoại lệ theo D-2): `cpal` qua ALSA, chỉ link động với thư viện hệ thống, không kèm vào bản cài, gói `.deb` khai là phụ thuộc, ghi trong trang giấy phép bên thứ ba. | 02/11/2026 |
| G-3 | **Chấp nhận GStreamer (LGPL) cho quay video trên Linux** (chủ dự án 02/11/2026, ngoại lệ theo D-2): chỉ link động với thư viện hệ thống, không kèm vào bản cài, gói `.deb` khai là phụ thuộc, ghi trong trang giấy phép bên thứ ba. Không phụ thuộc `gstreamer1.0-libav`; máy không có VAAPI dùng OpenH264 tải khi cần (F-7). | 02/11/2026 |
| G-4 | **Màu nhấn của groove theo bảng màu chọn ở Settings, mặc định là primary của materiant: xanh Material `#005cbb`** (chủ dự án 03/11/2026: "màu default của ta chuyển về #005cbb … vì theme đã có black pink", Black Pink đổi tên `deeppink`; nền sáng / tối / hệ thống và bảng màu là hai lựa chọn độc lập). Trước đó: **deeppink theo theme materiant, như fastcast** (chủ dự án 02/11/2026: "đổi theme từ cyan về deeppink như bên fastcast"). Thay màu cyan `#06b6d4` của bản cũ (đặt ở groove-gd1_29); không mã màu nhấn cứng trong view, lấy từ theme. | 02/11/2026 |
| G-5 | **Bấm lớp phủ đóng hộp Settings, coi như Huỷ** (chủ dự án 02/11/2026: "thêm tính năng click overlay để đóng dialog"; bỏ nút X ở header). Huỷ trả mọi thay đổi chưa OK về lúc mở, kể cả EQ đã áp tạm, nên không lặp lỗi M3 của bản cũ (bấm ra ngoài giữ EQ mà bỏ phím tắt). | 02/11/2026 |
| G-6 | **Chữ của groove chỉ một độ đậm: normal** (chủ dự án 02/11/2026: "KHÔNG áp dụng font bold / medium, tất cả đều để normal hết"), kể cả tiêu đề trang, tiêu đề hộp thoại, tên app; phân cấp bằng cỡ chữ và màu. Component materiant mặc định đậm thì groove truyền tuỳ chọn normal. | 02/11/2026 |
| G-7 | **Âm lượng và EQ nghe như bản web (Web Audio)** (chủ dự án 02/11/2026): mức to tối đa, đường âm lượng và cách EQ / bass boost tác động phải khớp chuỗi Web Audio của bản Tauri; chủ dự án nghe kỹ, đây là tiêu chí nghiệm thu bằng tai. | 02/11/2026 |
| G-8 | **Hộp sửa thẻ chỉ một cách ghi, không chọn chế độ** (chủ dự án 03/11/2026): làm sạch hết rồi ghi thẻ của app, chỉ giữ khung của app (`TIMELINE`) và khung chỉnh âm thanh lúc phát (ReplayGain, MP3Gain, R128, Sound Check / gapless của iTunes, `RVA2`, `RVAD`, `EQU2`, `EQUA`, `RVRB`), để làm sạch không làm bài nghe khác đi; bài khác khi áp cả nhóm ghi `CleanKeepKnown`. Hộp là một trang, không chia tab (bìa trái, mọi ô phải). Bỏ dropdown chế độ ghi, tab Raw frames, số khung rác ở tiêu đề, cảnh báo thiếu album artist cùng nút Fix grouping, ô Compilation (lưu giữ nguyên cờ có sẵn trong tệp) (đã gom theo thư mục; Apple Music gom theo album, không cần album artist). Số 0 ở số thứ tự, tổng của bài / đĩa, năm, BPM coi là trống: đọc thành ô trống, để trống hay gõ 0 thì xoá khung, không ghi 0. | 03/11/2026 |
| G-9 | **Tên app là `Groovex`, bundle id `com.sandtechs.desktop.groovex`** (chủ dự án 04/11/2026: "app name groove đổi thành Groovex"): mọi chữ người dùng thấy (cửa sổ, menu, bộ cài, `.app`, MPRIS, gói `.deb` `groovex` thay `groove-x`), macOS `CFBundleIdentifier` và AppStream id; Windows AUMID `Sandtechs.Groovex`. Giữ nguyên tên nội bộ để không mất dữ liệu / không đổi lại dock: thư mục dữ liệu `Groove X` (`paths::APP_DIR`), tệp chạy `groove`, Wayland `app_id` `groove` (debug `groove.dev`). Mô tả: trình nghe nhạc thay Groove Music của Microsoft, Windows / macOS / Linux (Ubuntu); xem video chưa có, mô tả ghi "sắp có". | 04/11/2026 |
