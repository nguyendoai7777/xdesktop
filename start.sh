#!/usr/bin/env bash
# Mở nhanh app của workspace để xem tay (macOS / Linux / Git Bash). Đứng ở gốc workspace:
#   bash start.sh docs                  gallery materiant (bản master), trang đầu
#   bash start.sh docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   bash start.sh docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                       chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   bash start.sh launcher              launcher example của materiant (bản master; tham số 2 = worktree)
#   bash start.sh groove                Groovex (bản master)
#   bash start.sh fastcast [màn]        Fastcast bản debug (inspector: Ctrl+Shift+I, Ctrl+Shift+C) + cấu hình dev riêng;
#                                       màn = app (mặc định: `fst` thật — khay + phím tắt toàn cục; phải thoát bản đã cài trước)
#                                       | settings | launcher | overlay | ruler | picker (daemon giả, không khay, không phím;
#                                       Linux: overlay/ruler/picker dùng fastcast/tools/fake-screens.sh)
#   bash start.sh list                  liệt kê worktree đang mở
# docs / launcher / groove mặc định theo dõi mã (tools/watch-run.mjs): lưu tệp ⇒ build lại, mở lại app (mất trạng thái đang mở).
# Thêm --no-watch (ở vị trí bất kỳ) hoặc XDESKTOP_NO_WATCH=1 để chỉ build rồi chạy một lần.
# Master build ở materiant/target/start; worktree build ở materiant/target/<worktree> (thư mục của chính session đó —
# không build nguội lại, nhưng có thể chờ khoá khi session đang build). Không trộn: cargo dễ đưa ra exe của nguồn khác.
# Trong gallery: ↑ / ↓ đổi trang, Ctrl+T xoay Light / Dark / System.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
worktrees="$root/.claude/worktrees"
# Build qua tools/cargo-prune.mjs: build xong dọn bản build cũ trong target/start (target/w<N> chỉ build, không dọn).
prune="$root/tools/cargo-prune.mjs"

show_worktrees() {
  local found=0
  for d in "$worktrees"/materiant-*/; do
    [ -d "$d" ] || continue
    found=1
    printf '  %-14s %s\n' "$(basename "$d" | sed 's/^materiant-//')" "$(git -C "$d" branch --show-current 2>/dev/null)"
  done
  [ "$found" = 1 ] || echo "Không có worktree materiant nào đang mở."
}

# Wayland không cho app tự gửi icon: GNOME ghép cửa sổ theo `app_id` với `<app_id>.desktop` để lấy icon cho dock.
# Bản debug có mã riêng `groove.dev` (groove `window_state::DEV_APP_ID`, MPRIS `groovex.dev`) ⇒ mục `groove.dev.desktop`
# "Groovex (dev)" hiện trong ô tìm, cạnh "Groovex" của gói đã cài, không đè nhau. Không MimeType: không giành việc mở tệp nhạc.
# Mission Center bản snap ghép scope `app-xdesktop-groove.dev-*` với mục đó, đọc home riêng của snap trước
# (XDG_DATA_HOME = ~/snap/mission-center/current/.local/share). Snap không có plug `home` ⇒ không đọc được ảnh trong repo:
# ghi thêm một bản vào home snap, icon trỏ tới ảnh chép sang đó. Không `NoDisplay` / `Hidden`: app-rummage bỏ hẳn các mục đó.
groove_dev_desktop_entry() {
  local icon="$root/groove/packaging/linux/icons/256x256.png" mc="$HOME/snap/mission-center/current/.local/share"
  groove_dev_desktop_entry_in "${XDG_DATA_HOME:-$HOME/.local/share}/applications" "$icon"
  if [ -d "$HOME/snap/mission-center/current" ]; then
    mkdir -p "$mc/icons" && cp -u "$icon" "$mc/icons/groove-dev.png"
    groove_dev_desktop_entry_in "$mc/applications" "$mc/icons/groove-dev.png"
  fi
}

