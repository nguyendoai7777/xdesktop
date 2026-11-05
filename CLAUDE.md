# Workspace xdesktop — app desktop Rust, nhiều repo

Repo gốc chỉ giữ cấu hình workspace và tài liệu chỉ đạo; plan nằm trong repo từng app. Mỗi app / thư viện là **repo git riêng** clone vào thư
mục con (không submodule). File này chỉ giữ định tuyến + luật chung mọi dự án; **luôn đọc `CLAUDE.md` của repo mình
đang chạm trước khi sửa code**.

| Dự án | Thư mục | Nạp ngữ cảnh |
| --- | --- | --- |
| **fastcast** (chụp vùng / thước / lấy màu / OCR / quay vùng) | `fastcast/` — lộ trình `fastcast/ROADMAP.md`, task `fastcast/plan/gd<N>_*.md` | `fastcast/CLAUDE.md` |
| **materiant** (bộ component UI dùng chung mọi app) | `materiant/` — nền GPUI (D-6); dùng component: `materiant/API.md` → `materiant/api/<module>.md`; inspector kiểu DevTools là crate `materiant/devtool` (D-25, app gọi `devtool::init`); lộ trình `materiant/ROADMAP.md`, task `materiant/plan/materiant-gd<N>_*` | `materiant/CLAUDE.md` (sửa materiant) |
| **cloud** (server chung mọi app: tài khoản, license, đồng bộ, lưu tệp — D-24) | `cloud/` — Rust axum + Postgres (sqlx); staging trên `ssh xbds-staging` (dùng chung với xbds, luật ở `cloud/CLAUDE.md`); task nằm ở `fastcast/plan/gd5_*`; remote `desktop-server` | `cloud/CLAUDE.md` |
| **groove** (trình phát nhạc **Groovex** — G-9, viết lại từ Tauri + Vue sang Rust + GPUI, G-1) | `groove/` — lộ trình `groove/ROADMAP.md`, task `groove/plan/groove-gd1_*.md`; bản Tauri còn tới khi gộp nhánh `claude/remove-tauri` (tag `tauri-final`) | `groove/CLAUDE.md`, skill `/groove` |

Mỗi session làm một app: `/fastcast`, `/groove` nạp đúng ngữ cảnh của app đó và không quét app kia.

**Plan: mỗi app một thư mục `<repo>/plan/`** (D-7) — khung tệp task, đặt tên, trần ước lượng, phân vai, bàn giao:
`.claude/rules/tasking-convention.md`; việc treo: `<repo>/plan/_backlog.md`; giai đoạn đã đóng: `<repo>/plan/completed/gd<N>/`. Lộ trình
của app nằm ở repo app (`<repo>/ROADMAP.md`). Spike sống trong repo nó phục vụ: `<repo>/spikes/<tên>/`, báo cáo
ở `<repo>/spikes/<tên>/README.md` hoặc mục 9 của task spike. Repo con không có `docs/`: luật, bẫy, lệnh vào `CLAUDE.md`,
quyết định vào `docs/decisions.md`; báo cáo giai đoạn, đặc tả đã làm xong chỉ còn trong lịch sử git.

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
- **UI**: xong một component / màn thì soát theo `materiant/CLAUDE.md` mục "Soát trước khi xong một component / màn" (đệm,
  cuộn, bo góc + cắt, độ đậm, màu theme, vòng focus, hoạt ảnh, nút icon, hộp thoại, nút cửa sổ) — áp cho mọi app.
- **RAM là tính năng**: tiến trình nền không mang framework UI / GPU / model; thứ nặng chỉ nạp khi dùng và nhả khi xong.
  Thêm phụ thuộc lớn vào tiến trình nền ⇒ đo RAM trước / sau.
- **`.claude` chỉ ở repo gốc**: rule, skill, agent, memory của mọi repo con sống ở `<gốc>/.claude`. Không `.agents/`,
  `.codex/`, `AGENTS.md`.
- Quy trình Opus điều phối + subagent Sonnet (D-5, bê từ `xbds`): skill **`run-task`** (làm một task trong `<repo>/plan/`),
  **`handoff`** (bàn giao khi task ✅ — run-task gọi; hoặc tài liệu bàn giao cho session khác) và **`close-phase`** (đóng
  giai đoạn) ở `.claude/skills/`. Chưa chuyển: output style `terse`, agent riêng, hook nhắc bàn giao.

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

