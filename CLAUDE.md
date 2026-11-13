# Workspace xdesktop — app desktop Rust, nhiều repo

Repo gốc chỉ giữ cấu hình workspace và tài liệu chỉ đạo; plan nằm trong repo từng app. Mỗi app / thư viện là **repo git riêng** clone vào thư
mục con (không submodule). File này chỉ giữ định tuyến + luật chung mọi dự án; **luôn đọc `CLAUDE.md` của repo mình
đang chạm trước khi sửa code**.

| Dự án | Thư mục | Nạp ngữ cảnh |
| --- | --- | --- |
| **fastcast** (chụp vùng / thước / lấy màu / OCR / quay vùng) | `fastcast/` — lộ trình `fastcast/ROADMAP.md`, task `fastcast/plan/gd<N>_*.md` | `fastcast/CLAUDE.md` |
| **materiant** (bộ component UI dùng chung mọi app) | `materiant/` — nền GPUI (D-6); dùng component: `materiant/API.md` → `materiant/api/<module>.md`; inspector kiểu DevTools là crate `materiant/devtool` (D-25, app gọi `devtool::init`); lộ trình `materiant/ROADMAP.md`, task `materiant/plan/materiant-gd<N>_*` | `materiant/CLAUDE.md` (sửa materiant) |
| **cloud** (server chung mọi app: tài khoản, license, đồng bộ, lưu tệp — D-24) | `cloud/` — Rust axum + Postgres (sqlx); staging trên `ssh xbds-staging` (dùng chung với xbds, luật ở `cloud/CLAUDE.md`); task nằm ở `fastcast/plan/gd5_*`; remote `desktop-server` | `cloud/CLAUDE.md` |
| **groove** (trình phát nhạc **Groovex** — G-9, viết lại từ Tauri + Vue sang Rust + GPUI, G-1) | `groove/` — lộ trình `groove/ROADMAP.md`, task `groove/plan/groove-gd1_*.md`; bản Tauri đã gỡ 09/11/2026, mã cũ ở tag `tauri-final` | `groove/CLAUDE.md`, skill `/groove` |
| **ferry** (app khay gửi tệp / thư mục sang app điện thoại `video-player` qua WiFi — W-1, W-5) | `ferry/` — hợp đồng `ferry/PROTOCOL.md`, lộ trình `ferry/ROADMAP.md`, task `ferry/plan/ferry-gd1_*.md` | `ferry/CLAUDE.md`, skill `/ferry` |
| **trang giới thiệu từng app** (Astro tĩnh, `<app>.sandtechs.com`) | **workspace riêng, ngoài repo này**: `E:\codex\sandtechs/sites/<app>` (vd `sites/fastcast`, `sites/groovex`) — giao việc bằng session có cwd đó, không sửa từ session xdesktop | `E:\codex\sandtechs\CLAUDE.md` |

Mỗi session làm một app: `/fastcast`, `/groove`, `/ferry` nạp đúng ngữ cảnh của app đó và không quét app kia.

**Plan: mỗi app một thư mục `<repo>/plan/`** (D-7) — khung tệp task, đặt tên, trần ước lượng, phân vai, bàn giao:
`.claude/rules/tasking-convention.md`; việc treo: `<repo>/plan/_backlog.md`; giai đoạn đã đóng: `<repo>/plan/completed/gd<N>/`. Lộ trình
của app nằm ở repo app (`<repo>/ROADMAP.md`). Spike sống trong repo nó phục vụ: `<repo>/spikes/<tên>/`, báo cáo
ở `<repo>/spikes/<tên>/README.md` hoặc mục 9 của task spike. Không repo nào có `docs/`: luật, bẫy, lệnh vào `CLAUDE.md`,
quyết định vào `.claude/rules/decisions/`; báo cáo giai đoạn, đặc tả đã làm xong chỉ còn trong lịch sử git.

