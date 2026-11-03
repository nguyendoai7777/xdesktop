---
name: handoff
description: Bàn giao khi xong việc trong workspace xdesktop. Chế độ plan — một task trong `<repo>/plan/` (`gd<N>_<NN>` của fastcast, `<repo>-gd<N>_<NN>` của repo khác) vừa ✅, trước khi gộp master: chèn khối "## 0. Bàn giao từ <task>" vào task nhận nó (task kế theo số, hoặc các task ghi nó ở dòng "Phụ thuộc" khi làm làn song song), task cuối giai đoạn thì ghi vào lộ trình repo. Skill run-task mục 6 gọi skill này. Ngoài plan: nén cuộc trò chuyện thành tài liệu bàn giao cho session / agent khác. Dùng khi chủ dự án nói "handoff", "bàn giao", "ghi bàn giao cho task sau", "viết handoff cho session mới".
argument-hint: "<mã task vừa xong, vd gd1_03 · materiant-gd1_04> hoặc 'phiên sau sẽ làm gì'"
---

Bản xdesktop của skill cùng tên ở xbds. Hai chế độ, chọn theo ngữ cảnh, không hỏi: có mã task / task vừa ✅ trong
`plan/` ⇒ **A**; còn lại ⇒ **B**. Luật gốc: `.claude/rules/tasking-convention.md` mục 0 (tên tệp), mục 6 (khuôn bàn giao).

## A. Chế độ plan — một task vừa ✅

Chạy SAU khi task đã điền mục 9 + `Trạng thái` ✅, TRƯỚC khi gộp `master` (run-task mục 6 bước 2). Khác xbds: một
`plan/` cho nhiều repo, tên tệp mang tiền tố repo, và có làn song song ⇒ "task nhận bàn giao" không luôn là số kế tiếp.

### 1. Tìm task nhận bàn giao

Gọi task vừa xong là `T` (`gd1_03` của fastcast, hoặc `materiant-gd1_04`). Chỉ xét task **cùng repo, cùng giai đoạn**:
fastcast ⇒ `fastcast/plan/gd<N>_*.md`; repo khác ⇒ `<repo>/plan/<repo>-gd<N>_*.md`.

1. **Các task ghi `T` ở dòng `| Phụ thuộc |`** — đọc dòng đó của từng tệp. Cách đọc: cụm sau dấu `·` mang tiền tố repo
   (`materiant-gd1_02 (…), gd1_03 (…)`) là task của repo đó **cả cụm** — `gd1_03` ở đây là `materiant-gd1_03`, không
   phải fastcast `gd1_03`. Dải `gd1_01 → gd1_09` tính là phụ thuộc mọi task trong dải.
2. Lộ trình repo có **sơ đồ làn song song** (`materiant/ROADMAP.md`) ⇒ nhận bàn giao = mọi task ở bước 1.
   Không có sơ đồ làn (fastcast) ⇒ task có số **kế tiếp** `NN+1`; task ở bước 1 khác số kế tiếp chỉ được nhắc tên
   trong mục 8 "Nợ" của `T` (không rải khối vào mọi tệp).
3. Bỏ task nhận đã ✅ (bàn giao vô ích) — nêu tên trong báo cáo. Task nhận đang 🔄 (session khác đang làm làn đó) vẫn
   chèn, nhưng **bằng `Edit` chèn khối, không `Write` cả tệp**, và báo chủ dự án để session kia đọc lại.
4. Không còn task nhận nào trong giai đoạn ⇒ `T` là task cuối: ghi bàn giao vào mục "Bàn giao GĐ<N>" của lộ trình repo
   (`fastcast/ROADMAP.md`, `materiant/ROADMAP.md` — chưa có mục thì thêm ngay trên "Rủi ro"), cùng các gạch ở mục 2.
5. **Repo khác** dùng `T` (vd fastcast `gd1_06` ghi `materiant-gd1_04`): KHÔNG chèn khối sang repo đó — task bên kia
   đọc mục 9 của `T` khi bắt đầu (run-task mục 0). Bảo đảm mục 9 của `T` có gạch "Cho <repo>": API thật đã chốt, tên
   khác spec.

