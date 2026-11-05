#!/usr/bin/env bash
# Dựng máy mới cho workspace xdesktop (macOS / Linux). Idempotent — chạy lại lúc nào cũng được.
#   bash init.sh                 hỏi init project nào
#   bash init.sh fastcast        không hỏi (fastcast, materiant, groove; nhiều project thì liệt kê)
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
    groove) echo https://github.com/nguyendoai7777/groove.git ;;
    # Server chung của các app desktop (D-24); thư mục `cloud`, remote tên desktop-server.
    cloud) echo https://github.com/nguyendoai7777/desktop-server.git ;;
  esac
}

# App dùng server chung `cloud` (D-24): init app ⇒ kéo cloud theo + tạo khung env của app trong cloud/env/. App mới lên
# server: `node cloud/tools/new-app.mjs <app>` rồi thêm tên vào đây (và `$cloudApps` của init.ps1).
cloud_apps="fastcast"
uses_cloud() { case " $cloud_apps " in *" $1 "*) return 0 ;; esac; return 1; }
# Nhãn trong bảng chọn: "(kéo <repo>…)".
pulls() { local out="$1 + materiant"; uses_cloud "$1" && out="$out + cloud"; echo "$out"; }

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

selected="$(printf '%s' "$*" | tr ',' ' ')"
if [ -z "$selected" ] && [ -t 0 ]; then
  select_checklist 'Bạn muốn init project nào:' \
    "fastcast|fastcast   (kéo $(pulls fastcast))" 'materiant|materiant  (chỉ thư viện UI)' \
    "groove|groove     (kéo $(pulls groove))" 'cloud|cloud      (server chung mọi app: tài khoản, license, đồng bộ)'
fi
if [ -z "$selected" ]; then
  # Stdin là pipe: không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
  echo 'Bạn muốn init project nào:'
  echo "  [1] fastcast   (kéo $(pulls fastcast))  (Enter)"
  echo '  [2] materiant  (chỉ thư viện UI)'
  echo "  [3] groove     (kéo $(pulls groove))"
  echo '  [4] cloud      (server chung mọi app: tài khoản, license, đồng bộ)'
  while [ -z "$selected" ]; do
    printf 'Chọn (nhiều project thì cách bằng dấu phẩy): '
    read -r answer || answer=""
    [ -n "$answer" ] || answer=1
    for pick in $(printf '%s' "$answer" | tr ',' ' '); do
      case "$pick" in
        1) selected="$selected fastcast" ;;
        2) selected="$selected materiant" ;;
        3) selected="$selected groove" ;;
        4) selected="$selected cloud" ;;
        *) echo 'Nhập 1–4 hoặc nhiều số như 1,4.'; selected=""; break ;;
      esac
    done
  done
fi

wanted=""
for project in $selected; do
  case "$project" in
    fastcast | groove) wanted="$wanted $project materiant"; uses_cloud "$project" && wanted="$wanted cloud" ;;
    materiant) wanted="$wanted materiant" ;;
    cloud) wanted="$wanted cloud" ;;
    *) echo "✗ không có project $project" >&2; exit 1 ;;
  esac
done
for name in $(printf '%s\n' $wanted | awk '!seen[$0]++'); do
  dir="$root/$name"
  if [ -d "$dir/.git" ]; then echo "✓ $name có sẵn, không kéo lại"; continue; fi
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir")" ]; then echo "⚠ $dir có tệp nhưng không phải repo git — dọn tay rồi chạy lại" >&2; continue; fi
  url="$(repo_url "$name")"
  if [ -z "$url" ]; then echo "· $name chưa có remote, bỏ qua"; continue; fi
  git clone "$url" "$dir"
  echo "✓ $name đã clone"
done

# Khung env của app dùng server (cloud/env/<app>-dev.env, <app>.env — không theo git): tạo tệp thiếu, thêm biến mới vào
# tệp có sẵn, giá trị đã điền giữ nguyên. Giá trị bí mật vẫn phải điền / chép tay. Chọn `cloud` ⇒ mọi app dùng server.
env_apps=""
for project in $selected; do
  if [ "$project" = cloud ]; then env_apps="$env_apps $cloud_apps"; elif uses_cloud "$project"; then env_apps="$env_apps $project"; fi
