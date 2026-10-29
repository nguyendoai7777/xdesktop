# Workspace xdesktop — app desktop Rust, nhiều repo

Repo gốc chỉ giữ cấu hình workspace, tài liệu chỉ đạo và spike. Mỗi app / thư viện là **repo git riêng** clone vào thư
mục con (không submodule). File này chỉ giữ định tuyến + luật chung mọi dự án; **luôn đọc `CLAUDE.md` của repo mình
đang chạm trước khi sửa code**.

| Dự án | Thư mục | Nạp ngữ cảnh |
| --- | --- | --- |
| **fastcast** (chụp vùng / thước / lấy màu / OCR / quay vùng) | `fastcast/` — spec `fastcast/docs/MVP.md`, lộ trình `fastcast/docs/plans/roadmap.md` | `fastcast/CLAUDE.md` |
| **rs-materiant** (bộ component UI dùng chung mọi app) | `rs-materiant/` — chưa tạo; nền GPUI (D-6), plan `docs/plans/rs-materiant-gd1.md` | `rs-materiant/CLAUDE.md` |
| Spike | `spikes/<tên>/` (trong repo gốc, mã vứt đi được) | báo cáo ở `docs/spikes/<tên>.md` |

**Quyết định đã chốt: `docs/decisions.md`** — đọc trước khi đề xuất thứ gì trái với nó. Chủ dự án chốt thêm ⇒ ghi
vào đó kèm ngày (không chỉ ghi vào memory: memory nằm theo máy, `docs/decisions.md` đi theo git).

## Luật chung mọi dự án

- **Mọi định danh là tiếng Anh** — biến / hàm / kiểu / crate / module, khoá cấu hình, giá trị enum (`capture_region`,
  không `chup_vung`). Tiếng Việt chỉ ở comment, tài liệu và **lớp hiển thị**: chữ cho người dùng đi qua catalog i18n
  (`vi`, `en`), không hardcode trong mã UI.
- File cấu hình / IPC dạng JSON: khoá **camelCase** (`#[serde(rename_all = "camelCase")]`), giá trị enum snake_case.
- **Mã đóng, chỉ phát hành bản cài** (D-2): thêm thư viện ⇒ soát giấy phép cả cây phụ thuộc. Cho phép MIT, Apache-2.0,
  BSD, ISC, Zlib, BSL-1.0, Unicode, MPL-2.0 (dùng nguyên bản), OFL (font). Cấm GPL / AGPL; LGPL chỉ khi link động và phải
  hỏi chủ dự án. Repo app soát bằng `cargo deny check licenses`.
- **Dịch vụ trả phí — chủ dự án tự trả**: không tự bật dịch vụ tính tiền (runner CI macOS, chứng chỉ ký code, Apple
  Developer, máy chủ tải model…), không gọi API trả phí khi chưa hỏi.
- **RAM là tính năng**: tiến trình nền không mang framework UI / GPU / model; thứ nặng chỉ nạp khi dùng và nhả khi xong.
  Thêm phụ thuộc lớn vào tiến trình nền ⇒ đo RAM trước / sau.
- **`.claude` chỉ ở repo gốc**: rule, skill, agent, memory của mọi repo con sống ở `<gốc>/.claude`. Không `.agents/`,
  `.codex/`, `AGENTS.md`.
- Quy trình Opus điều phối + subagent Sonnet, `run-task`, `handoff`, `close-phase`, output style `terse` (D-5): **chưa
  chuyển từ `xbds`** — làm khi tạo repo app đầu tiên.

## Memory của Claude dùng chung giữa các máy

Memory tự động của Claude nằm theo máy (`~/.claude/projects/<đường dẫn>/memory`). `init.ps1` / `init.sh` nối thư mục đó
vào `.claude/memory/` của repo này (junction trên Windows, symlink trên macOS / Linux) nên mọi máy đọc ghi cùng một bộ,
đồng bộ qua git. Memory chỉ ghi điều không suy ra được từ repo; quyết định đã chốt vẫn vào `docs/decisions.md`. Cách nối
dựa vào bố cục thư mục nội bộ của Claude Code — đổi bố cục thì sửa `init.*`.

## Máy mới

```bash
pwsh init.ps1      # Windows
bash init.sh       # macOS / Ubuntu (Git Bash trên Windows tự đá sang init.ps1)
```

Idempotent, chạy lại lúc nào cũng được: nối memory, clone repo app còn thiếu (khi đã có remote), soát công cụ.

## Lệnh chung

- Rust stable (≥ 1.96), MSVC Build Tools + Windows SDK trên Windows. Repo con: `git -C <repo> …`.
- Repo gốc commit theo đường dẫn: `git commit -- <paths>` (tránh kéo tệp người khác đã stage).

## Xong task thì gộp về `master` và dọn nhánh

Làm trong worktree `claude/<task>` là chuyện của Claude; chủ dự án chỉ nhìn `master`. Hết task: kiểm xanh
(`cargo build`, `cargo clippy -- -D warnings`, `cargo test`) → commit hết trên nhánh → `git -C <repo> merge --no-ff
claude/<task>` vào `master` → gỡ worktree rồi `branch -d`. Có xung đột thì dừng lại hỏi.