**Quyết định đã chốt: `.claude/rules/decisions/`** — `workspace.md` (D-*, nạp mọi session), `fastcast.md` (F-*, Q-*),
`groove.md` (G-*): tệp app có `paths:` nên chỉ nạp khi chạm repo / worktree của app đó. Không đề xuất thứ gì trái với nó.
Chủ dự án chốt thêm ⇒ ghi vào tệp đúng phạm vi kèm ngày (không chỉ ghi vào memory: memory nằm theo máy, rule đi theo git).
Khuôn release note: `.claude/rules/release-notes.md`; OCR trên máy mới: `.claude/rules/fastcast-ocr.md`.

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
đồng bộ qua git. Memory chỉ ghi điều không suy ra được từ repo; quyết định đã chốt vẫn vào `.claude/rules/decisions/`. Cách nối
dựa vào bố cục thư mục nội bộ của Claude Code — đổi bố cục thì sửa `init.*`.

## Máy mới

```bash
pwsh init.ps1      # Windows
bash init.sh       # macOS / Ubuntu (Git Bash trên Windows tự đá sang init.ps1)
```

Idempotent, chạy lại lúc nào cũng được: nối memory, hỏi init project nào (fastcast, materiant, groove, cloud — chọn được nhiều)
rồi clone repo còn thiếu (fastcast, groove kéo cả materiant; app dùng server chung — bảng `cloud_apps` / `$cloudApps` trong
`init.*`, hiện là fastcast, groove, ferry — kéo thêm `cloud` (remote `desktop-server`) và tạo khung `cloud/env/<app>-dev.env`, `<app>.env`
(biến trống, `node cloud/tools/new-app.mjs --env-only`); chọn `cloud` = server + khung env của mọi app dùng nó; repo có rồi
thì không đụng; remote của materiant tên `materiant-rust`; giá trị bí mật của cloud — `.env`, `env/`, `secrets/` — không theo
git, điền / chép tay), soát công cụ. Không hỏi: `-Project fastcast,cloud` / `bash init.sh fastcast,cloud`.

## Build bản release

```bash
pwsh ./build.ps1   # Windows
bash build.sh      # macOS / Ubuntu
```

Script gốc chỉ hỏi project (radio, chọn một): Fastcast, Groovex, Ferry, materiant (docs only) rồi gọi sang script build của repo đó (`fastcast/build.sh` / `build.ps1`, `groove/build.*`, `ferry/build.*`, `materiant/build.*` — chạy thẳng cũng được, mọi cờ trừ `--project` chuyển nguyên; helper chung ở `tools/script-lib.sh` / `.ps1`); không hỏi: `-Project <tên>` / `--project <tên>`, hoặc có cờ OS / kiến trúc / chip / plan thì là fastcast. `-f` / `--force` dùng cho mọi project: biên dịch lại mã của ta, giữ thư viện đã build. Fastcast hỏi tiếp OS → kiến trúc (chỉ macOS: ô tích Apple silicon / Intel, chọn nhiều thì build lần lượt; Windows / Linux chỉ x64 — bỏ ARM 10/11/2026) → chip (Enter = máy đang chạy) → plan (Free / Pro; có cờ OS / kiến trúc / chip thì không hỏi, mặc định Free), ra thẳng `release/fastcast/` (gitignore), tên `<app>_<version>_<os>_<arch>[_avx2][_draft].<đuôi>` — os `win` / `macos` / `linux`, arch `x64` / `arm64` (arm64 chỉ macOS; Linux theo Debian: `amd64`), vd. `fastcast_0.1.4_linux_amd64.deb`, `groovex_0.2.0_win_x64_setup.exe` (bản cài Windows có hậu tố `_setup`); macOS ra `Fastcast.app` + `.dmg` (thiếu model / `pwsh` thì bản `_draft`); Windows hỏi dạng đóng gói (ô tích, cả fastcast lẫn Groovex): bản cài NSIS `_setup.exe` (tích sẵn; fastcast chỉ x64 phổ thông) và / hoặc bản chạy thẳng `_portable.zip` (giải nén ra một thư mục, không để thư mục rời), mỗi tệp kèm `.sha256`; không hỏi: `-Package setup,portable` / `--package setup,portable` (có cờ OS / kiến trúc / chip mà không `-Package` ⇒ chỉ bản cài). `--pro` / `-Pro` (= `--plan=pro` / `-Plan pro`): fastcast mở sẵn Pro để nghiệm thu (D-23), tên có `_pro`, Windows mặc định chỉ `.zip` (`-Pro -Package setup` ra bản cài `_pro_setup.exe` để chủ dự án tự cài, không đưa lên trang tải).
Chỉ build được cho OS đang chạy. Không hỏi: `-Os windows -Arch x64 -Chip intel-amd` / `--os … --arch … --chip …`. Linux: tự soát gói dev (`libegl-dev`, `libgbm-dev`, `libpipewire-0.3-dev`, `clang`, `dpkg-dev`), thiếu thì `sudo apt-get install` ngay trong terminal, tự tải ONNX Runtime (sha ghim) khi `fastcast/target/release/models` có model mà thiếu `libonnxruntime.so`, tự `cargo install cargo-about` cho trang giấy phép (không cần `pwsh`), rồi ra `.deb`. Groovex: bản cài (Windows thêm tuỳ chọn `.zip` chạy thẳng) cho máy đang chạy ở `release/groove/`; riêng macOS hỏi kiến trúc (Enter = máy đang chạy) và cross-compile Apple Silicon ⇄ Intel: `--project groove --arch arm64|x64` (`--chip apple|intel`), ra `groovex_<version>_macos_<arm64|x64>.dmg` + `Groovex.app` (kiến trúc dựng sau). Ferry (`--project ferry`): bản cài máy đang chạy ở `release/ferry/` — Linux `ferry_<version>_linux_amd64.deb` (hai exe `ferry` + `ferry-ui`, mục menu `ferry.desktop`), macOS `Ferry.app` + `ferry_<version>_macos_<arm64|x64>.dmg` (`--arch` như Groovex, `Info.plist` khai Bonjour `_vpsync._tcp` + quyền mạng LAN), Windows `_setup.exe` (cần admin: luật tường lửa mDNS UDP 5353) / `_portable.zip` theo ô tích như trên; `--draft` khi thiếu `cargo-about`. materiant: chỉ gallery docs, ra `release/materiant/materiant-docs[.exe]`.

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

