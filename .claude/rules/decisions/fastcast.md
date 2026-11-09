---
paths:
  - "fastcast/**"
  - ".claude/worktrees/fastcast-*/**"
  - "cloud/**"
  - ".claude/worktrees/cloud-*/**"
---

# Quyết định đã chốt — fastcast

Quy ước ghi: `.claude/rules/decisions/workspace.md`.

| Mã | Quyết định | Ngày |
|---|---|---|
| F-1 | **Phạm vi**: chụp vùng có chú thích (không chụp cả màn — OS đã có), thước căn, lấy màu, OCR vùng, quay video vùng. Gộp phần hay dùng của FastStone Capture + Flameshot. Đối tượng: dev + dân văn phòng, UX dev-first. | 29/10/2026 |
| F-2 | **UX theo Raycast**: phím tắt mở launcher liệt kê mọi lệnh; gán phím tắt thẳng cho từng lệnh từ launcher (Ctrl+K → gán); Settings dạng sidebar. Giao diện dễ nhìn, không cần bắt mắt. | 29/10/2026 |
| F-3 | **Đóng băng màn hình trước, làm mọi việc trên ảnh tĩnh** (chụp, thước, lấy màu, chọn vùng OCR). Mỗi màn một overlay riêng; vùng chọn theo toạ độ toàn cục, pixel vật lý — hết lỗi màn đen khi các màn khác Hz / DPI. | 29/10/2026 |
| F-4 | **Tiến trình**: daemon rất nhẹ (phím tắt, khay, clipboard, IPC — không GPU, không framework UI) + tiến trình UI bật khi dùng, giữ ấm N phút rồi tự thoát + tiến trình OCR riêng. | 29/10/2026 |
| F-5 | **Tự khởi động cùng hệ thống**: daemon chỉ đọc cấu hình + đăng ký phím + icon khay; độ trễ chỉnh được (mặc định 10–15 s), ưu tiên thấp. Windows: Task Scheduler "At log on"; macOS: `SMAppService`; Ubuntu: `~/.config/autostart/*.desktop` + `X-GNOME-Autostart-Delay`. | 29/10/2026 |
| F-6 | **OCR**: viết lại bằng Rust (crate `ort`) đường `scene` của vnocr (`xbds/bds-service/ocr` — PP-OCRv6 small det + VietOCR, giải mã tham lam); dùng lại model ONNX + `manifest.toml` (sha256, cổng giấy phép). Thêm tiền xử lý cho ảnh chụp màn hình (đảo màu nền tối, phóng chữ nhỏ). Cần spike: int8, bộ bench ảnh chụp màn hình. | 29/10/2026 |
| F-7 | **Video**: chỉ MP4 (H.264) bằng bộ mã hoá của OS (Media Foundation / VideoToolbox / VAAPI-GStreamer), dự phòng OpenH264 tải khi cần — KHÔNG x264. Độ nét 480 / 720 = **cạnh ngắn** của vùng chọn, giữ tỉ lệ, không phóng to, làm tròn số chẵn. FPS nhập 1–60, mặc định 30. Có / không âm thanh khi quay. | 29/10/2026 |
| F-8 | **Lưu**: Ctrl/Cmd+S lưu nhanh vào thư mục mặc định (ảnh: Pictures, video: Videos / Movies), chỉnh được; Ctrl/Cmd+Shift+S mở hộp thoại lưu của hệ thống, nhớ thư mục cuối — tách riêng ảnh và video. | 29/10/2026 |
| F-9 | **Tên lệnh**: exe daemon + CLI là `fst` (`fst status`, `fst run <lệnh>`, `fst autostart on`…); tiến trình con giữ tên `fastcast-ui`, `fastcast-ocr`; tên app, thư mục cấu hình, tác vụ Task Scheduler vẫn là `fastcast`. | 29/10/2026 |
| F-10 | **Icon app**: mẫu #9 đợt 2 — ba lớp đặc chồng nhau (dáng "chồng lớp" × khối Raycast), đỏ `#FF7A7A → #E5484D`, **không nền, hình lớn lề 6/64** cho mọi OS (chủ dự án đổi 02/11/2026: bỏ ô nền `#1C1C1C`, to ra kiểu icon WebStorm). Nguồn: `design/fastcast-icon/app-icon.svg` (đầy đủ), `glyph.svg` (chỉ hình, `currentColor`; header launcher tô `#FF6363`). Các mẫu đã xem: `design/fastcast-app-icons*.html`. | 30/10/2026 |
| F-11 | **Bộ icon chức năng + phím**: cùng hệ với icon materiant — viewBox 24, nét 2 (trừ `stroke_width`: 1 / 2 / 4 có chủ đích), đầu tròn, `currentColor`, nạp bằng `svg()`, màu theo theme (`Icon.color(cx.theme().colors().primary)`). Bản đã chọn → tệp `design/fastcast-icons/<tên>.svg`: 1.6 `ruler`, 2.7 `capture_region`, 3.2 `record_region`, 4.1 `pen`, 5.1 `arrow`, 6.3 `color_picker`, 7.1 `ocr`, 8.1 `rectangle`, 9.1 `ellipse`, 10.1 `text`, 11.6 `blur`, 12.6 `save`, 13.2 `save_as`, 14.5 `copy`, 15.1 `stroke_width`; phím: 16.1 `key_cmd`, 17.1 `key_ctrl`, 18.1 `key_option`, 19.1 `key_shift`, 20.1 `key_enter`, 21.1 `key_tab`, 22.9 `key_esc`, 23.1 `key_space`, 24.3 `key_backspace`, 25.9 `key_delete`, 26.1 `key_caps_lock`, 27.1 `key_up`, 28.1 `key_down`, 29.1 `key_left`, 30.1 `key_right`, 31.2 `key_super`. Bản đặc giữ đặc, cùng khung với bản nét. Trang soát: `design/fastcast-icons.html`; các mẫu đã xem: `design/fastcast-feature-icons.html`. Đã nối vào app: `fastcast/crates/ui/assets/icons/` + `assets::AppIcon` (dòng launcher, thanh công cụ overlay, chip phím `Kbd`); chưa dùng tới (GĐ2 chú thích): `pen`, `arrow`, `rectangle`, `ellipse`, `text`, `blur`, `stroke_width`. | 30/10/2026 |
| F-12 | **Icon tuỳ chỉnh là chức năng Pro** (D-4, chỉ đặt chỗ, làm ở GĐ4): người dùng thay từng icon bằng tệp ảnh, tên tệp ở F-11 là mã của slot. Hướng làm: `materiant::icon` nhận nguồn "icon có sẵn (`svg()`, tô theo theme) hoặc tệp ảnh (`img()`, giữ màu gốc)"; cấu hình `customIcons` { mã slot: đường dẫn }; tệp lỗi / hết Pro ⇒ về icon có sẵn. Định dạng theo thẻ `<img>` của HTML, theo mã `gpui-pre` 0.3.10 (đọc mã, chưa chạy thử): PNG, JPEG, GIF / WebP động, SVG, BMP, ICO được; APNG chỉ khung đầu; AVIF chưa giải mã được (crate `image` không bật feature `avif`, muốn có thì soát giấy phép + đo RAM). | 30/10/2026 |
| F-13 | **Bỏ link chia sẻ ảnh / video** (gd5_08, 09, 10, 14): người dùng gửi ảnh, video qua app chat (gửi thẳng tệp được), link chia sẻ thừa và ít cơ hội khai thác. App gỡ nút Chép link (thanh chụp vùng, bảng quay xong), thẻ Link chia sẻ ở trang Tài khoản, cấu hình `share`, lệnh `Share` của `fastcast-sync`, đường nén video `Transcode` của `fastcast-rec`; lớp `PUT` + thử lại dùng chung giữ ở `sync/src/transport.rs` cho ảnh gốc của lịch sử (gd5_15). Gói Cloud còn đồng bộ + lịch sử trên cloud. API `share/` của server `cloud` gỡ riêng. | 06/11/2026 |
| F-14 | **Phản hồi là form trên web, không có form trong app**: Settings → Giới thiệu → Gửi phản hồi chỉ mở trình duyệt tới `<server cloud>/feedback?app=&version=&os=` (tránh mã thừa trong app). Form bắt buộc email, gửi về server `cloud` (`POST /feedback`). Hiện là khung: chưa lưu, chưa báo cho chủ dự án; lưu trữ + kênh báo dựng sau. | 06/11/2026 |
| F-15 | **Sẽ mua Apple Developer ID** (chưa có ngày; việc trả phí, chủ dự án tự mua): cần cho cập nhật trên macOS — bản ký ad-hoc đổi chữ ký mỗi bản nên mất quyền Ghi màn hình (TCC) sau mỗi lần cập nhật. Cơ chế cập nhật (manifest ký trên `cloud`, nút Cập nhật, `fst` tự khởi động lại) chưa chốt; Linux: xem F-16. | 06/11/2026 |
| F-16 | **Linux cài vào thư mục người dùng** (`~/.local/share/fastcast`, như bản Windows cài theo người dùng `$LOCALAPPDATA\Programs\fastcast`): app tự cập nhật không cần root, không hỏi mật khẩu; ba nền tảng cập nhật cùng một cách. Bản `.deb` cài `/opt` (cần root mỗi lần cập nhật) được thay bằng dạng gói mới này hoặc chỉ còn là đường cài phụ — chốt khi làm task cập nhật. | 06/11/2026 |
| F-17 | **Đổi plan ở bản dev không build lại** (chủ dự án 06/11/2026: "một cờ plan để test dev các gói tính năng"): `start.sh fastcast [màn] --plan=free\|pro\|cloud` (`--free` / `--pro` / `--cloud`; `start.sh` trơn hỏi app rồi plan) đặt biến dev `FASTCAST_PLAN` cho mọi tiến trình. Chỉ bản debug / `dev-env` đọc (qua `worker::dev_env`, bản `pro-unlock` không có chuỗi này) và chỉ **hạ** về Free — đúng D-23, không biến nào bật được Pro. `cloud` = Pro ở máy; quyền ghi đồng bộ / lịch sử trên cloud vẫn do server quyết theo tài khoản (`cloud` `grant <email> cloud`). Bản phát hành chọn plan lúc build: `build.sh` hỏi Free / Pro (= `--pro`). | 06/11/2026 |

## Câu hỏi mở

| Mã | Câu hỏi | Đề xuất |
|---|---|---|
| Q-1 | Nguồn âm khi quay video | Không (mặc định) / Âm hệ thống / Micro / Cả hai; AAC qua bộ mã hoá của OS |
