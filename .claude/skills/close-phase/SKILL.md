---
name: close-phase
description: Đóng task đã xong của một repo trong workspace xdesktop — dời các tệp task ✅ (`fastcast/plan/gd<N>_*.md`, `<repo>/plan/<repo>-gd<N>*.md`) sang `<repo>/plan/completed/gd<N>/`, đổi đường dẫn tham chiếu, ghi dòng "Lưu trữ" vào lộ trình của repo, chép việc còn treo sang `<repo>/plan/_backlog.md`, commit. Dùng khi chủ dự án nói "đóng giai đoạn", "đóng gđ1 fastcast", "close phase", "dời plan về completed".
---

# Đóng giai đoạn trong `<repo>/plan/`

Bản xdesktop của skill cùng tên ở xbds. Mỗi app một `plan/` trong repo của nó (D-7) ⇒ mọi `git` ở bước này chạy trong repo
đó. Khung đặt tên: `.claude/rules/tasking-convention.md` mục 0.

## 1. Soát trước (đọc, không đổi gì)

1. Tệp của giai đoạn: `<repo>/plan/gd<N>_*.md` (fastcast), `<repo>/plan/<repo>-gd<N>_*.md` (repo khác) + plan chưa tách
   `<repo>-gd<N>.md`. `grep -n "| Trạng thái" <các tệp>` — tệp nào ✅, tệp nào chưa.
2. **Task chưa ✅**: để nguyên trong `plan/`, chỉ dời task ✅; ghi ở dòng "Lưu trữ" task nào còn lại. Không tự đóng thay.
3. Plan chưa tách tệp (`<repo>-gd<N>.md`) chỉ dời khi mọi dòng task trong đó đã xong.
4. Đọc mục 9 / 10 của các task và mục bàn giao giai đoạn trong lộ trình repo — nguồn cho bước 3.
5. Repo còn nhánh / worktree `claude/*` của giai đoạn (`git -C <repo> worktree list`, `branch --list 'claude/*'`) ⇒ báo,
   không tự xoá. Session khác đang ghi vào tệp sắp dời ⇒ chờ nó xong.

## 2. Dời

```bash
git -C <repo> mv plan/<tệp> plan/completed/gd<N>/<tệp>      # từng tệp ✅; không ghi đè tệp đích có sẵn
```

Đổi tham chiếu `plan/<tệp>` ⇒ `plan/completed/gd<N>/<tệp>` trong các tệp vừa dời, tệp còn lại của `plan/`, lộ trình repo.
Trong lộ trình, ngay dưới tiêu đề mục giai đoạn chèn:

```markdown
> **Lưu trữ** — GĐ<N> đóng dd/mm/yyyy, task ở `plan/completed/gd<N>/`. <một câu: kết quả chính>
```

## 3. Chép việc còn treo sang `<repo>/plan/_backlog.md`

Thêm `### GĐ<N> — <tên ngắn> (đóng dd/mm/yyyy, \`plan/completed/gd<N>/\`)`, mỗi gạch một việc làm được: câu hỏi chờ chủ dự
án, `[owner-qa]` chưa kiểm, test đỏ + lệnh sửa, việc đo tay, đề xuất mục 10 đã chọn mà chưa làm. Trỏ về tệp task mục 9 cho
chi tiết, đừng chép lại. Gỡ các gạch của giai đoạn này đã xong.

## 4. Tham chiếu ngoài `plan/` — soát tay

`grep -rn "plan/gd<N>_\|plan/<repo>-gd<N>" CLAUDE.md */CLAUDE.md */ROADMAP.md .claude/skills docs` (bỏ qua `target/`):

- Chỗ trỏ tới một task cụ thể vừa dời ⇒ đổi sang `plan/completed/gd<N>/…`.
- Chỗ nói chung "task ở `plan/gd<N>_*`" cho giai đoạn sau ⇒ để nguyên.
- Comment trong mã ghi "gd1_03" — nhãn lịch sử, không đụng.

## 5. Commit

Commit theo đường dẫn, soát `git status` trước.

```bash
git -C <repo> add -A plan
git -C <repo> commit -m "plan: đóng gđ<N> — dời về plan/completed/gd<N>" -- plan ROADMAP.md
```

Không push (hỏi trước nếu đã có remote).

## 6. Báo chủ dự án

Ba dòng: dời gì sang đâu · `plan/` còn gì của repo đó · việc treo đã ghi ở mục nào (kèm câu hỏi cần chủ dự án chốt).
