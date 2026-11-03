#!/usr/bin/env bash
# Mở nhanh app của workspace để xem tay (macOS / Linux / Git Bash). Đứng ở gốc workspace:
#   bash start.sh docs                  gallery materiant (bản master), trang đầu
#   bash start.sh docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   bash start.sh docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                       chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   bash start.sh launcher              launcher example của materiant (bản master; tham số 2 = worktree)
#   bash start.sh groove                Groove X (bản master)
#   bash start.sh fastcast [màn]        Fastcast bản debug (inspector: Ctrl+Shift+I, Ctrl+Shift+C) + daemon giả + cấu hình dev riêng;
#                                       màn = settings (mặc định) | launcher | overlay | ruler | picker (Linux: overlay/ruler/picker dùng fastcast/tools/fake-screens.sh)
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
  fastcast)
    # Bản debug có inspector, daemon giả (không phím tắt toàn cục, không khay), cấu hình dev riêng: không đụng Fastcast đã cài.
    # Git Bash trên Windows ⇒ đá sang start.ps1 (endpoint là named pipe).
    case "$(uname -s)" in
      MINGW*|MSYS*|CYGWIN*) exec pwsh -NoProfile -File "$(cygpath -w "$root/start.ps1")" fastcast "${@:2}" ;;
    esac
    screen="${page:-settings}"
    case "$screen" in
      settings) command=open_settings ;;
      launcher) command=open_launcher ;;
      overlay) command=capture_region ;;
      ruler) command=ruler ;;
      picker) command=color_picker ;;
      *) echo "Màn '$screen' không hợp lệ. Hợp lệ: settings, launcher, overlay, ruler, picker"; exit 1 ;;
    esac
    os="$(uname -s)"
    fake=0
    case "$command" in capture_region|ruler|color_picker) fake=1 ;; esac
    if [ "$fake" = 1 ] && [ "$os" = Linux ]; then
      echo "Màn '$screen' trên Linux: Wayland không cho app tự đặt chỗ cửa sổ thường nên FASTCAST_OVERLAY_FAKE=1 chồng các màn giả lên nhau."
      echo "Dùng: bash fastcast/tools/fake-screens.sh rồi gõ lệnh ($command) vào terminal của nó."
      exit 2
    fi
    target="$root/fastcast/target/start"
    export CARGO_TARGET_DIR="$target"
    # Socket của endpoint `dev` (fastcast_core::ipc::Endpoint::custom): temp_dir() = $TMPDIR hoặc /tmp.
    sock="${TMPDIR:-/tmp}"; sock="${sock%/}/fastcast-dev.sock"
    if [ -S "$sock" ]; then
      # `listen` xoá socket cũ còn sót, nên chỉ báo khi có tiến trình thật đang nghe (cần `nc -U`); không có `nc` thì coi là sót.
      if command -v nc >/dev/null 2>&1 && nc -U -z "$sock" 2>/dev/null; then
        echo "đã có fake_daemon dev đang chạy (session khác?)"
        exit 1
      fi
      rm -f "$sock"
    fi
    cargo build --manifest-path "$root/fastcast/Cargo.toml" -p fastcast-ui --bin fastcast-ui --example fake_daemon

    # Cấu hình dev: lần đầu chép từ cấu hình thật (fastcast_core::paths::config_dir).
    dev_config="$target/dev-config.json"
    if [ "$os" = Darwin ]; then real_config="$HOME/Library/Application Support/fastcast/config.json"
    else real_config="${XDG_CONFIG_HOME:-$HOME/.config}/fastcast/config.json"; fi
    if [ ! -f "$dev_config" ] && [ -f "$real_config" ]; then cp "$real_config" "$dev_config"; fi
    export FASTCAST_CONFIG_FILE="$dev_config"
    echo "cấu hình dev: $dev_config"
    if [ "$fake" = 1 ]; then export FASTCAST_OVERLAY_FAKE=1; else unset FASTCAST_OVERLAY_FAKE; fi

    echo "Gõ vào đây: open_launcher, capture_region, ruler, color_picker, open_settings…; quit hoặc Ctrl+C để thoát. Trong cửa sổ: Ctrl+Shift+I mở inspector, Ctrl+Shift+C chọn phần tử."
    # Job nền không đọc được tty ⇒ daemon giả chạy tiền cảnh, UI bật từ subshell nền khi socket đã có (trần 10 s).
    # exec trong subshell ⇒ pid của job = pid của UI. UI mất daemon mà còn cửa sổ thì chờ đóng cửa sổ cuối ⇒ phải giết.
    (
      for _ in $(seq 200); do [ -S "$sock" ] && break; sleep 0.05; done
      [ -S "$sock" ] || { echo "fake_daemon không mở socket sau 10 s" >&2; exit 1; }
      exec "$target/debug/fastcast-ui" --endpoint dev --command "$command"
    ) &
    ui_pid=$!
    trap 'kill "$ui_pid" 2>/dev/null || true' EXIT
    trap 'exit 130' INT TERM
    set +e
    "$target/debug/examples/fake_daemon" dev
    exit $?
    ;;
  list) show_worktrees ;;
  *) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
