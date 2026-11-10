---
name: media-wireless-sync
description: Khoanh session vào app media-wireless-sync trong workspace xdesktop (app PC khay hệ thống gửi video sang app điện thoại video-player qua WiFi, Rust + GPUI + materiant) — nạp đúng ngữ cảnh, không quét fastcast / groove. Dùng khi chủ dự án gõ "/media-wireless-sync", "/media-wireless-sync <việc>", hoặc nói sẽ làm việc với app sync WiFi / gửi video sang điện thoại.
argument-hint: "<việc cần làm, bỏ trống nếu chỉ nạp ngữ cảnh>"
---

Session này chỉ làm **media-wireless-sync**. fastcast, groove không liên quan: chỉ dùng chung materiant và luật workspace
(được đọc mã fastcast khi task ghi rõ "bê từ fastcast", vd khay / IPC / autostart).

## Nạp ngay

1. `media-wireless-sync/CLAUDE.md`, `media-wireless-sync/ROADMAP.md`.
2. `.claude/rules/decisions/workspace.md` (D-*) và `media-wireless-sync.md` (W-*; tự nạp khi chạm repo).
3. `media-wireless-sync/plan/_backlog.md`.

## Đọc khi việc cần

| Cần gì | Đọc |
| --- | --- |
| Giao thức, màn hình, máy trạng thái | `media-wireless-sync/PROTOCOL.md` đúng mục (6 = HTTP, 5 = trạng thái, 4 = màn) |
| Task | `media-wireless-sync/plan/media-wireless-sync-gd<N>_*.md`, khung ở `.claude/rules/tasking-convention.md` |
| Component UI | `materiant/API.md` rồi `materiant/api/<module>.md` |
| Khay, IPC, một instance, autostart | mã tương ứng của `fastcast/crates/{core,daemon}` (chỉ đọc) |

## Không đọc

- `fastcast/plan/`, `groove/`, quyết định F-* / G-*.
- `target/`, `materiant/spikes/` trừ khi tài liệu đang đọc trỏ tới.

## Sau khi nạp

Có việc trong tham số ⇒ làm luôn. Không có ⇒ báo một dòng "đã nạp ngữ cảnh media-wireless-sync" rồi chờ.
