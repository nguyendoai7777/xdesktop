#!/usr/bin/env bash
# Dựng máy mới cho workspace xdesktop (macOS / Linux). Idempotent — chạy lại lúc nào cũng được.
#   bash init.sh
# Git Bash trên Windows ⇒ đá sang init.ps1 (junction cần PowerShell).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
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

# --- 2. Repo con (điền remote khi tạo repo; mỗi dòng "<thư mục> <remote>") --------------------------------------
# Không dùng mảng kết hợp: bash mặc định của macOS là 3.2. Thiếu remote = repo mới chỉ có local (Q-2) — chỉ báo.
repos="
fastcast
materiant
"
printf '%s\n' "$repos" | while read -r name url; do
  case "$name" in ''|'#'*) continue ;; esac
  if [ -d "$root/$name/.git" ]; then echo "✓ $name có sẵn"; continue; fi
  if [ -z "${url:-}" ]; then echo "⚠ $name chưa có remote — chép tay từ máy khác hoặc điền remote vào init.ps1 / init.sh" >&2; continue; fi
  git clone "$url" "$root/$name"
done

# --- 3. Công cụ ---------------------------------------------------------------------------------------------------
for tool in git cargo rustc; do
  if command -v "$tool" >/dev/null 2>&1; then echo "✓ $tool  $("$tool" --version | head -1)"; else echo "⚠ thiếu $tool" >&2; fi
done
