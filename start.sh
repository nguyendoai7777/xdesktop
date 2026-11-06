#!/usr/bin/env bash
# Mở nhanh app của workspace để xem tay — chỉ hỏi / định tuyến; việc thật nằm ở `<repo>/start.sh` của từng app. Một mã cho mọi
# OS (macOS / Linux; Windows chạy qua Git Bash, `pwsh start.ps1 …` chỉ là lớp bọc gọi sang đây). Đứng ở gốc workspace:
#   bash start.sh                       hỏi app (radio: fastcast / groove / materiant (CDK)) rồi hỏi plan của app đó (app không
#                                       có plan thì bỏ bước này); materiant mở gallery docs
#   bash start.sh fastcast [màn] [--plan=<plan> | --free | --pro | --cloud]
#                                       ⇒ fastcast/start.sh: bản debug (inspector: Ctrl+Shift+I, Ctrl+Shift+C) + cấu hình dev
#                                       riêng; màn = app (mặc định: `fst` thật — khay + phím tắt toàn cục; phải thoát bản đã cài
#                                       trước) | settings | launcher | overlay | ruler | picker (daemon giả); plan = free | pro
#                                       (mặc định) | cloud — đổi plan khi test dev, không build lại
#   bash start.sh groove                ⇒ groove/start.sh: Groovex (bản master)
#   bash start.sh docs [trang] [worktree]
#                                       ⇒ materiant/start.sh: gallery materiant; worktree = .claude/worktrees/materiant-<tên>
#   bash start.sh launcher [worktree]   ⇒ materiant/start.sh: launcher example của materiant
#   bash start.sh list                  ⇒ materiant/start.sh: liệt kê worktree materiant đang mở
#   bash start.sh materiant [docs … | launcher … | list]
# docs / launcher / groove mặc định theo dõi mã (tools/watch-run.mjs): lưu tệp ⇒ build lại, mở lại app (mất trạng thái đang mở).
# Thêm --no-watch (ở vị trí bất kỳ) hoặc XDESKTOP_NO_WATCH=1 để chỉ build rồi chạy một lần. Chi tiết từng app: đầu `<repo>/start.sh`
# hoặc `bash <repo>/start.sh help`.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$root/tools/script-lib.sh"

usage() { sed -n '2,/^set -euo/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//'; }

# Tách --no-watch để tìm app ở đối số đầu, rồi trả lại cho script của app (nó tự hiểu cờ này).
xd_parse_watch "$@"
forward=()
[ "$watch" = 1 ] || forward=(--no-watch)
set -- "${xd_args[@]+"${xd_args[@]}"}"

# start <repo> <đối số…>: chạy <gốc>/<repo>/start.sh.
start() {
  local script="$root/$1/start.sh"
  [ -f "$script" ] || { echo "Thiếu $1 (hoặc $1/start.sh): chạy bash init.sh rồi chọn $1." >&2; exit 1; }
  shift
  exec bash "$script" "$@" ${forward[@]+"${forward[@]}"}
}

if [ $# -eq 0 ]; then
  # Không tty (pipe, script) ⇒ in cách dùng thay vì lặng lẽ mở app mặc định.
  [ -t 0 ] || { usage; exit 0; }
  xd_select 'Mở app nào:' 1 'fastcast|fastcast' 'groove|groove' 'materiant|materiant (CDK)'
  repo="$picked"
  [ -f "$root/$repo/start.sh" ] || { echo "Thiếu $repo (hoặc $repo/start.sh): chạy bash init.sh rồi chọn $repo." >&2; exit 1; }
  xd_pick_plan "$root/$repo/start.sh"
  if [ -n "$plan" ]; then start "$repo" "--plan=$plan"; else start "$repo"; fi
fi

case "$1" in
  fastcast|groove|materiant) repo="$1"; shift; start "$repo" "$@" ;;
  docs|launcher|list) start materiant "$@" ;;
  -h|--help|help) usage ;;
  *) echo "Không hiểu '$1'." >&2; usage; exit 1 ;;
esac
