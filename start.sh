#!/usr/bin/env bash
# Mở nhanh app của workspace để xem tay (macOS / Linux / Git Bash). Đứng ở gốc workspace:
#   bash start.sh docs                  gallery materiant (bản master), trang đầu
#   bash start.sh docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   bash start.sh docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                       chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   bash start.sh list                  liệt kê worktree đang mở
# Build ở materiant/target/start, tách khỏi thư mục build của các session Claude ⇒ không bị khoá; lần đầu build nguội.
# Trong gallery: ↑ / ↓ đổi trang, Ctrl+T xoay Light / Dark / System.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
worktrees="$root/.claude/worktrees"

show_worktrees() {
  local found=0
  for d in "$worktrees"/materiant-*/; do
    [ -d "$d" ] || continue
    found=1
    printf '  %-14s %s\n' "$(basename "$d" | sed 's/^materiant-//')" "$(git -C "$d" branch --show-current 2>/dev/null)"
  done
  [ "$found" = 1 ] || echo "Không có worktree materiant nào đang mở."
}

app="${1:-help}" page="${2:-}" worktree="${3:-}"
case "$app" in
  docs)
    dir="$root/materiant"
    if [ -n "$worktree" ]; then
      dir="$worktrees/materiant-${worktree#materiant-}"
      if [ ! -d "$dir" ]; then
        echo "Không thấy worktree '$worktree'. Đang mở:"
        show_worktrees
        exit 1
      fi
    fi
    # Thư mục build riêng: không chờ khoá của các session Claude (chúng dùng materiant/target). Lần đầu build nguội.
    export CARGO_TARGET_DIR="$root/materiant/target/start"
    echo "gallery từ $dir"
    if [ -n "$page" ]; then
      exec cargo run --manifest-path "$dir/Cargo.toml" -p materiant --example gallery -- --page "$page"
    else
      exec cargo run --manifest-path "$dir/Cargo.toml" -p materiant --example gallery
    fi
    ;;
  list) show_worktrees ;;
  *) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