### 2. Viết khối

Đọc mục 1 "Làm gì" + dòng "File đụng tới" của từng task nhận để chỉ chép điều **liên quan tới nó**. Chèn ngay SAU bảng
thuộc tính, TRƯỚC mục đầu tiên; có khối bàn giao cũ thì đặt khối mới lên trên:

```markdown
## 0. Bàn giao từ <T> (dd/mm/yyyy)

<!-- handoff: <T> -->

- **Đã có sẵn để dùng**: module / hàm / token / icon / cấu hình `T` để lại mà task này cần (đường dẫn thật, tên thật).
- **Đổi so với lúc viết spec này**: tên hàm, khoá config, thông điệp IPC, tệp đã khác…
- **Nợ chuyển sang đây** (mục 8 của `T` nêu tên task này).
- **Bẫy đã gặp**: điều mất công mới biết và sẽ lặp lại ở task này (API gpui-base, bẫy Windows, khoá build…).
- **Soát lại khi làm**: lệnh / số đo cụ thể (`cargo test -p …`, `tools/measure-ram.ps1`, trang gallery nào).
```

- `<T>` ghi đúng mã có tiền tố repo (`materiant-gd1_04`, `gd1_03`). Dấu `<!-- handoff: <T> -->` để soát (và hook
  sau này) tìm — luôn có.
- 5–15 gạch, mỗi gạch hành động được. KHÔNG chép lại mục 9 của `T` — trỏ `<repo>/plan/<tệp T>` mục 9 cho chi tiết.
- Khối cho các task nhận khác nhau viết riêng theo nhu cầu từng task, không dán một bản cho tất cả.

### 3. Soát + commit

```bash
grep -ln "<!-- handoff: <T> -->" <repo>/plan/*.md <repo>/ROADMAP.md   # đúng các tệp ở bước 1
git -C <repo> commit -m "plan: <T> ✅ + bàn giao" -- plan/<tệp T> plan/<tệp nhận>… ROADMAP.md
```

Commit theo đường dẫn (session song song có thể đang sửa tệp khác của `plan/`). Lộ trình nằm trong repo app ⇒
`git -C <repo> commit -- ROADMAP.md`. Không push.

Báo trong câu trả lời cuối của run-task: một dòng "Bàn giao → <các task nhận>" (+ task nhận nào đang 🔄 của session
khác, task nào bỏ qua vì đã ✅).

## B. Chế độ chung — bàn giao cho session / agent khác

Viết tài liệu bàn giao tóm cuộc trò chuyện hiện tại để một agent mới làm tiếp.

- Nơi lưu: session có thư mục ghi chú chung (dòng "Shared notes folder" trong ngữ cảnh) ⇒ lưu ở đó; không thì thư mục
  tạm của OS (scratchpad của session nếu có). **Không** lưu vào workspace.
- Mở đầu: mục tiêu, trạng thái (đã xong / đang dở / chưa làm), repo + nhánh / worktree đang mở, commit cuối từng repo.
- Không chép lại thứ đã có ở tệp khác (task trong `<repo>/plan/`, `ROADMAP.md`, `docs/decisions.md`, commit, diff) — trỏ
  đường dẫn. Câu hỏi đang chờ chủ dự án ghi nguyên văn.
- Mục "Skill nên gọi": `run-task <mã>` cho task kế, `close-phase` nếu giai đoạn đã xong, `handoff` khi xong task.
- Che thông tin nhạy cảm (khoá API, mật khẩu, dữ liệu cá nhân, đường dẫn ảnh chụp màn hình của chủ dự án).
- Chủ dự án đưa tham số ⇒ coi là việc phiên sau tập trung vào, cắt tài liệu theo đó.

Trả lời chủ dự án: đường dẫn đầy đủ của tài liệu + một câu nói nó dùng cho việc gì.
