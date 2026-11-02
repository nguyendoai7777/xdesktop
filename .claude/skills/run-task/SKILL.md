---
name: run-task
description: Điều phối thực thi MỘT task trong `<repo>/plan/` của workspace xdesktop (fastcast, materiant…) theo quy trình Opus điều phối + subagent Sonnet (D-5, bê từ xbds) — nạp ngữ cảnh repo theo dòng "Repo" của task, chốt câu hỏi mở, viết Phân vai + Case test nếu thiếu, tự code phần [opus], giao [sonnet], verify bằng build / clippy / test / deny + chạy thật, soi cải tiến bảo mật · UI/UX · RAM, ghi bàn giao, gộp master. Dùng khi chủ dự án gõ "/run-task <tệp hoặc mã task>", "làm task gd1_03", "làm tiếp fastcast", "làm tiếp plan".
argument-hint: "<tệp task hoặc mã, vd fastcast/plan/gd1_03_selection-edit.md · gd1_03 · 'làm tiếp fastcast'>"
---

Skill giữ **quy trình**; luật riêng của repo (lệnh soát, bẫy, quy ước code) lấy từ `CLAUDE.md` của repo đó, không chép
vào đây. Khung tệp task, trần ước lượng, nhãn phân vai, khuôn bàn giao: `docs/tasking-convention.md` — đọc mỗi lần.

Phiên chính là **Opus**. Trả lời chủ dự án **gọn**, tiếng Việt, không tường thuật từng bước.

**Lỗi phát sinh sửa ngay (D-11).** Gặp lỗi lúc làm ⇒ sửa trong lượt, không ghi backlog; backlog chỉ cho việc thiếu máy / dịch vụ trả phí / chờ kiểm tay.

**Không hỏi, không dừng chờ (D-9).** Chủ dự án thường vắng máy ⇒ KHÔNG dùng `AskUserQuestion` ở bất kỳ bước nào. Chỗ
nào dưới đây ghi "chọn" ⇒ tự chọn phương án tốt nhất, làm luôn, ghi lý do ở mục 9 của task + một gạch vào
`<repo>/plan/confirm.md` (`- [<task>] <việc> — <phương án khác> — <vì sao>`) để chủ dự án soát sau. Thiếu máy / dịch vụ trả
phí / luật cấm ⇒ ghi `<repo>/plan/_backlog.md` rồi đi tiếp phần còn lại.

## 0. Xác định task — theo lời chủ dự án

- Mỗi app một thư mục plan: `<repo>/plan/` (fastcast, materiant, groove). Chủ dự án đưa **tệp** · **mã** (`gd1_03`, `materiant-gd1_02`) ·
  **"làm tiếp <repo>"** ⇒ task 🔄 của repo đó nếu có, không thì ☐ có số nhỏ nhất (gd thấp trước) mà mọi "Phụ thuộc"
  đã ✅ — nêu tên task ở câu trả lời đầu tiên.
- "làm tiếp" không nói repo, hoặc khớp nhiều tệp ⇒ chọn task ☐ sẵn sàng có số nhỏ nhất, nêu tên. Task 🔄 có worktree
  `claude/<task>` đang mở có thể là của session khác (làn song song) ⇒ không nhận, chọn task sẵn sàng khác. Bắt đầu
  task ⇒ đổi `Trạng thái` sang 🔄 ngay.
- Phụ thuộc vào task của repo khác ghi dạng `materiant-gd1_03` ⇒ soát dòng `Trạng thái` của
  `materiant/plan/materiant-gd1_03_*.md` + `git -C materiant log`; chưa xong ⇒ chọn task khác đã sẵn sàng, không có thì làm phần
  không cần nó và ghi phần chờ vào mục 9.

## 1. Nạp ngữ cảnh (không hỏi)

1. `CLAUDE.md` gốc (luật chung, bảng định tuyến) + `docs/decisions.md` (D-*, F-*, Q-*).
2. Dòng `Repo` của task ⇒ `<repo>/CLAUDE.md` TRƯỚC khi đọc code; lộ trình của repo (`fastcast/ROADMAP.md`) — chỉ phần
   task trỏ tới. Task chạm repo khác ⇒ nạp cả `CLAUDE.md` của repo đó.
3. `docs/tasking-convention.md`; mở tệp task: bảng thuộc tính, khối `## 0. Bàn giao từ …`, mục 1–8.
4. Hồ sơ repo cho các bước sau: lệnh soát xanh (mặc định `cargo build`, `cargo clippy --all-targets -- -D warnings`,
   `cargo test`, `cargo deny check licenses`), cách đo (RAM: `tools/measure-ram.ps1`), bẫy môi trường ghi trong
   `CLAUDE.md` của repo (vd AppData ảo hoá khi chạy exe từ app Claude, PowerShell không chờ exe GUI).
5. Soát nền: phụ thuộc ✅ và có commit trên `master`; checkout chính của repo bị chạm đang bẩn, hay đã có worktree /
   nhánh `claude/<task>` ⇒ nói ra trước khi tạo nhánh.

## 2. Chốt câu hỏi mở — TRƯỚC khi code

