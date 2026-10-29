---
name: close-phase
description: Đóng một giai đoạn của một repo trong workspace xdesktop — dời các tệp task ✅ của giai đoạn đó (`plan/gd<N>_*.md` của fastcast, `plan/<repo>-gd<N>*.md` của repo khác) sang `completed/<repo>/gd<N>/` ở repo gốc, đổi đường dẫn tham chiếu, ghi dòng "Lưu trữ" vào lộ trình của repo, chép việc còn treo sang `plan/_backlog.md`, commit. Dùng khi chủ dự án nói "đóng giai đoạn", "đóng gđ1 fastcast", "close phase", "dời plan về completed".
argument-hint: "<repo> <số giai đoạn>, vd 'fastcast 1' · 'materiant 1'"
---

# Đóng giai đoạn trong `plan/`

Bản xdesktop của skill cùng tên ở xbds. Khác xbds: một thư mục `plan/` cho cả workspace nên đích tách theo repo —
`completed/<repo>/gd<N>/` (không phải `completed/pharse<N>/`); việc dời ít tệp nên làm bằng `git mv`, không có script.
Khung đặt tên: `plan/_tasking-convention.md` mục 0.

## 1. Soát trước (đọc, không đổi gì)

1. Tệp của giai đoạn: fastcast ⇒ `plan/gd<N>_*.md`; repo khác ⇒ `plan/<repo>-gd<N>_*.md` + plan chưa tách
   `plan/<repo>-gd<N>.md`. `grep -n "| Trạng thái" <các tệp>` — tệp nào ✅, tệp nào chưa.
2. `completed/<repo>/gd<N>/` đã có ⇒ DỪNG hỏi (có thể đã đóng một phần).
3. **Task chưa ✅** ⇒ DỪNG, hỏi từng cái: làm tiếp (không đóng), gác (ghi `plan/_backlog.md`, dời theo giai đoạn với
   `Trạng thái` ⛔ + lý do), hay giữ lại trong `plan/` cho giai đoạn sau (đổi tên sang `gd<N+1>_…` và sửa bảng lộ trình).
4. Plan chưa tách tệp (`<repo>-gd<N>.md`) chỉ dời khi mọi dòng task trong đó đã xong — soát bảng của nó.
5. Đọc mục 9 / 10 của các task và mục bàn giao giai đoạn trong lộ trình repo (`fastcast/ROADMAP.md`) — nguồn cho bước 3.
6. Repo bị chạm còn nhánh / worktree `claude/*` của giai đoạn (`git -C <repo> worktree list`, `branch --list 'claude/*'`)
   ⇒ báo, không tự xoá.
7. Tệp task chưa từng commit ở repo gốc (`git status --short plan/`) ⇒ commit chúng trước (bước 5 dùng `git mv`).

## 2. Dời

```bash
mkdir -p completed/<repo>/gd<N>
git mv plan/<tệp> completed/<repo>/gd<N>/<tệp>      # từng tệp của giai đoạn
```

Sau đó đổi tham chiếu `plan/<tệp>` ⇒ `completed/<repo>/gd<N>/<tệp>` trong: các tệp vừa dời, các tệp còn lại của `plan/`
(bàn giao, phụ thuộc), lộ trình repo. Trong lộ trình, ngay dưới tiêu đề mục giai đoạn chèn:

```markdown
> **Lưu trữ** — GĐ<N> đóng dd/mm/yyyy, task ở `completed/<repo>/gd<N>/`. <một câu: kết quả chính>
```

và đổi cột tệp của bảng task sang đường dẫn mới. Không ghi đè tệp đích có sẵn.

## 3. Chép việc còn treo sang `plan/_backlog.md`

Dưới mục của repo, thêm `### GĐ<N> — <tên ngắn> (đóng dd/mm/yyyy, \`completed/<repo>/gd<N>/\`)`, mỗi gạch một việc làm
được: câu hỏi chờ chủ dự án, `[owner-qa]` chưa kiểm, test đỏ + lệnh sửa, việc đo tay, đề xuất mục 10 đã chọn mà chưa
làm. Trỏ về `completed/<repo>/gd<N>/<tệp>` mục 9 cho chi tiết, đừng chép lại. Gỡ các gạch của giai đoạn này đã xong.

## 4. Tham chiếu ngoài `plan/` — soát tay

`grep -rn "plan/gd<N>_\|plan/<repo>-gd<N>" CLAUDE.md */CLAUDE.md */ROADMAP.md .claude/skills docs` (bỏ qua `target/`):

- Chỗ trỏ tới một task cụ thể vừa dời ⇒ đổi sang `completed/<repo>/gd<N>/…`.
- Chỗ nói chung "task ở `plan/gd<N>_*`" cho giai đoạn sau ⇒ để nguyên.
- Comment trong mã ghi "gd1_03" — nhãn lịch sử, không đụng.

## 5. Commit

Repo gốc có thể có tệp người khác đang sửa ⇒ luôn commit theo đường dẫn, soát `git status` trước.

```bash
git add -A plan completed/<repo>/gd<N>
git commit -m "plan: đóng <repo> gđ<N> — dời về completed/<repo>/gd<N>" -- plan completed/<repo>/gd<N> [CLAUDE.md …]
git -C <repo> commit -m "roadmap: đóng gđ<N>" -- ROADMAP.md    # nếu lộ trình repo đổi
```

Không push (hỏi trước nếu đã có remote).

## 6. Báo chủ dự án

Ba dòng: dời gì sang đâu · `plan/` còn gì của repo đó · việc treo đã ghi ở `_backlog.md` mục nào (kèm câu hỏi cần chủ
dự án chốt).
