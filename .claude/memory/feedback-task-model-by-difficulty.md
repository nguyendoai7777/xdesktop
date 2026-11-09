---
name: feedback-task-model-by-difficulty
description: "Chia task theo độ khó: UI dễ không nghiệp vụ giao Sonnet, task cần nghiệp vụ và tư duy giao Opus (D-14)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 09f8135a-3e89-4341-9ede-5ee8e03111a5
  modified: 2026-11-02T01:24:02.165Z
---

Task dễ, code UI, không chứa nghiệp vụ, không cần tư duy cao về hiệu năng ⇒ Sonnet. Task cần nghiệp vụ và tư duy, phải làm kỹ, triệt để ⇒ Opus. Đã chốt thành D-14 trong `.claude/rules/decisions/workspace.md` (02/11/2026).

**Why:** chủ dự án muốn tiết kiệm Opus cho chỗ cần suy nghĩ, không để việc khó rơi vào model yếu hơn.

**How to apply:** Opus tự đánh giá khi chia task, ghi dòng `Model`; mở session con thì truyền đúng `model`. Không chắc thì chọn Opus. Không hỏi lại chủ dự án: [[feedback-no-blocking-questions]].