done
env_apps="$(printf '%s\n' $env_apps | awk 'NF && !seen[$0]++' | tr '\n' ' ')"
if [ -n "$env_apps" ] && [ -f "$root/cloud/tools/new-app.mjs" ]; then
  if command -v node >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    node "$root/cloud/tools/new-app.mjs" --env-only $env_apps
  else
    echo "⚠ thiếu node: bỏ qua khung env của cloud ($env_apps) — cài Node rồi chạy lại" >&2
  fi
fi

# --- 3. Gói hệ thống (Linux) --------------------------------------------------------------------------------------
# Đủ mọi thư viện để build, chạy app của project đã chọn, kể cả gói -dev, để không phải cài tay. Thiếu thì cài, có rồi
# thì bỏ qua. Danh sách lấy từ cây `cargo tree --target x86_64-unknown-linux-gnu` (các crate `-sys`) và đã thử build
# trong container Ubuntu sạch. Thêm crate có thư viện hệ thống ⇒ thêm gói vào đây.
linux_packages() {
  # Nền GPUI / materiant: trình biên dịch C, X11 / Wayland, font, Vulkan; portal cho hộp chọn tệp.
  echo build-essential pkg-config cmake clang curl git ca-certificates \
    libfontconfig-dev libfreetype-dev libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libx11-dev libx11-xcb-dev libxcb1-dev libvulkan-dev libvulkan1 mesa-vulkan-drivers \
    xdg-desktop-portal xdg-desktop-portal-gtk
  for project in $wanted; do
    case "$project" in
      # Âm thanh ALSA (G-2, link động), đóng gói .deb.
      groove) echo libasound2-dev dpkg-dev ;;
      # Chụp màn hình X11 / Wayland (xcap, PipeWire), bindgen cần libclang.
      fastcast) echo libclang-dev libpipewire-0.3-dev libspa-0.2-dev libgbm-dev libdrm-dev libegl-dev \
        libxcb-randr0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxcb-shape0-dev ;;
    esac
  done
}

if [ "$(uname -s)" = Linux ]; then
  if command -v apt-get >/dev/null 2>&1; then
    missing=""
    for pkg in $(linux_packages | tr ' ' '\n' | awk 'NF && !seen[$0]++'); do
      dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed' || missing="$missing $pkg"
    done
    if [ -n "$missing" ]; then
      echo "→ cài gói hệ thống còn thiếu:$missing"
      sudo=""; [ "$(id -u)" = 0 ] || sudo=sudo
      $sudo apt-get update
      # shellcheck disable=SC2086
      $sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $missing
    fi
    echo "✓ gói hệ thống đủ cho:$selected"
  else
    echo "✗ chỉ tự cài được trên Ubuntu / Debian (apt). Cài các gói tương đương rồi chạy lại:" >&2
    echo "  $(linux_packages | tr '\n' ' ')" >&2
    exit 1
  fi
fi

# --- 4. Rust và công cụ cargo -------------------------------------------------------------------------------------
min_rust=1.99
if ! command -v cargo >/dev/null 2>&1 && [ -x "$HOME/.cargo/bin/cargo" ]; then export PATH="$HOME/.cargo/bin:$PATH"; fi
if ! command -v cargo >/dev/null 2>&1; then
  echo "→ cài Rust qua rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --component clippy,rustfmt
  export PATH="$HOME/.cargo/bin:$PATH"
  fresh_rust=1
fi
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }
rust_now="$(rustc --version | awk '{print $2}')"
if ! version_ge "$rust_now" "$min_rust"; then
  if command -v rustup >/dev/null 2>&1; then
    echo "→ Rust $rust_now cũ hơn $min_rust, cập nhật stable"
    rustup update stable
  else
    echo "✗ Rust $rust_now cũ hơn $min_rust và không có rustup — cập nhật tay." >&2
    exit 1
  fi
fi
if command -v rustup >/dev/null 2>&1; then
  for component in clippy rustfmt; do
    rustup component list --installed 2>/dev/null | grep -q "^$component" || rustup component add "$component"
  done
fi
if ! cargo deny --version >/dev/null 2>&1; then
  echo "→ cài cargo-deny (soát giấy phép, D-2)"
  cargo install --locked cargo-deny
fi
for tool in git cargo rustc; do
  if command -v "$tool" >/dev/null 2>&1; then echo "✓ $tool  $("$tool" --version | head -1)"; else echo "✗ thiếu $tool" >&2; exit 1; fi
done
echo "✓ cargo-deny  $(cargo deny --version)"
if [ -n "${fresh_rust:-}" ]; then echo "⚠ Rust vừa cài: mở terminal mới (hoặc '. ~/.cargo/env') để có cargo trong PATH." >&2; fi
