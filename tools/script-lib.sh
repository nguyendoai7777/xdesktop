# Hàm dùng chung cho start.sh / build.sh của gốc workspace và của từng repo (fastcast, groove, materiant). Nạp sau khi đã
# tìm ra gốc (thư mục có tools/script-lib.sh — repo con nằm ở <gốc>/<repo> hoặc worktree <gốc>/.claude/worktrees/<repo>-w<N>):
#   root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   until [ -f "$root/tools/script-lib.sh" ]; do [ "$root" != / ] || { echo "…" >&2; exit 1; }; root="$(dirname "$root")"; done
#   . "$root/tools/script-lib.sh"
# Đặt: win (1 = Git Bash trên Windows), ext (".exe" | ""), root (Windows: dạng `E:/codex/…` — bash, cargo lẫn Node đều hiểu),
# prune (tools/cargo-prune.mjs). Không `set -e` ở đây: script gọi tự đặt.

win=0 ext=""
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) win=1 ext=".exe" ;; esac

# xd_path <thư mục> ⇒ đường dẫn tuyệt đối (Windows: `E:/…` qua `pwd -W`).
xd_path() {
  if [ "$win" = 1 ]; then (cd "$1" && pwd -W); else (cd "$1" && pwd); fi
}
root="$(xd_path "$root")"
# Build qua tools/cargo-prune.mjs: build xong dọn bản build cũ (xem đầu tệp đó).
prune="$root/tools/cargo-prune.mjs"

# xd_target_name <thư mục repo> <tên repo> ⇒ tên thư mục build trong <gốc>/<repo>/target: bản ở <gốc>/<repo> ⇒ `start`;
# worktree `.claude/worktrees/<repo>-w<N>` ⇒ `w<N>` (đúng thư mục build của session đó, D-18 — không build nguội lại).
xd_target_name() {
  if [ "$1" = "$root/$2" ]; then echo start; else basename "$1" | sed "s/^$2-//"; fi
}

# xd_parse_watch <đối số…> ⇒ watch (0 | 1) + mảng xd_args (đối số còn lại, bỏ --no-watch ở vị trí bất kỳ).
# XDESKTOP_NO_WATCH=1 cũng tắt.
xd_parse_watch() {
  watch=1
  xd_args=()
  local a
  for a in "$@"; do
    if [ "$a" = --no-watch ]; then watch=0; else xd_args+=("$a"); fi
  done
  [ "${XDESKTOP_NO_WATCH:-}" != 1 ] || watch=0
}

# Build rồi chạy: watch ⇒ tools/watch-run.mjs (build qua cargo-prune, theo dõi các thư mục --watch); không ⇒ build một lần rồi exec.
#   xd_run_app [--scope <desktop id>] <exe không đuôi> <thư mục theo dõi, cách nhau "|"> <đối số app…> -- <đối số cargo build…>
# Ngăn bằng "|" chứ không ":" vì đường dẫn Windows có ổ đĩa (`E:/…`).
# --scope: Linux chạy app trong scope systemd riêng (xem tools/watch-run.mjs) ⇒ Mission Center hiện app thành dòng riêng.
xd_run_app() {
  local scope=""
  if [ "$1" = --scope ]; then scope="$2"; shift 2; fi
  local exe="$1$ext" dirs="$2"; shift 2
  local app_args=()
  while [ "$1" != -- ]; do app_args+=("$1"); shift; done
  shift
  if [ "${watch:-1}" = 1 ]; then
    local opts=(--exe "$exe") d a ds
    [ -n "$scope" ] && opts+=(--scope "$scope")
    IFS='|' read -ra ds <<< "$dirs"
    for d in "${ds[@]}"; do opts+=(--watch "$d"); done
    for a in "${app_args[@]+"${app_args[@]}"}"; do opts+=(--arg "$a"); done
    exec node "$root/tools/watch-run.mjs" "${opts[@]}" -- "$@"
  fi
  node "$prune" build "$@"
  if [ -n "$scope" ] && [ "$(uname -s)" = Linux ] && command -v systemd-run >/dev/null 2>&1; then
    exec systemd-run --user --scope --quiet "--unit=app-xdesktop-$scope-$$" -- "$exe" "${app_args[@]+"${app_args[@]}"}"
  fi
  exec "$exe" "${app_args[@]+"${app_args[@]}"}"
}