Idempotent, chạy lại lúc nào cũng được: nối memory, hỏi init project nào (fastcast, materiant, groove, cloud — chọn được nhiều)
rồi clone repo còn thiếu (fastcast, groove kéo cả materiant; app dùng server chung — bảng `cloud_apps` / `$cloudApps` trong
`init.*`, hiện là fastcast — kéo thêm `cloud` (remote `desktop-server`) và tạo khung `cloud/env/<app>-dev.env`, `<app>.env`
(biến trống, `node cloud/tools/new-app.mjs --env-only`); chọn `cloud` = server + khung env của mọi app dùng nó; repo có rồi
thì không đụng; remote của materiant tên `materiant-rust`; giá trị bí mật của cloud — `.env`, `env/`, `secrets/` — không theo
git, điền / chép tay), soát công cụ. Không hỏi: `-Project fastcast,cloud` / `bash init.sh fastcast,cloud`.

## Build bản release

```bash
pwsh ./build.ps1   # Windows
bash build.sh      # macOS / Ubuntu
```

Trước hết hỏi project (radio, chọn một): Fastcast, Groovex, materiant (docs only); không hỏi: `-Project <tên>` / `--project <tên>`, hoặc có cờ OS / kiến trúc / chip thì là fastcast. `-f` / `--force` dùng cho cả ba project: biên dịch lại mã của ta, giữ thư viện đã build. Fastcast hỏi tiếp OS → kiến trúc → chip (Enter = máy đang chạy), ra thẳng `release/fastcast/` (gitignore), tên `<app>_<version>_<os>_<arch>[_avx2][_draft].<đuôi>` — os `win` / `macos` / `linux`, arch `x64` / `arm64` (Linux theo Debian: `amd64` / `arm64`), vd. `fastcast_0.1.4_linux_amd64.deb`, `groovex_0.2.0_win_x64.exe`; macOS ra `Fastcast.app` + `.dmg` (thiếu model / `pwsh` thì bản `_draft`); Windows ra thư mục exe rời cùng tên + bản cài NSIS (x64 phổ thông). `--pro` / `-Pro`: fastcast mở sẵn Pro để nghiệm thu (D-23), tên có `_pro`, Windows không dựng bản cài.
Chỉ build được cho OS đang chạy. Không hỏi: `-Os windows -Arch x64 -Chip intel-amd` / `--os … --arch … --chip …`. Linux: tự soát gói dev (`libegl-dev`, `libgbm-dev`, `libpipewire-0.3-dev`, `clang`, `dpkg-dev`), thiếu thì `sudo apt-get install` ngay trong terminal, tự tải ONNX Runtime (sha ghim) khi `fastcast/target/release/models` có model mà thiếu `libonnxruntime.so`, tự `cargo install cargo-about` cho trang giấy phép (không cần `pwsh`), rồi ra `.deb`. Groovex: bản cài cho máy đang chạy ở `release/groove/`. materiant: chỉ gallery docs, ra `release/materiant/materiant-docs[.exe]`.

Model OCR không nằm trong git. Chép sang máy khác: `pwsh ./export-ocr.ps1` / `bash export-ocr.sh` soát sha256 theo sổ rồi nén `fastcast/target/release/models` (bỏ thư viện ONNX Runtime vì theo OS) ra `release/fastcast/fastcast-ocr-models.tar.gz` + `.sha256`; đổi nguồn: `-Models <thư mục>` / đối số đầu. Máy nhận giải nén vào `fastcast/target/release/models`.

## Dọn dung lượng

`pwsh ./clean.ps1` / `bash clean.sh`: xoá phần build sinh ra, giữ model OCR ở `fastcast/target/release/models` và cache build release (`-All` / `--all` xoá luôn). Không chạy lúc có session đang build.

`start.*` / `build.*` build qua `tools/cargo-prune.mjs` (Node): build xong, bản build cũ (cùng crate cùng loại, hash không còn
dùng trong 7 ngày, sổ ở `<profile>/.prune-ledger.json`) và `incremental/` quá 7 ngày bị xoá; build lỗi thì không dọn. Không dọn
`target/w<N>` (cache clippy / test của session) và build của Groovex (script trong repo groove). `XDESKTOP_NO_PRUNE=1` tắt,
`XDESKTOP_PRUNE_DAYS` đổi số ngày.