groove_dev_desktop_entry_in() {
  local dir="$1" icon="$2"
  local file="$dir/groove.dev.desktop" old="$dir/groove.desktop" marker="X-Xdesktop-Dev=true"
  # Bản cũ ghi mục dev trùng tên `groove.desktop` của gói (che mục của gói): gỡ nếu đúng là của script.
  if [ -f "$old" ] && grep -qx "$marker" "$old"; then rm -f "$old"; fi
  if [ -f "$file" ] && ! grep -qx "$marker" "$file"; then return 0; fi
  mkdir -p "$dir"
  cat > "$file.tmp" <<EOF
[Desktop Entry]
Type=Application
Name=Groovex (dev)
Exec=$CARGO_TARGET_DIR/debug/groove
Icon=$icon
Terminal=false
Categories=AudioVideo;Audio;Player;
StartupWMClass=groove.dev
$marker
Actions=pip;

[Desktop Action pip]
Name=Picture in picture
Name[vi]=Trình phát thu nhỏ
Exec=$CARGO_TARGET_DIR/debug/groove --pip
EOF
  mv "$file.tmp" "$file"
}

watch=1
args=()
for a in "$@"; do
  if [ "$a" = --no-watch ]; then watch=0; else args+=("$a"); fi
done
[ "${XDESKTOP_NO_WATCH:-}" = 1 ] && watch=0
set -- "${args[@]+"${args[@]}"}"

