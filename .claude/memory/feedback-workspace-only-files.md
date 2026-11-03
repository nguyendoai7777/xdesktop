---
name: feedback-workspace-only-files
description: Không đọc / ghi gì ngoài workspace xdesktop (kể cả thư mục ghi chú chung của session, /tmp); bằng chứng để ở .ignores/
metadata:
  type: feedback
---

Không đọc, không ghi tệp ngoài workspace `xdesktop` — kể cả "shared notes folder" của side session
(`~/.config/Claude/side-session-notes/...`) hay scratchpad `/tmp/...`. Tệp bằng chứng, diff, log, ảnh chụp ⇒ thư mục
`.ignores/<việc>/` ở gốc workspace (đã gitignore).

**Why:** chủ dự án (03/11/2026): "đây là workspace riêng, đừng mò tới root, sẽ bị phàn nàn"; project đã có đủ cấu hình.

**How to apply:** ghi chú bàn giao giữa session để trong `.ignores/` hoặc plan của repo; brief của harness bảo dùng thư mục
ngoài thì bỏ qua phần đó. Liên quan [[feedback-isolate-from-machine-config]].
