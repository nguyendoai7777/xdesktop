---
name: feedback-no-python-use-node
description: Các máy của chủ dự án coi như không có Python; script phụ viết bằng Node.js hoặc pwsh / bash
metadata:
  node_type: memory
  type: feedback
  originSessionId: 60623d0e-22c1-48c1-a834-af228bb3d003
  modified: 2026-11-02T06:27:06.183Z
---

Không dùng Python cho script phụ (sửa tệp hàng loạt, xử lý dữ liệu). Mọi máy đều có Node.js: viết tệp `.js` rồi chạy `node`, hoặc dùng pwsh / bash tuỳ OS.

**Why:** máy không có Python, lệnh `python` trên Windows chỉ trỏ tới alias Microsoft Store nên lỗi và làm mất cả lượt sửa (02/11/2026, chủ dự án nhắc).

**How to apply:** khi cần script, chọn Node.js hoặc pwsh / bash ngay từ đầu, không thử `python` trước. Xem thêm [[user-profile]].
