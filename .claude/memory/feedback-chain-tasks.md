---
name: feedback-chain-tasks
description: Phiên điều phối: mỗi khi session của một task báo xong, kiểm nhanh rồi tự bốc task kế trong plan và mở session mới chạy nó
metadata:
  type: feedback
---

Phiên điều phối (Opus) giữ chuỗi task chạy liên tục: một session báo task ✅ ⇒ kiểm nhanh (trạng thái trong tệp task,
commit gộp master) ⇒ bốc ngay task kế chưa làm trong `<repo>/plan/` ⇒ mở session mới (`/run-task <tệp>`, wake_when_done)
— không chờ chủ dự án bảo. Dừng ở task chờ chủ dự án (dịch vụ trả phí, kiểm tay máy thật).

**Why:** chủ dự án nhắc hai lần ("cho chạy lần lượt các task khi xong", 05/11/2026 "cứ xong 1 task thì bốc task mới và
new session mới"); có lần chuỗi đứt sau gd5_07 vì phiên điều phối mải việc khác.

**How to apply:** mỗi `<side-sessions-event>` / note của session task ⇒ soát xem đó có phải task trong chuỗi vừa xong không,
nếu có thì giao task kế trong cùng lượt, kể cả khi đang xử lý việc khác. Liên quan: [[feedback-no-blocking-questions]].
