---
name: feedback-avoid-uppercase-ui
description: "Nhãn giao diện viết thường, rất hạn chế chữ hoa — chủ dự án thấy khó chịu khi nhìn"
metadata:
  node_type: memory
  type: feedback
  originSessionId: d5bb5cbf-22da-49cb-9f50-919c0d4ef95d
  modified: 2026-10-30T09:40:08.272Z
---

Nhãn trên giao diện viết thường, rất hạn chế dùng toàn chữ hoa (kể cả tên kỹ thuật như `hex`, `rgb`, `oklch`).

**Why:** chủ dự án nói chữ hoa "rất khó chịu khi nhìn" (30/10/2026, khi xem kính lúp lấy màu gd1_09).

**How to apply:** khi thêm nhãn, chip, tab, tiêu đề ở fastcast / materiant thì viết thường, không dùng uppercase transform. Giá trị do chính người dùng chép (mã `#1E90FF`) là dữ liệu, không phải nhãn.