Task ghi "Quyết định trong task", "xác nhận với chủ dự án", Q-… chưa chốt, hoặc mâu thuẫn với code thật ⇒ gom lại, tự
chọn phương án khuyên dùng cho từng câu (dựa D-* / F-*, code thật, bản web), ghi mục 9 ("Opus chọn <ngày>: … — vì …")
+ `<repo>/plan/confirm.md`. Không ghi `docs/decisions.md` — chỉ chủ dự án chốt mới vào đó.

## 3. Phân vai + Case test (thiếu thì Opus viết, không chờ duyệt)

Dòng `Model` của task (D-14, `docs/tasking-convention.md` mục 8): task `sonnet` chạy trọn bằng Sonnet, không giao tiếp subagent; gặp chỗ phải quyết định nghiệp vụ thì ghi lại cho Opus, không đoán.

- `## 2b. Phân vai`: bảng phần việc → `[opus]` / `[sonnet]` / `[owner-qa]` theo `docs/tasking-convention.md` mục 8.
  Mặc định `[opus]`: toạ độ / hình học đa màn, đa luồng + vòng sự kiện, IPC + giao thức, `unsafe` / FFI theo OS, interface
  giữa crate. `[sonnet]`: ghép UI từ component `materiant`, catalog i18n, đọc / ghi cấu hình đơn giản, test theo case.
- `## 6.` đổi gạch nghiệm thu thành case `C1…Cn` (Cho / Khi / Thì, giữ đúng con số của task) + ai phủ: `[opus-unit]`,
  `[sonnet-test]`, `[opus-run]`, `[owner-qa]`.
- File của `[opus]` và `[sonnet]` KHÔNG chồng nhau; chồng thì `[opus]` làm xong + commit trước.
- Vượt trần mục 2 của khung ⇒ tách tệp task (đổi tên các tệp sau, sửa bảng trong lộ trình) rồi mới code.

## 4. Thực thi

1. Nhánh: mỗi repo bị sửa một worktree đặt ở `.claude/worktrees/` của **repo gốc** (`.claude` chỉ ở gốc, đã gitignore):
   ```bash
   git -C <repo> worktree add ../.claude/worktrees/<repo>-<task> -b claude/<task> master
   export CARGO_TARGET_DIR="$PWD/<repo>/target/<task>"   # RIÊNG từng worktree (nằm trong target/ ⇒ đã gitignore)
   ```
   **Không** dùng chung `<repo>/target` giữa các worktree: fingerprint của package path theo đường dẫn tương đối +
   mtime ⇒ build ở worktree này sau worktree khác có thể báo `Fresh` mà exe / test là code của worktree kia (đã dính
   30/10/2026: gallery của gd1_03 ra trang stub của master). Lần đầu build nguội vài phút — chấp nhận. Gỡ worktree thì
   xoá luôn `<repo>/target/<task>`.
   Task chỉ sửa plan / tài liệu ⇒ không worktree, làm thẳng `master` của repo chứa tệp đó.
2. Opus code `[opus]` + test `[opus-unit]`, chốt interface, commit trên nhánh.
3. Giao Sonnet: `Agent` với `subagent_type: "general-purpose"`, `model: "sonnet"`. Lời giao gồm: đường dẫn tệp task +
   mục, `CLAUDE.md` phải đọc trước (`<repo>/CLAUDE.md`, khung task), đường dẫn worktree, danh sách file được sửa (và
   file KHÔNG được chạm), interface đã chốt, case phải phủ, lệnh soát chạy với cwd = worktree, commit bằng
   `git commit -- <paths>`. **Việc không phụ thuộc nhau ⇒ bật agent song song** (mỗi agent một bộ file); tuần tự khi
   cùng file / cần kết quả của nhau.
4. Verify bằng log: `git diff` phần Sonnet viết; lệnh soát xanh với **cwd = worktree** (chạy ở checkout chính là soát
   `master`, xanh giả); `[opus-run]`: build release, chạy exe, giả lập phím (`keybd_event`), đọc log, đo RAM / độ trễ
   theo mục 5 của task. Ảnh chụp màn hình thật sinh ra khi thử ⇒ xoá sau khi xem (dữ liệu riêng của chủ dự án).
5. Lỗi ⇒ `SendMessage` về đúng agent đã viết; lỗi trong `[opus]` ⇒ Opus tự sửa. Chạy lại chỉ case đỏ.
6. `[owner-qa]`: không tự đánh dấu qua — ghi bước kiểm vào báo cáo cuối cho chủ dự án, task vẫn ✅ nếu mọi case khác
   xanh và case tay không chặn (ghi rõ "chờ kiểm tay" ở mục 9 + `<repo>/plan/_backlog.md`).

## 5. Soi cải tiến — Opus, sau khi xanh, TRƯỚC khi gộp

Đọc lại diff + luồng người dùng bằng bốn lăng kính. Mỗi phát hiện phải có **bằng chứng** (`file:dòng`, số đo, ca tái
hiện). Lăng kính không hợp task ⇒ ghi "không áp".

