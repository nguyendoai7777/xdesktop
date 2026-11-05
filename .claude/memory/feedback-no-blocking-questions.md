---
name: feedback-no-blocking-questions
description: "Không để session (cả phiên chính lẫn session con) dừng hỏi chủ dự án — tự chọn, ghi lý do ở mục 9 task; không còn confirm.md"
metadata:
  type: feedback
---

Chủ dự án không muốn bất kỳ session nào dừng chờ chọn đáp án (AskUserQuestion) — tự chọn phương án tốt nhất, làm luôn,
ghi lý do vào mục 9 task. Đã chốt thành D-9 trong `docs/decisions.md` (30/10/2026).

05/11/2026: bỏ hẳn `<repo>/plan/confirm.md` — cải tiến / lựa chọn tự làm không cần log vào sổ soát riêng, không tạo lại
tệp này, brief session con không dặn ghi nó.

**Why:** họ hay vắng máy; session con dừng hỏi làm chậm tiến độ ("dự án này hiện chưa cần phải confirm kỹ"); sổ confirm.md
không ai đọc nên thừa.

**How to apply:** brief của session con luôn ghi "KHÔNG dùng AskUserQuestion"; phiên điều phối cũng tự chọn thay vì
hỏi. Luật cứng (giấy phép, dịch vụ trả phí, push, an toàn máy — [[user-profile]]) vẫn giữ. Chuỗi task: [[feedback-chain-tasks]].
