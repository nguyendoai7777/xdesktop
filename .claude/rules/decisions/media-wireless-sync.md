---
paths:
  - "media-wireless-sync/**"
  - ".claude/worktrees/media-wireless-sync-*/**"
---

# Quyết định đã chốt — media-wireless-sync

Quy ước ghi: `.claude/rules/decisions/workspace.md`.

| Mã | Quyết định | Ngày |
|---|---|---|
| W-1 | **`media-wireless-sync/PROTOCOL.md` là hợp đồng với app điện thoại `video-player`** (chủ dự án 10/11/2026, mang sang khi khởi tạo repo 11/11/2026): triết lý, màn hình, máy trạng thái và giao thức HTTP v1 (`_vpsync._tcp`, ghép PIN → token lâu dài, upload nối tiếp kiểu tus rút gọn, tải về `Range`). Điện thoại là server, PC là client; Android đã cài, iOS cài sau đúng giao thức này. Đổi giao thức ⇒ sửa `PROTOCOL.md` trước rồi sửa cả hai phía; PC không tự thêm route / header / mã trạng thái. | 10/11/2026 |
| W-2 | **Phạm vi v1: cầu nối, không phải đồng bộ** (PROTOCOL mục 1, 8): đẩy PC → điện thoại là chính, kéo về là phụ, chạy nền ở khay. Không xoá video từ PC, không đồng bộ thư mục hai chiều, không TLS / ghép QR, không đánh thức điện thoại, không gửi song song nhiều máy, chưa iOS. | 10/11/2026 |
| W-3 | **IPv4 + IPv6 và đẩy thư mục như copy/paste** (chủ dự án 11/11/2026): dò + truyền chạy trên cả hai họ địa chỉ (thiết bị = `id` + tập địa chỉ, link-local qua `resolve()` + `scope_id`, PROTOCOL §6.8); thả / dán tệp **và thư mục** ⇒ điện thoại dựng lại cây trong nơi lưu qua header `X-File-Dir`, `list` có `dir`, `info` có `addresses` + `features` (§6.9). Không thêm "nhớ tệp đã gửi theo thiết bị" ngoài bước Checking sẵn có. Vẫn một chiều PC → điện thoại (W-2). | 11/11/2026 |