| Lăng kính | Hỏi |
| --- | --- |
| **Bảo mật / riêng tư** | Ảnh chụp màn hình là dữ liệu nhạy cảm: tệp tạm có bị sót, nằm ngoài thư mục của người dùng, lọt vào log? Tiến trình khác (cùng / khác người dùng) gọi được IPC để đọc tệp tuỳ ý, đặt clipboard, chạy lệnh? Đường dẫn từ IPC có kiểm trong thư mục cho phép, có trần cỡ? Lỗi có fail-closed? |
| **UI/UX** | Dùng hết bằng bàn phím? Đúng trên nhiều màn khác DPI / Hz, sáng / tối, vi / en, cỡ chữ lớn? Người dùng biết vì sao không làm được (phím trùng, thư mục không ghi được) và cách gỡ? Độ trễ cảm nhận (phím tắt → khung đầu)? |
| **RAM / hiệu năng** | RAM lúc nghỉ của daemon / UI giữ ấm có tăng? Bộ nhớ có nhả sau khi đóng overlay? CPU khi kéo, trên WARP / RDP? Phụ thuộc mới kéo gì vào tiến trình nền? |
| **Pro (D-4)** | Chỗ người dùng sẵn lòng trả về sau (chỉ ghi — chưa làm thanh toán): tính năng nâng cao nào hợp đặt huy hiệu "Pro"? |

Giới hạn — đề xuất trái các luật này thì bỏ: luật chung của `CLAUDE.md` gốc (không tự bật dịch vụ trả phí, cấm GPL…),
quyết định D-* / F-* đã chốt.

- **Lỗi thật trong phạm vi task** ⇒ sửa luôn, ghi mục 9.
- **Ngoài phạm vi** ⇒ `## 10. Đề xuất cải tiến`, mỗi dòng: `[bảo mật|ux|ram|pro]` vấn đề — bằng chứng — đề xuất — giá
  trị — cỡ (S/M) — ưu tiên (P1/P2/P3). Tối đa 7 dòng, xếp theo giá trị.
- Viết xong mục 10 ⇒ tự chọn đề xuất đáng làm (P1 / P2, cỡ S / M, không trái D-* / F-*) và **làm ngay trong lượt**
  (D-8, D-9): trên chính nhánh `claude/<task>` (chưa gộp) — code, test, soát xanh lại, ghi
  mục 9 "Đề xuất đã làm"; đề xuất thuộc tệp của task khác chưa tới thì vẫn làm ngay nếu không đụng làn song song đang
  mở, không thì ghi thẳng vào mục 0 / mục 1 của task đó. Chỉ vào `<repo>/plan/_backlog.md` khi KHÔNG làm được trong lượt
  (cần máy / thiết bị không có, dịch vụ trả phí, chờ quyết định khác) — ghi rõ lý do. Đề xuất `[pro]` (D-4 chỉ đặt
  chỗ) ⇒ ghi vào lộ trình / task của tính năng đó ngay. Vượt trần mục 2 của khung ⇒ tách task mới rồi làm luôn.

## 6. Đóng task

1. Điền mục 9 (bàn giao thực tế: số đo, lệnh soát, quyết định đã chốt, việc chờ kiểm tay) → `Trạng thái` ✅ (ngày).
2. Bàn giao: gọi skill **`handoff`** (chế độ A, tham số = mã task) — nó tìm task nhận (số kế tiếp, hoặc các task ghi
   task này ở dòng "Phụ thuộc" khi lộ trình có làn song song), chèn khối `## 0. Bàn giao từ <task>` + dấu
   `<!-- handoff: <task> -->`, task cuối giai đoạn thì ghi vào lộ trình repo. Khuôn ở `docs/tasking-convention.md` mục 6.
3. Gộp từng repo: soát xanh lần cuối trên nhánh → `git -C <repo> merge --no-ff claude/<task>` vào `master` →
   `git -C <repo> worktree remove ../.claude/worktrees/<repo>-<task>` → `git -C <repo> branch -d claude/<task>`. Gộp
   `master` vào nhánh trước khi merge; xung đột ⇒ tự giải (giữ cả hai phía khi là hai mục cạnh nhau), soát xanh lại,
   ghi mục 9. Gỡ worktree từ shell đang đứng TRONG nó (Windows) ⇒ "Permission denied", git vẫn gỡ đăng ký nhưng
   để lại thư mục rỗng: `cd` ra gốc trước, sót thì `git worktree prune` + xoá thư mục. Gỡ worktree xong xoá luôn `CARGO_TARGET_DIR` của task: mỗi thư mục build 8–20 GB, không ai dùng lại. Không push (chưa có remote — Q-2; có rồi cũng hỏi trước).
4. Commit plan ở repo chứa nó, theo đường dẫn: `git -C <repo> commit -m "plan: <task> ✅" -- plan/<tệp task> plan/<các task nhận>
   plan/_backlog.md ROADMAP.md`; `docs/decisions.md` nếu có quyết định mới thì commit ở repo gốc.

Báo chủ dự án ≤ 10 dòng: kết quả + commit từng repo, case xanh / đỏ, số đo chính, việc chủ dự án phải làm (lệnh chạy
được, bước kiểm tay), đề xuất mục 10 đã làm / lý do còn treo.