# xd_select <tiêu đề> <số thứ tự mặc định> <id|nhãn>… ⇒ gán $picked. Radio, chỉ chọn một: ↑ ↓ di chuyển, Enter chọn; vẽ lại tại
# chỗ bằng mã ANSI. `read -t` số nguyên: bash 3.2 của macOS không nhận số lẻ. Stdin là pipe ⇒ gõ số; hết stdin thì lấy mặc định.
xd_select() {
  local title="$1" default="$2" answer i=1 item
  shift 2
  if [ $# -eq 1 ]; then echo "$title ${1#*|}"; picked="${1%%|*}"; return; fi
  if [ -t 0 ]; then
    local items=("$@") count=$# cursor=$((default - 1)) key rest
    echo "$title"
    printf '\033[?25l'
    trap 'printf "\033[?25h"' EXIT
    while :; do
      for ((i = 0; i < count; i++)); do
        if [ "$i" = "$cursor" ]; then
          printf '\r\033[2K\033[36m(•) %s\033[0m\n' "${items[i]#*|}"
        else
          printf '\r\033[2K( ) %s\n' "${items[i]#*|}"
        fi
      done
      printf '\r\033[2K\033[2m%s\033[0m' '↑ ↓ di chuyển · enter chọn'
      IFS= read -rsn1 key || key=""
      if [ "$key" = $'\033' ]; then
        IFS= read -rsn2 -t 1 rest || rest=""
        key="$key$rest"
      fi
      printf '\r\033[%dA' "$count"
      case "$key" in
        $'\033[A'|$'\033OA') cursor=$(((cursor + count - 1) % count)) ;;
        $'\033[B'|$'\033OB') cursor=$(((cursor + 1) % count)) ;;
        '')
          # Xoá cả dòng tiêu đề rồi in lại kèm lựa chọn.
          printf '\033[1A\r\033[J\033[?25h'
          trap - EXIT
          echo "$title ${items[cursor]#*|}"
          picked="${items[cursor]%%|*}"
          return ;;
      esac
    done
  fi
  echo "$title"
  for item in "$@"; do
    if [ "$i" = "$default" ]; then echo "  [$i] ${item#*|}  (Enter)"; else echo "  [$i] ${item#*|}"; fi
    i=$((i + 1))
  done
  while :; do
    printf 'Chọn: '
    read -r answer || answer=""
    [ -n "$answer" ] || answer="$default"
    case "$answer" in
      *[!0-9]*) ;;
      *)
        if [ "$answer" -ge 1 ] && [ "$answer" -le $# ]; then
          eval "item=\${$answer}"
          picked="${item%%|*}"
          return
        fi ;;
    esac
    echo "Nhập số từ 1 đến $#."
  done
}