`start.sh docs | launcher | groove` mặc định theo dõi mã (`tools/watch-run.mjs`, Node): lưu tệp hay gộp vào master ⇒ build lại
(~2 s khi sửa một tệp view) ⇒ đóng app cũ, mở bản mới; build lỗi thì giữ app cũ; đóng cửa sổ app là lệnh thoát theo. Không phải
hot reload: mất trạng thái đang mở (trang, hộp thoại). `--no-watch` / `XDESKTOP_NO_WATCH=1` chỉ chạy một lần. Linux: groove chạy trong scope systemd riêng `app-xdesktop-groove.dev-*.scope` để Mission Center hiện thành dòng riêng, không gộp vào terminal. Chưa áp cho
`start.sh fastcast`.

## Đánh tag

`bash tag.sh` / `pwsh ./tag.ps1`: hỏi project (fastcast, materiant, groove; space tích, enter xác nhận, chọn được nhiều; không hỏi: `--project a,b`, PowerShell `-Project a,b`), nâng version trong `Cargo.toml` + `Cargo.lock`, commit rồi tag `v<version>`. **Release note bắt buộc** (D-22, khuôn `docs/release-notes.md`): `<repo>/release-notes/v<version>.md` đi kèm commit và làm nội dung tag; thiếu thì script tạo khung rồi dừng. Nâng materiant thì fastcast / groove có thêm commit cập nhật `Cargo.lock`. Không cờ = `-p` / `--patch`; `--minor`, `--major` nâng bậc tương ứng; `--current` tag version đang có, không nâng; `--push` đẩy lên origin. Dừng nếu còn thay đổi chưa commit, không ở `master`, hoặc tag đã có.

## Lệnh chung

- Rust stable (≥ 1.99; `init.sh` tự cài / nâng), MSVC Build Tools + Windows SDK trên Windows; Linux: `init.sh` tự cài mọi gói hệ thống (apt). Repo con: `git -C <repo> …`.
- Repo gốc commit theo đường dẫn: `git commit -- <paths>` (tránh kéo tệp người khác đã stage).
- Chủ dự án xem tay — **một mã: `start.sh`** (macOS / Linux / Git Bash); `pwsh start.ps1 …` chỉ là lớp bọc tìm Git Bash rồi
  chuyển nguyên đối số sang `start.sh` (không gọi `bash` trần: trên Windows là WSL). `pwsh start.ps1 docs [trang] [worktree]` — gallery materiant từ master hoặc
  từ worktree `.claude/worktrees/materiant-<worktree>`; `start.ps1 list` liệt kê worktree; `start.ps1 groove` mở Groovex bản master (bản debug mã riêng `groove.dev`, MPRIS `groovex.dev`, Windows AUMID `GrooveX.Player.Dev`: chạy cạnh bản đã cài không đè nhau; Linux: `start.sh` ghi `~/.local/share/applications/groove.dev.desktop` "Groovex (dev)" cho ô tìm + dock); `start.ps1 fastcast [màn]` mặc định màn `app`: `fst` thật bản debug (khay + phím tắt toàn cục, cấu hình dev riêng `fastcast/target/start/dev-config.json`; bản đã cài đang chạy thì script dừng, bảo `fst quit` trước; GNOME: phím trong dconf trỏ tới exe debug tới khi bản cài chạy lại); màn `settings|launcher|overlay|ruler|picker` dùng daemon giả + cùng cấu hình dev, overlay trên màn giả (Linux: `fastcast/tools/fake-screens.sh`). Bản debug (cả ba lệnh này) có inspector kiểu devtool: `Ctrl+Shift+I` mở, `Ctrl+Shift+C` chọn phần tử (D-19, D-25, `materiant/devtool/README.md`). App mới ⇒ thêm nhánh vào
  `start.sh` (không sửa `start.ps1`).

## Xong task thì gộp về `master` và dọn nhánh

Làm trên nhánh `claude/<task>` trong một **worktree cố định** (D-18: `.claude/worktrees/<repo>-w<N>` của repo gốc, build ở
`<repo>/target/w<N>`, không xoá, task sau dùng lại cả mã lẫn cache build) là chuyện của Claude; chủ dự án chỉ nhìn `master`.
Hết task: kiểm xanh (`cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test`,
`cargo deny check licenses`; fastcast thay `cargo test` bằng `node tools/test-affected.mjs` — chỉ test phần đổi + phần
phụ thuộc, cả bộ để lúc đóng giai đoạn / trước tag / build bản phát hành, D-26) → commit hết trên nhánh → `git -C <repo> merge --no-ff claude/<task>` vào `master` → trả
worktree về rảnh (`git -C <worktree> switch --detach master`), `branch -d`; giữ worktree và thư mục build. Có xung đột thì
dừng lại hỏi. Chi tiết: skill `run-task` mục 4, 6.