`bash tag.sh` / `pwsh ./tag.ps1`: hỏi project (fastcast, materiant, groove, ferry; space tích, enter xác nhận, chọn được nhiều; không hỏi: `--project a,b`, PowerShell `-Project a,b`), nâng version trong `Cargo.toml` + `Cargo.lock`, commit rồi tag `v<version>`. **Release note** (D-22, khuôn `.claude/rules/release-notes.md`): `<repo>/release-notes/v<version>.md` đi kèm commit và làm nội dung tag; viết sẵn thì dùng, thiếu thì script tự sinh từ tiêu đề commit kể từ tag trước rồi tag luôn (không dừng). Nâng materiant thì fastcast / groove / ferry có thêm commit cập nhật `Cargo.lock`. Không cờ = `-p` / `--patch`; `--minor`, `--major` nâng bậc tương ứng; `--current` tag version đang có, không nâng; `--push` đẩy lên origin; `-f` / `--force` tag đã có thì ghi đè (dời tag sang commit mới, `--push` đẩy `+v<version>`). Dừng nếu còn thay đổi chưa commit, không ở `master`, hoặc tag đã có mà không `-f`.

## Lệnh chung

- Rust stable (≥ 1.99; `init.sh` tự cài / nâng), MSVC Build Tools + Windows SDK trên Windows; Linux: `init.sh` tự cài mọi gói hệ thống (apt). Repo con: `git -C <repo> …`.
- Repo gốc commit theo đường dẫn: `git commit -- <paths>` (tránh kéo tệp người khác đã stage).
- Chủ dự án xem tay — **`start.sh`** (macOS / Linux / Git Bash); `pwsh start.ps1 …` chỉ là lớp bọc tìm Git Bash rồi
  chuyển nguyên đối số sang `start.sh` (không gọi `bash` trần: trên Windows là WSL). `start.sh` gốc chỉ hỏi / định tuyến, việc
  thật ở `<repo>/start.sh` của từng app (chạy thẳng được, cả từ worktree `.claude/worktrees/<repo>-w<N>` ⇒ code worktree, build
  `<repo>/target/w<N>`; `bash <repo>/start.sh help`). **Không đối số**: radio chọn app (fastcast / groove / ferry / materiant (CDK)) rồi
  radio plan của app đó (`<repo>/start.sh --plans` in `id|nhãn`, `*` = mặc định; rỗng ⇒ bỏ bước), materiant mở gallery; không tty thì
  in cách dùng. `pwsh start.ps1 docs [trang] [worktree]` — gallery materiant từ master hoặc
  từ worktree `.claude/worktrees/materiant-<worktree>`; `launcher [worktree]`; `start.ps1 list` liệt kê worktree (ba lệnh này = `materiant/start.sh`, `start.sh materiant …` cũng được); `start.ps1 groove` mở Groovex bản master (bản debug mã riêng `groove.dev`, MPRIS `groovex.dev`, Windows AUMID `GrooveX.Player.Dev`: chạy cạnh bản đã cài không đè nhau; Linux: `groove/start.sh` ghi `~/.local/share/applications/groove.dev.desktop` "Groovex (dev)" cho ô tìm + dock); `start.ps1 ferry` mở khay `ferry` bản debug (dữ liệu dev riêng ở `ferry/target/dev`, khay → Mở cửa sổ bật `ferry-ui`; = `ferry/start.sh`); `start.ps1 fastcast [màn] [--plan=free|pro|cloud]` (`--free` / `--pro` / `--cloud` viết tắt) mặc định màn `app`: `fst` thật bản debug (khay + phím tắt toàn cục, cấu hình dev riêng `fastcast/target/start/dev-config.json`; bản đã cài đang chạy thì script dừng, bảo `fst quit` trước; GNOME: phím trong dconf trỏ tới exe debug tới khi bản cài chạy lại; macOS: bản dev dùng quyền ghi màn hình của app terminal đang chạy lệnh, thiếu thì script nói tên app cần bật và mở trang cài đặt); màn `settings|launcher|overlay|ruler|picker` dùng daemon giả + cùng cấu hình dev, overlay trên màn giả (Linux: `fastcast/tools/fake-screens.sh`). Plan của fastcast: biến dev `FASTCAST_PLAN` cho mọi tiến trình (chỉ bản debug / `dev-env` đọc, chỉ hạ được về Free — D-23): `free` xem bản Free không build lại, `pro` (mặc định), `cloud` = Pro ở máy, quyền ghi đồng bộ do server quyết theo tài khoản. Groove, materiant chưa có plan. Bản debug (cả ba lệnh này) có inspector kiểu devtool: `Ctrl+Shift+I` mở, `Ctrl+Shift+C` chọn phần tử (D-19, D-25, `materiant/devtool/README.md`). App mới ⇒ `<repo>/start.sh`
  (+ `build.sh` / `build.ps1`, nhận `--plans`) rồi thêm tên vào radio và `case` của `start.sh` / `build.*` gốc (không sửa `start.ps1`).