# xd_checklist <tiêu đề> <id tích sẵn, cách bằng dấu cách> <id|nhãn>… ⇒ gán $selected (id cách bằng dấu cách, theo thứ tự danh
# sách). Ô tích, chọn được nhiều: ↑ ↓ di chuyển, Space tích / bỏ, Enter xác nhận (phải tích ít nhất một mục). Stdin là pipe ⇒
# gõ số cách bằng dấu phẩy; Enter = các mục tích sẵn (không có thì mục đầu).
xd_checklist() {
  local title="$1" preset=" $2 " i key rest box answer pick ok labels defaults hint='↑ ↓ di chuyển · space tích / bỏ · enter xác nhận'
  shift 2
  local items=("$@") count=$# checked=() cursor=-1
  selected=""
  if [ "$count" -eq 1 ]; then echo "$title ${1#*|}"; selected="${1%%|*}"; return; fi
  for ((i = 0; i < count; i++)); do
    case "$preset" in
      *" ${items[i]%%|*} "*) checked[i]=1; [ "$cursor" -ge 0 ] || cursor=$i ;;
      *) checked[i]=0 ;;
    esac
  done
  [ "$cursor" -ge 0 ] || cursor=0
  if [ -t 0 ]; then
    echo "$title"
    printf '\033[?25l'
    trap 'printf "\033[?25h"' EXIT
    while :; do
      for ((i = 0; i < count; i++)); do
        if [ "${checked[i]}" = 1 ]; then box='[x]'; else box='[ ]'; fi
        if [ "$i" = "$cursor" ]; then
          printf '\r\033[2K\033[36m%s %s\033[0m\n' "$box" "${items[i]#*|}"
        else
          printf '\r\033[2K%s %s\n' "$box" "${items[i]#*|}"
        fi
      done
      printf '\r\033[2K\033[2m%s\033[0m' "$hint"
      IFS= read -rsn1 key || key=""
      if [ "$key" = $'\033' ]; then
        IFS= read -rsn2 -t 1 rest || rest=""
        key="$key$rest"
      fi
      printf '\r\033[%dA' "$count"
      case "$key" in
        $'\033[A'|$'\033OA') cursor=$(((cursor + count - 1) % count)) ;;
        $'\033[B'|$'\033OB') cursor=$(((cursor + 1) % count)) ;;
        ' ') if [ "${checked[cursor]}" = 1 ]; then checked[cursor]=0; else checked[cursor]=1; fi ;;
        '')
          labels=""
          for ((i = 0; i < count; i++)); do
            [ "${checked[i]}" = 1 ] || continue
            selected="${selected:+$selected }${items[i]%%|*}"
            labels="${labels:+$labels, }${items[i]#*|}"
          done
          if [ -n "$selected" ]; then
            # Xoá cả dòng tiêu đề rồi in lại kèm lựa chọn.
            printf '\033[1A\r\033[J\033[?25h'
            trap - EXIT
            echo "$title $labels"
            return
          fi
          hint='chưa tích mục nào, bấm space để tích' ;;
      esac
    done
  fi
  defaults=""
  for ((i = 0; i < count; i++)); do [ "${checked[i]}" = 1 ] && defaults="$defaults $((i + 1))"; done
  [ -n "$defaults" ] || defaults=" 1"
  echo "$title"
  for ((i = 0; i < count; i++)); do
    case "$defaults " in
      *" $((i + 1)) "*) echo "  [$((i + 1))] ${items[i]#*|}  (Enter)" ;;
      *) echo "  [$((i + 1))] ${items[i]#*|}" ;;
    esac
  done
  while :; do
    printf 'Chọn (nhiều mục thì cách bằng dấu phẩy): '
    read -r answer || answer=""
    [ -n "$answer" ] || answer="$defaults"
    answer=" $(printf '%s' "$answer" | tr ',' ' ') "
    ok=1
    for pick in $answer; do
      case "$pick" in
        *[!0-9]*) ok="" ;;
        *) { [ "$pick" -ge 1 ] && [ "$pick" -le "$count" ]; } || ok="" ;;
      esac
    done
    if [ -n "$ok" ]; then
      for ((i = 0; i < count; i++)); do
        case "$answer" in *" $((i + 1)) "*) selected="${selected:+$selected }${items[i]%%|*}" ;; esac
      done
      [ -n "$selected" ] && return
    fi
    echo "Nhập số từ 1 đến $count, vd 1,2."
  done
}

# xd_pick_plan <script của app> ⇒ gán $plan. Hỏi plan theo danh sách `<script> --plans`: mỗi dòng `id|nhãn`, dòng mặc định có
# `*` đứng đầu; rỗng = app không có plan ⇒ plan rỗng, không hỏi.
xd_pick_plan() {
  local plans=() line default=1
  plan=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    case "$line" in \**) line="${line#\*}"; default=$((${#plans[@]} + 1)) ;; esac
    plans+=("$line")
  done < <(bash "$1" --plans)
  [ ${#plans[@]} -gt 0 ] || return 0
  xd_select 'Plan:' "$default" "${plans[@]}"
  plan="$picked"
}