# Build rồi chạy: watch ⇒ tools/watch-run.mjs (build qua cargo-prune, theo dõi các thư mục --watch); không ⇒ build một lần rồi exec.
#   run_app [--scope <desktop id>] <exe> <thư mục theo dõi, cách nhau ":"> <đối số app…> -- <đối số cargo build…>
# --scope: Linux chạy app trong scope systemd riêng (xem tools/watch-run.mjs) ⇒ Mission Center hiện app thành dòng riêng.
run_app() {
  local scope=""
  if [ "$1" = --scope ]; then scope="$2"; shift 2; fi
  local exe="$1" dirs="$2"; shift 2
  local app_args=()
  while [ "$1" != -- ]; do app_args+=("$1"); shift; done
  shift
  if [ "$watch" = 1 ]; then
    local opts=(--exe "$exe") d a
    [ -n "$scope" ] && opts+=(--scope "$scope")
    IFS=: read -ra ds <<< "$dirs"
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
    page_args=()
    [ -n "$page" ] && page_args=(--page "$page")
    run_app "$CARGO_TARGET_DIR/debug/examples/gallery" "$dir/src:$dir/examples:$dir/assets:$dir/vendor:$dir/Cargo.toml" \
      "${page_args[@]+"${page_args[@]}"}" -- --manifest-path "$dir/Cargo.toml" -p materiant --example gallery
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
    run_app "$CARGO_TARGET_DIR/debug/examples/launcher" "$dir/src:$dir/examples:$dir/assets:$dir/vendor:$dir/Cargo.toml" \
      -- --manifest-path "$dir/Cargo.toml" -p materiant --example launcher
    ;;
  groove)
    # Dữ liệu thật của máy, cửa sổ ở nơi OS hoặc vị trí đã lưu chọn: lệnh này để chủ dự án xem tay.
    export CARGO_TARGET_DIR="$root/groove/target/start"
    [ "$(uname -s)" = Linux ] && groove_dev_desktop_entry
    m="$root/materiant"
    run_app --scope groove.dev "$CARGO_TARGET_DIR/debug/groove" \
      "$root/groove/crates:$root/groove/i18n:$root/groove/Cargo.toml:$m/src:$m/assets:$m/vendor:$m/Cargo.toml" \
      -- --manifest-path "$root/groove/Cargo.toml" -p groove-app
    ;;
  fastcast)
    # macOS: bản dev là exe rời, không phải Fastcast.app ⇒ quyền ghi màn hình tính cho app terminal đang chạy lệnh này (app gần
    # nhất trên cây tiến trình cha; app con trong app khác như Claude Helper ⇒ app ngoài cùng), không phải Fastcast đã cài. Thiếu ⇒ đưa terminal vào danh sách, mở đúng trang, nói tên app.
    mac_screen_access() {
      local cg='ObjC.import("CoreGraphics"); ObjC.bindFunction("CGPreflightScreenCaptureAccess", ["bool", []]); $.CGPreflightScreenCaptureAccess()'
      [ "$(osascript -l JavaScript -e "$cg" 2>/dev/null)" = true ] && return 0
      local pid=$$ path app=""
      while [ "${pid:-0}" -gt 1 ]; do
        path="$(ps -p "$pid" -o comm= 2>/dev/null || true)"
        case "$path" in */*.app/Contents/*) app="${path%%.app/*}"; app="${app##*/}"; break ;; esac
        pid="$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ' || true)"
      done
      osascript -l JavaScript -e "${cg//Preflight/Request}" >/dev/null 2>&1 || true
      open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture" 2>/dev/null || true
      echo "Chưa có quyền ghi màn hình: bản dev dùng quyền của app terminal ${app:+($app) }chứ không phải Fastcast đã cài."
      echo "Bật ${app:-app terminal này} trong System Settings > Privacy & Security > Screen & System Audio Recording, thoát hẳn rồi mở lại nó, chạy lại lệnh."
      echo "Vẫn chạy tiếp: chụp / quay sẽ báo thiếu quyền tới khi bật."
    }
    # Bản debug có inspector, cấu hình dev riêng. `app`: daemon thật (khay + phím tắt toàn cục) — một instance nên bản đã cài
    # phải thoát trước. Màn khác: daemon giả (không phím tắt toàn cục, không khay), không đụng Fastcast đã cài.
    # Git Bash trên Windows ⇒ đá sang start.ps1 (endpoint là named pipe).
    case "$(uname -s)" in
      MINGW*|MSYS*|CYGWIN*) exec pwsh -NoProfile -File "$(cygpath -w "$root/start.ps1")" fastcast "${@:2}" ;;
    esac
    screen="${page:-app}"
    case "$screen" in
      app) command="" ;;
      settings) command=open_settings ;;
      launcher) command=open_launcher ;;
      overlay) command=capture_region ;;
      ruler) command=ruler ;;
      picker) command=color_picker ;;
      *) echo "Màn '$screen' không hợp lệ. Hợp lệ: app, settings, launcher, overlay, ruler, picker"; exit 1 ;;
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
    mkdir -p "$target"
    # Cấu hình dev: lần đầu chép từ cấu hình thật (fastcast_core::paths::config_dir).
    dev_config="$target/dev-config.json"
    if [ "$os" = Darwin ]; then real_config="$HOME/Library/Application Support/fastcast/config.json"
    else real_config="${XDG_CONFIG_HOME:-$HOME/.config}/fastcast/config.json"; fi
    if [ ! -f "$dev_config" ] && [ -f "$real_config" ]; then cp "$real_config" "$dev_config"; fi
    export FASTCAST_CONFIG_FILE="$dev_config"
    echo "cấu hình dev: $dev_config"

    if [ "$screen" = app ]; then
      # Một instance: `fst` thứ hai chỉ báo bản đang chạy mở launcher rồi thoát ⇒ soát trước, nói rõ bản nào đang giữ.
      own="$target/debug/fst"
      for pid in $(pgrep -x fst 2>/dev/null || true); do
        exe="$(readlink "/proc/$pid/exe" 2>/dev/null || ps -p "$pid" -o comm= 2>/dev/null || true)"
        if [ "${exe% (deleted)}" = "$own" ]; then
          echo "fst bản debug đã chạy (pid $pid, session khác?)"
        else
          echo "Fastcast đang chạy (pid $pid: ${exe:-fst}). Thoát nó trước: fst quit (hoặc Thoát ở menu khay), rồi chạy lại."
        fi
        exit 1
      done
      node "$prune" build --manifest-path "$root/fastcast/Cargo.toml" -p fastcast-daemon --bin fst -p fastcast-ui --bin fastcast-ui \
        -p fastcast-video --bin fastcast-rec -p fastcast-ocr --bin fastcast-ocr
      [ "$os" = Darwin ] && mac_screen_access
      echo "fst thật (bản debug): khay + phím tắt theo cấu hình dev. Lệnh từ terminal khác: $own run <lệnh>, $own quit. Ctrl+C để thoát."
      [ "$os" = Linux ] && echo "GNOME: phím tắt ghi vào dconf, trỏ tới exe debug; mở lại Fastcast đã cài thì nó ghi lại đường dẫn của nó."
      exec "$own"
    fi
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
    node "$prune" build --manifest-path "$root/fastcast/Cargo.toml" -p fastcast-ui --bin fastcast-ui --example fake_daemon

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
  *) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