## Xong task thì gộp về `master` và dọn nhánh

Làm trên nhánh `claude/<task>` trong một **worktree cố định** (D-18: `.claude/worktrees/<repo>-w<N>` của repo gốc, build ở
`<repo>/target/w<N>`, không xoá, task sau dùng lại cả mã lẫn cache build) là chuyện của Claude; chủ dự án chỉ nhìn `master`.
Hết task: kiểm xanh (`cargo build`, `cargo clippy --all-targets -- -D warnings`, `cargo test`,
`cargo deny check licenses`; fastcast thay `cargo test` bằng `node tools/test-affected.mjs` — chỉ test phần đổi + phần
phụ thuộc, cả bộ để lúc đóng giai đoạn / trước tag / build bản phát hành, D-26) → commit hết trên nhánh (mở đầu bằng mã
task) → **lịch sử thẳng (D-12)**: `git -C <worktree> rebase master` → kiểm xanh lại → `git -C <repo> merge --ff-only
claude/<task>` (từ chối thì rebase lại, không merge thường; không merge `master` vào nhánh) → trả worktree về rảnh
(`git -C <worktree> switch --detach master`), `branch -d`; giữ worktree và thư mục build. Pull: `git pull --rebase`. Xung
đột rebase không tự giải được ⇒ `rebase --abort`, dừng hỏi. Chi tiết: skill `run-task` mục 4, 6.
