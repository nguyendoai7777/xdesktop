---
name: fastcast
description: Khoanh session vào app fastcast trong workspace xdesktop (chụp vùng, thước, lấy màu, OCR, quay vùng) — nạp đúng ngữ cảnh của fastcast, không quét groove. Dùng khi chủ dự án gõ "/fastcast", "/fastcast <việc>", hoặc nói sẽ làm việc với fastcast mà chưa có mã task (có mã task thì dùng run-task).
argument-hint: "<việc cần làm, bỏ trống nếu chỉ nạp ngữ cảnh>"
---

Session này chỉ làm **fastcast**. groove không liên quan: hai app chỉ dùng chung materiant và luật workspace.

## Nạp ngay

1. `fastcast/CLAUDE.md`: bố cục crate, luật riêng, lệnh, bẫy khi chạy thử. Đọc trước khi sửa code.
2. `docs/decisions.md`, mục `Chung cho workspace` và `fastcast` (D-*, F-*).

## Đọc khi việc cần

| Cần gì | Đọc |
| --- | --- |
| Đang ở giai đoạn nào, làn nào sở hữu tệp nào | `fastcast/ROADMAP.md`, chỉ phần liên quan |
| Task | `fastcast/plan/gd<N>_*.md`, khung tệp ở `.claude/rules/tasking-convention.md` |
| Số đo, kiểm tay của giai đoạn trước | `fastcast/CLAUDE.md` mục "Chạy lại số đo", `fastcast/plan/completed/gd<N>/`; báo cáo cũ: `git -C fastcast show b573bfd:docs/gd<N>-report.md` |
| Component UI | `materiant/API.md` rồi `materiant/api/<module>.md`, xem mục dưới |

## materiant

`fastcast-ui` dùng materiant qua đường dẫn `../materiant`. Dùng component: `materiant/API.md` (mục lục) rồi đúng `materiant/api/<module>.md`, không quét `materiant/src`; đọc thêm
`materiant/CLAUDE.md` khi sắp sửa materiant. Sửa materiant là đụng cả app khác ⇒ giữ API chung, không nhét logic riêng
của fastcast, và soát bằng lệnh của materiant.

## Không đọc

- `groove/`, mục `groove` của `docs/decisions.md`.
- `materiant/plan/` trừ khi task fastcast ghi phụ thuộc vào nó.
- `target/`, `dist/`, `release/`, `plan/completed/` của repo khác, `materiant/spikes/` trừ khi `fastcast/CLAUDE.md` trỏ tới.

Tìm kiếm luôn truyền `path` hẹp (`fastcast/crates/ui/src`, không phải gốc workspace): quét từ gốc đi qua thư mục build
nên dễ quá hạn.

## Sau khi nạp

Có việc trong tham số ⇒ làm luôn. Không có ⇒ báo một dòng "đã nạp ngữ cảnh fastcast" rồi chờ. Đừng tóm tắt lại những
gì vừa đọc. Việc chạm groove ⇒ nói rõ là ngoài phạm vi session này.
