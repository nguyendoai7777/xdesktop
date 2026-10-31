#!/usr/bin/env bash
# Dựng máy mới cho workspace xdesktop (macOS / Linux). Idempotent — chạy lại lúc nào cũng được.
#   bash init.sh                 hỏi init project nào
#   bash init.sh fastcast        không hỏi (fastcast, materiant; nhiều project thì liệt kê)
# Git Bash trên Windows ⇒ đá sang init.ps1 (junction cần PowerShell).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    if [ $# -gt 0 ]; then
      exec pwsh -NoProfile -Command "& '$(cygpath -w "$root/init.ps1")' -Project $(IFS=,; echo "$*")"
    fi
    exec pwsh -NoProfile -File "$(cygpath -w "$root/init.ps1")" ;;
esac

# --- 1. Memory: nối thư mục memory của Claude trên máy này vào .claude/memory (track trong git) ------------------
# Claude Code đặt tên thư mục project bằng đường dẫn tuyệt đối, mọi ký tự không phải chữ / số thành '-'.
slug="$(printf '%s' "$root" | sed 's/[^A-Za-z0-9]/-/g')"
machine_dir="$HOME/.claude/projects/$slug/memory"
shared="$root/.claude/memory"
mkdir -p "$shared"

if [ -L "$machine_dir" ]; then
  if [ "$(cd "$machine_dir" && pwd -P)" = "$(cd "$shared" && pwd -P)" ]; then
    echo "✓ memory: đã nối $machine_dir → $shared"
  else
    echo "⚠ memory: $machine_dir đang nối chỗ khác — gỡ symlink đó rồi chạy lại." >&2
  fi
else
  if [ -d "$machine_dir" ]; then
    # Thư mục thật: dời tệp sang bộ dùng chung. Trùng tên mà khác nội dung ⇒ giữ cả hai.
    for f in "$machine_dir"/* "$machine_dir"/.[!.]*; do
      [ -f "$f" ] || continue
      name="$(basename "$f")"
      if [ ! -e "$shared/$name" ]; then
        mv "$f" "$shared/$name"
      elif cmp -s "$f" "$shared/$name"; then
        rm "$f"
      else
        alt="$shared/${name%.*}.$(hostname -s | tr '[:upper:]' '[:lower:]').${name##*.}"
        mv "$f" "$alt"
        echo "⚠ memory: $name khác bản dùng chung — đã giữ thành $(basename "$alt"), gộp tay." >&2
      fi
    done
    rmdir "$machine_dir" || { echo "✗ memory: $machine_dir còn thư mục con — dọn tay rồi chạy lại." >&2; exit 1; }
  else
    mkdir -p "$(dirname "$machine_dir")"
  fi
  ln -s "$shared" "$machine_dir"
  echo "✓ memory: nối $machine_dir → $shared"
fi

# --- 2. Repo của project được chọn; repo đã có thì giữ nguyên, không pull ------------------------------------------
# Không dùng mảng kết hợp: bash mặc định của macOS là 3.2.
# Thư mục luôn là `materiant` (fastcast trỏ `../materiant`); trên remote tên materiant-rust để khỏi trùng bản web Angular.
repo_url() {
  case "$1" in
    fastcast) echo https://github.com/nguyendoai7777/fastcast.git ;;
    materiant) echo https://github.com/nguyendoai7777/materiant-rust.git ;;
  esac
}

# select_checklist <tiêu đề> <id|nhãn>… ⇒ gán $selected. ↑ ↓ di chuyển, Space tích / bỏ, Enter xác nhận. Vẽ lại tại chỗ
# bằng mã ANSI, phải có ít nhất một mục được tích. `read -t` số nguyên: bash 3.2 của macOS không nhận số lẻ.
select_checklist() {
  local title="$1" cursor=0 count i key rest box hint='↑ ↓ di chuyển · space chọn · enter xác nhận'
  shift
  count=$#
  local checked=()
  local items=("$@")
  for ((i = 0; i < count; i++)); do checked[i]=0; done
  echo "$title"
  printf '\033[?25l'
  trap 'printf "\033[?25h"' EXIT
  while :; do
    for ((i = 0; i < count; i++)); do
      if [ "${checked[i]}" = 1 ]; then box='[x]'; else box='[ ]'; fi
      if [ "$i" = "$cursor" ]; then
        printf '\r\033[2K\033[36m> %s %s\033[0m\n' "$box" "${items[i]#*|}"
      else
        printf '\r\033[2K  %s %s\n' "$box" "${items[i]#*|}"
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
        selected=""
        for ((i = 0; i < count; i++)); do
          if [ "${checked[i]}" = 1 ]; then selected="$selected ${items[i]%%|*}"; fi
        done
        if [ -n "$selected" ]; then
          printf '\033[J\033[?25h'
          trap - EXIT
          echo "Đã chọn:$selected"
          return
        fi
        hint='chưa chọn project nào, bấm space để chọn' ;;
    esac
  done
}

selected="$*"
if [ -z "$selected" ] && [ -t 0 ]; then
  select_checklist 'Bạn muốn init project nào:' \
    'fastcast|fastcast   (kéo fastcast + materiant)' 'materiant|materiant  (chỉ thư viện UI)'
fi
if [ -z "$selected" ]; then
  # Stdin là pipe: không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
  echo 'Bạn muốn init project nào:'
  echo '  [1] fastcast   (kéo fastcast + materiant)  (Enter)'
  echo '  [2] materiant  (chỉ thư viện UI)'
  while [ -z "$selected" ]; do
    printf 'Chọn (nhiều project thì cách bằng dấu phẩy): '
    read -r answer || answer=""
    [ -n "$answer" ] || answer=1
    for pick in $(printf '%s' "$answer" | tr ',' ' '); do
      case "$pick" in
        1) selected="$selected fastcast" ;;
        2) selected="$selected materiant" ;;
        *) echo 'Nhập 1, 2 hoặc 1,2.'; selected=""; break ;;
      esac
    done
  done
fi

wanted=""
for project in $selected; do
  case "$project" in
    fastcast) wanted="$wanted fastcast materiant" ;;
    materiant) wanted="$wanted materiant" ;;
    *) echo "✗ không có project $project" >&2; exit 1 ;;
  esac
done
for name in $(printf '%s\n' $wanted | awk '!seen[$0]++'); do
  dir="$root/$name"
  if [ -d "$dir/.git" ]; then echo "✓ $name có sẵn, không kéo lại"; continue; fi
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir")" ]; then echo "⚠ $dir có tệp nhưng không phải repo git — dọn tay rồi chạy lại" >&2; continue; fi
  git clone "$(repo_url "$name")" "$dir"
  echo "✓ $name đã clone"
done

# --- 3. Công cụ ---------------------------------------------------------------------------------------------------
for tool in git cargo rustc; do
  if command -v "$tool" >/dev/null 2>&1; then echo "✓ $tool  $("$tool" --version | head -1)"; else echo "⚠ thiếu $tool" >&2; fi
done
