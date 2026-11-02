---
name: feedback-isolate-from-machine-config
description: "Chỉ trên máy công ty Linux — xdesktop cách ly khỏi hook, skill, cách xưng hô của kit; Windows / Mac không áp dụng"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 332ac5f2-64a8-43bd-a60f-9f97fa224d35
  modified: 2026-11-02T03:29:14.704Z
---

Chỉ trên máy công ty Linux: trong xdesktop không dùng hook, rule, skill hay cách xưng hô từ `~/.claude` và kit của máy này ("Dạ B", dòng giờ hoàn thành, dòng bằng chứng, sổ phiên...). Xem D-15. Windows và Mac là máy cá nhân, không áp dụng luật này.

**Why:** chủ dự án tách việc riêng khỏi cấu hình công ty, chính họ đã phải nhắc khi Claude làm theo các hook đó.

**How to apply:** trên Linux, hook toàn cục vẫn ép ⇒ báo chủ dự án, không làm theo; worktree mới cần chép `.claude/settings.local.json` từ repo gốc, vì tệp ở gốc không có tác dụng trong repo con. Trên Windows / Mac không tắt hook, không tạo tệp này.
