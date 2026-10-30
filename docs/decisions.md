# Quyết định đã chốt

Nguồn sự thật dùng chung giữa các máy (máy nhà Windows, máy công ty Ubuntu, Mac). Mỗi dòng ghi ngày chủ dự án chốt.
Đổi quyết định ⇒ sửa tại chỗ + ghi ngày đổi, không để hai phiên bản song song. Spec tính năng của fastcast: `fastcast/docs/MVP.md`.

## Chung cho workspace

| Mã | Quyết định | Ngày |
|---|---|---|
| D-1 | **Bố cục repo**: `xdesktop/` là repo gốc (cấu hình workspace, `.claude`, tài liệu, spike). Mỗi app (`fastcast/`, sau này nhiều app khác) và bộ component dùng chung (`materiant/`, crate `materiant`) là repo riêng clone vào thư mục con — giống `xbds`. Tên app đổi từ `fastcapx` ⇒ `fastcast`, thư viện component từ `xui` ⇒ **`materiant`** (repo + crate cùng tên; bỏ tiền tố `rs-` 29/10/2026). | 29/10/2026 |
| D-2 | **Mã đóng, không phân phối mã nguồn, chỉ phát hành bản cài.** Thư viện: MIT, Apache-2.0, BSD, ISC, Zlib, BSL-1.0, Unicode, MPL-2.0 (không sửa), OFL (font); bổ sung 29/10/2026: `0BSD`, `Apache-2.0 WITH LLVM-exception`, `CC0-1.0` (biến thể thoáng hơn / công cộng — vd `tiny-keccak` qua `gpui-pre-linux`). Cấm GPL / AGPL. LGPL chỉ khi link động và phải hỏi trước. Bản cài kèm trang giấy phép bên thứ ba. | 29/10/2026 |
| D-3 | **Một mã nguồn Rust cho Windows · macOS · Linux.** Linux nhắm GNOME Wayland là chính (máy test: Ubuntu 26.04 ở công ty). Thứ tự test: Windows → macOS → Ubuntu; cả ba máy đều có nhiều màn. | 29/10/2026 |
| D-4 | **Có bản Pro trả phí về sau** — hiện chỉ đặt chỗ (kiểu `Entitlement` + huy hiệu "Pro" + dòng bị khoá), chưa làm thanh toán. | 29/10/2026 |
| D-5 | **Quy trình + convention chung bê từ `xbds`** (Opus điều phối + Sonnet, `run-task`, `handoff`, `close-phase`, output style `terse`, worktree + `merge --no-ff`). KHÔNG bê convention / skill Angular / Go. | 29/10/2026 |
| D-6 | **Nền UI cho `materiant`: GPUI, ghim `gpui-kit` =0.8.1** (= `gpui-pre` 0.3.10 + `gpui-base` 0.8.1), **không bật `gpui-component`**. materiant = lớp style materiant dựng trên primitive không-style của `gpui-base` (hành vi, focus, bàn phím, định vị popup có sẵn). Đóng băng: `=0.8.1` + `Cargo.lock` (+ `cargo vendor` khi phát hành). Lý do + số đo: `materiant/docs/spikes/ui-foundation.md` mục 5, 6, 6a, 7. Loại: Slint (port Tailwind chậm hơn), `gpui-ce` (hiệu năng ngang nhưng phải tự viết toàn bộ lớp hành vi), egui (khó làm đẹp). Chủ dự án giao Claude chọn theo tiêu chí "ít công port nhất". | 29/10/2026 |
| D-7 | **Plan + spike**: một thư mục `plan/` ở repo gốc cho cả workspace (không lồng trong `docs/`); task tên `gd<N>_<NN>_<slug>.md` (fastcast), `<repo>-gd<N>_<NN>_<slug>.md` (repo khác); khung ở `plan/_tasking-convention.md`. Lộ trình app ở repo app (`fastcast/ROADMAP.md`). Spike sống trong repo nó phục vụ (`<repo>/spikes/`, báo cáo `<repo>/docs/spikes/`) — spike UI chuyển sang `materiant/`; `slint-proto`, `gpuice-proto` đã xoá (số đo giữ ở báo cáo). | 29/10/2026 |
| D-8 | **Đề xuất cải tiến chủ dự án xác nhận ⇒ làm ngay trong lượt**, không đưa về backlog. Backlog chỉ giữ việc không làm được trong lượt (thiếu máy / thiết bị, dịch vụ trả phí, chờ quyết định khác) kèm lý do. Quy trình: skill `run-task` mục 5. | 29/10/2026 |
| D-9 | **Session không hỏi, không dừng chờ chủ dự án.** Dự án chưa cần xác nhận kỹ; chủ dự án thường vắng máy ⇒ mọi lựa chọn (câu hỏi mở của task, đề xuất mục 10, xung đột merge, task nào làm tiếp) Claude tự chọn phương án tốt nhất và làm luôn, ghi lý do ở mục 9 của task + `plan/confirm.md` để soát sau. Không thay luật cứng (giấy phép, dịch vụ trả phí, push, an toàn máy). Quy trình: skill `run-task`. | 30/10/2026 |

## fastcast

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
| F-10 | **Icon app**: mẫu #9 đợt 2 — ba lớp đặc chồng nhau (dáng "chồng lớp" × khối Raycast), đỏ `#FF7A7A → #E5484D` trên ô nền `#1C1C1C`. Nguồn: `design/fastcast-icon/app-icon.svg` (đầy đủ), `glyph.svg` (chỉ hình, `currentColor`; header launcher tô `#FF6363`). Các mẫu đã xem: `design/fastcast-app-icons*.html`. | 30/10/2026 |

## Câu hỏi mở

| Mã | Câu hỏi | Đề xuất |
|---|---|---|
| Q-1 | Nguồn âm khi quay video | Không (mặc định) / Âm hệ thống / Micro / Cả hai; AAC qua bộ mã hoá của OS |
| Q-2 | Remote git cho repo `materiant` (và `fastcast`) | Chủ dự án tạo repo trống trên GitHub rồi đưa URL; trước đó làm local |
