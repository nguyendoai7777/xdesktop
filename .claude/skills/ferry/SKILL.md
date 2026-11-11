---
name: ferry
description: Khoanh session vào app ferry trong workspace xdesktop (trước tên media-wireless-sync; app PC khay hệ thống đẩy tệp / thư mục bất kỳ sang app điện thoại qua WiFi, Rust + GPUI + materiant) — nạp đúng ngữ cảnh, không quét fastcast / groove. Dùng khi chủ dự án gõ "/ferry", "/ferry <việc>", hoặc nói sẽ làm việc với app gửi tệp / video sang điện thoại qua WiFi.
argument-hint: "<việc cần làm, bỏ trống nếu chỉ nạp ngữ cảnh>"
---

Session này chỉ làm **ferry**. fastcast, groove không liên quan: chỉ dùng chung materiant và luật workspace
(được đọc mã fastcast khi task ghi rõ "bê từ fastcast", vd khay / IPC / autostart).

## Nạp ngay

1. `ferry/CLAUDE.md`, `ferry/ROADMAP.md`.
2. `.claude/rules/decisions/workspace.md` (D-*) và `ferry.md` (W-*; tự nạp khi chạm repo).
3. `ferry/plan/_backlog.md`.

## Đọc khi việc cần

| Cần gì | Đọc |
| --- | --- |
| Giao thức, màn hình, máy trạng thái | `ferry/PROTOCOL.md` đúng mục (6 = HTTP, 5 = trạng thái, 4 = màn) |
| Task | `ferry/plan/ferry-gd<N>_*.md`, khung ở `.claude/rules/tasking-convention.md` |
| Component UI | `materiant/API.md` rồi `materiant/api/<module>.md` |
| Khay, IPC, một instance, autostart | mã tương ứng của `fastcast/crates/{core,daemon}` (chỉ đọc) |

## Không đọc

- `fastcast/plan/`, `groove/`, quyết định F-* / G-*.
- `target/`, `materiant/spikes/` trừ khi tài liệu đang đọc trỏ tới.

## Sau khi nạp

Có việc trong tham số ⇒ làm luôn. Không có ⇒ báo một dòng "đã nạp ngữ cảnh ferry" rồi chờ.
