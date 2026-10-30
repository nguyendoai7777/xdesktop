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

selected="$*"
if [ -z "$selected" ]; then
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
