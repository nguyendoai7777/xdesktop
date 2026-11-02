#!/usr/bin/env bash
# Mở nhanh app của workspace để xem tay (macOS / Linux / Git Bash). Đứng ở gốc workspace:
#   bash start.sh docs                  gallery materiant (bản master), trang đầu
#   bash start.sh docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   bash start.sh docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                       chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   bash start.sh launcher              launcher example của materiant (bản master; tham số 2 = worktree)
#   bash start.sh groove                Groove X (bản master)
#   bash start.sh list                  liệt kê worktree đang mở
# Master build ở materiant/target/start; worktree build ở materiant/target/<worktree> (thư mục của chính session đó —
# không build nguội lại, nhưng có thể chờ khoá khi session đang build). Không trộn: cargo dễ đưa ra exe của nguồn khác.
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
    # Mỗi nguồn một thư mục build (cargo trộn worktree trong cùng target ⇒ dễ ra exe của nguồn khác).
    name="${worktree#materiant-}"; name="${name:-start}"
    export CARGO_TARGET_DIR="$root/materiant/target/$name"
    echo "gallery từ $dir"
    if [ -n "$page" ]; then
      exec cargo run --manifest-path "$dir/Cargo.toml" -p materiant --example gallery -- --page "$page"
    else
      exec cargo run --manifest-path "$dir/Cargo.toml" -p materiant --example gallery
    fi
    ;;
  launcher)
    # `start.sh launcher <worktree>`: launcher không có trang nên worktree là tham số thứ hai.
    wt="${page#materiant-}"
    dir="$root/materiant"
    if [ -n "$wt" ]; then
      dir="$worktrees/materiant-$wt"
      if [ ! -d "$dir" ]; then
        echo "Không thấy worktree '$wt'. Đang mở:"
        show_worktrees
        exit 1
      fi
    fi
    export CARGO_TARGET_DIR="$root/materiant/target/${wt:-start}"
    echo "launcher từ $dir"
    exec cargo run --manifest-path "$dir/Cargo.toml" -p materiant --example launcher
    ;;
  groove)
    # Dữ liệu thật của máy, cửa sổ ở nơi OS hoặc vị trí đã lưu chọn: lệnh này để chủ dự án xem tay.
    export CARGO_TARGET_DIR="$root/groove/target/start"
    exec cargo run --manifest-path "$root/groove/Cargo.toml" -p groove-app
    ;;
  list) show_worktrees ;;
  *) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
