---
name: feedback-no-blocking-questions
description: "Không để session (cả phiên chính lẫn session con) dừng hỏi chủ dự án — tự chọn, ghi plan/confirm.md"
metadata:
  node_type: memory
  type: feedback
  originSessionId: fecf66d7-475f-41ad-b20a-c6107cec6e30
  modified: 2026-10-30T03:43:34.795Z
---

Chủ dự án không muốn bất kỳ session nào dừng chờ chọn đáp án (AskUserQuestion) — tự chọn phương án tốt nhất, làm luôn,
ghi lý do vào mục 9 task + `plan/confirm.md`. Đã chốt thành D-9 trong `docs/decisions.md` (30/10/2026).

**Why:** họ hay vắng máy; session con dừng hỏi làm chậm tiến độ ("dự án này hiện chưa cần phải confirm kỹ").

**How to apply:** brief của session con luôn ghi "KHÔNG dùng AskUserQuestion"; phiên điều phối cũng tự chọn thay vì
hỏi. Luật cứng (giấy phép, dịch vụ trả phí, push, an toàn máy — [[user-profile]]) vẫn giữ.
