#!/usr/bin/env bash
# Build bản release. Hỏi project (fastcast / groove / materiant docs) rồi, với fastcast, OS → kiến trúc → chip (Enter = máy
# đang chạy). Groovex: bản cài cho máy đang chạy ở release/groove/. materiant: chỉ gallery docs, ra
# release/materiant/materiant-docs. Đứng ở gốc workspace:
#   bash build.sh
#   bash build.sh --project fastcast --os linux --arch x64 --chip intel-amd      # không hỏi
#   bash build.sh -f                                          # --force: biên dịch lại mã của ta, giữ thư viện đã build
# Ra release/fastcast/<target>[-avx2]/ (macOS: Fastcast.app + .dmg để cài; OS khác: bốn exe, models, licenses — chạy `fst`). Chỉ build được cho OS đang chạy: thiếu SDK
# để link chéo OS. Git Bash trên Windows ⇒ đá sang build.ps1.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$root/fastcast"

os="" arch="" chip="" force="" project=""
while [ $# -gt 0 ]; do
  case "$1" in
    --project) project="$2"; shift 2 ;;
    --os) os="$2"; shift 2 ;;
    --arch) arch="$2"; shift 2 ;;
    --chip) chip="$2"; shift 2 ;;
    -f|--force) force=1; shift ;;
    *) echo "Không hiểu tham số: $1" >&2; exit 1 ;;
  esac
done

# Git Bash trên Windows: mọi việc (cả câu hỏi) do build.ps1 làm.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    forward=()
    [ -n "$project" ] && forward+=(-Project "$project")
    [ -n "$os" ] && forward+=(-Os "$os")
    [ -n "$arch" ] && forward+=(-Arch "$arch")
    [ -n "$chip" ] && forward+=(-Chip "$chip")
    [ -n "$force" ] && forward+=(-Force)
    exec pwsh -NoProfile -File "$(cygpath -w "$root/build.ps1")" ${forward[@]+"${forward[@]}"} ;;
  Darwin) host_os=macos ;;
  *) host_os=linux ;;
esac
case "$(uname -m)" in
  arm64|aarch64) host_arch=arm64 ;;
  *) host_arch=x64 ;;
esac

# select_option <tiêu đề> <số thứ tự mặc định> <id|nhãn>… ⇒ gán $picked. Radio, chỉ chọn một: ↑ ↓ di chuyển, Enter chọn; vẽ lại tại chỗ bằng mã
# ANSI. `read -t` số nguyên: bash 3.2 của macOS không nhận số lẻ. Stdin là pipe ⇒ gõ số; hết stdin thì lấy mặc định.
select_option() {
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

# --os / --arch / --chip chỉ có ở fastcast: có cờ đó thì khỏi hỏi project.
[ -n "$project$os$arch$chip" ] || { select_option 'Build project nào:' 1 'fastcast|Fastcast' 'groove|Groovex' 'materiant|materiant (docs only)'; project="$picked"; }
project="${project:-fastcast}"

case "$project" in
  # Groovex: bản cài cho đúng máy đang chạy, ra release/groove/. Dựng thật do script của repo groove.
  groove)
    if [ -n "$os$arch$chip" ]; then
      echo "groove chỉ build cho máy đang chạy, không nhận --os, --arch, --chip." >&2
      exit 1
    fi
    if [ -n "$force" ]; then
      clean_target=()
      if [ "$host_os" = macos ]; then
        case "$host_arch" in arm64) clean_target=(--target aarch64-apple-darwin) ;; *) clean_target=(--target x86_64-apple-darwin) ;; esac
      fi
      cargo clean --release --manifest-path "$root/groove/Cargo.toml" ${clean_target[@]+"${clean_target[@]}"} \
        -p groove-app -p groove -p groove-audio -p groove-core -p groove-library -p materiant
    fi
    case "$host_os" in
      macos) exec bash "$root/groove/packaging/macos/build-macos.sh" --out "$root/release/groove/macos-$(uname -m)" ;;
      *) exec bash "$root/groove/packaging/linux/build-deb.sh" --out "$root/release/groove" ;;
    esac ;;
  # materiant chỉ có gallery docs (assets nhúng sẵn trong exe).
  materiant)
    if [ -n "$os$arch$chip" ]; then
      echo "materiant chỉ build cho máy đang chạy, không nhận --os, --arch, --chip." >&2
      exit 1
    fi
    manifest="$root/materiant/Cargo.toml"
    [ -f "$manifest" ] || { echo "Thiếu materiant: chạy bash init.sh." >&2; exit 1; }
    [ -z "$force" ] || cargo clean --release --manifest-path "$manifest" -p materiant
    node "$root/tools/cargo-prune.mjs" build --release --locked --manifest-path "$manifest" -p materiant --example gallery
    mkdir -p "$root/release/materiant"
    cp "${CARGO_TARGET_DIR:-$root/materiant/target}/release/examples/gallery" "$root/release/materiant/materiant-docs"
    printf '\nXong: %s\n' "$root/release/materiant/materiant-docs"
    exit 0 ;;
  fastcast) ;;
  *) echo "--project: fastcast, groove hoặc materiant" >&2; exit 1 ;;
esac

if [ -z "$os" ]; then
  case "$host_os" in macos) d=2 ;; *) d=3 ;; esac
  select_option 'Build cho OS nào:' "$d" 'windows|Windows' 'macos|macOS' 'linux|Linux'
  os="$picked"
fi
case "$os" in windows|macos|linux) ;; *) echo "OS không hợp lệ: $os" >&2; exit 1 ;; esac
if [ "$os" != "$host_os" ]; then
  echo "Máy này chạy $host_os, không link được bản $os. Chạy build trên máy $os." >&2
  exit 1
fi
if [ -z "$arch" ]; then
  case "$host_arch" in arm64) d=2 ;; *) d=1 ;; esac
  select_option 'Kiến trúc:' "$d" 'x64|x64 (64-bit Intel / AMD)' 'arm64|arm64'
  arch="$picked"
fi

case "$os-$arch" in
  linux-x64) triple=x86_64-unknown-linux-gnu
    chips=('intel-amd|Intel / AMD, chạy trên mọi máy' 'avx2|Intel / AMD đời mới có AVX2 (x86-64-v3), máy cũ không chạy được') ;;
  linux-arm64) triple=aarch64-unknown-linux-gnu; chips=('arm|ARM 64-bit') ;;
  macos-x64) triple=x86_64-apple-darwin; chips=('intel|Intel') ;;
  macos-arm64) triple=aarch64-apple-darwin; chips=('apple|Apple Silicon (M1 trở lên)') ;;
  *) echo "Kiến trúc không hợp lệ: $arch" >&2; exit 1 ;;
esac
if [ -z "$chip" ]; then
  select_option 'Loại chip:' 1 "${chips[@]}"
  chip="$picked"
else
  valid=""
  for item in "${chips[@]}"; do [ "${item%%|*}" = "$chip" ] && valid=1; done
  [ -n "$valid" ] || { echo "Chip $chip không có ở $os $arch." >&2; exit 1; }
fi

# Linux: GPUI + quay cần thư viện dev của hệ thống, `dpkg-shlibdeps` để dựng `.deb`. Có đủ thì thôi, thiếu thì tự cài
# (apt hỏi mật khẩu sudo ngay trong terminal này); không có apt thì in danh sách rồi dừng.
if [ "$os" = linux ]; then
  dev_packages="pkg-config clang libegl-dev libgbm-dev libpipewire-0.3-dev dpkg-dev"
  missing=""
  for package in $dev_packages; do
    dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed' || missing="$missing $package"
  done
  if [ -n "$missing" ]; then
    if ! command -v apt-get >/dev/null 2>&1; then
      echo "Thiếu gói dev:$missing — máy không có apt, cài bằng trình quản lý gói của OS rồi chạy lại." >&2
      exit 1
    fi
    echo "==> Cài gói dev còn thiếu:$missing"
    sudo apt-get install -y $missing || { echo "Cài gói dev không xong." >&2; exit 1; }
  fi
fi

if [ ! -f "$repo/Cargo.toml" ] || [ ! -f "$root/materiant/Cargo.toml" ]; then
  echo "Thiếu fastcast hoặc materiant: chạy bash init.sh rồi chọn fastcast." >&2
  exit 1
fi

printf '\n==> %s, chip %s\n' "$triple" "$chip"
rustup target list --installed | grep -qx "$triple" || rustup target add "$triple"
out_name="$triple"
if [ "$chip" = avx2 ]; then
  export RUSTFLAGS="${RUSTFLAGS:-} -C target-cpu=x86-64-v3"
  out_name="$triple-avx2"
fi

# Luôn --target: RUSTFLAGS không lan sang build script, mỗi target một thư mục. Không feature `dev-env` (bản phát hành).
if [ -n "$force" ]; then
  (cd "$repo" && cargo clean --release --target "$triple" -p fastcast-core -p fastcast-capture -p fastcast-daemon \
    -p fastcast-ui -p fastcast-ocr -p fastcast-video -p materiant)
fi
# Build qua tools/cargo-prune.mjs: build xong dọn bản build cũ (cùng crate, hash khác) trong thư mục build vừa dùng.
(cd "$repo" && node "$root/tools/cargo-prune.mjs" build --release --locked --target "$triple" \
  -p fastcast-daemon -p fastcast-ui -p fastcast-ocr -p fastcast-video --bins)
target_dir="${CARGO_TARGET_DIR:-$repo/target}"
release="$target_dir/$triple/release"

exes="fst fastcast-ui fastcast-ocr fastcast-rec"
for exe in $exes; do
  if grep -aqE 'FASTCAST_(OCR_EXE|REC_EXE|REC_WINDOW|OCR_MODELS)' "$release/$exe"; then
    echo "$exe còn biến chạy thử" >&2
    exit 1
  fi
done
# Inspector (D-19) chỉ có ở bản debug: bản cài mà còn chuỗi của nó thì build sai profile.
if grep -a -q -e 'inspector-pick' -e 'Hover to highlight' "$release/fastcast-ui"; then
  echo "fastcast-ui còn inspector (bản debug?)" >&2
  exit 1
fi

out="$root/release/fastcast/$out_name"

# macOS phát hành bằng `.app` + `.dmg`, không để exe rời. Có đủ model thì ra bản đủ, thiếu thì bản `-draft` kèm cảnh báo.
if [ "$os" = macos ]; then
  package=(--skip-build --arch "$arch" --out "$out")
  models=""
  for dir in "$target_dir/release/models" "$target_dir/ocr-models"; do
    if [ -d "$dir/onnx" ] && [ "$arch" = "$host_arch" ]; then models="$dir"; break; fi
  done
  if [ -n "$models" ] && command -v pwsh >/dev/null 2>&1 && command -v cargo-about >/dev/null 2>&1; then
    package+=(--models "$models")
  else
    package+=(--draft)
    [ -z "$models" ] || package+=(--models "$models")
  fi
  bash "$repo/tools/build-macos.sh" "${package[@]}"
  exit 0
fi

# Linux phát hành bằng `.deb` (Ubuntu), cùng cách với macOS: đủ model + giấy phép thì bản đủ, thiếu thì `-draft` kèm cảnh báo.
if [ "$os" = linux ]; then
  package=(--skip-build --arch "$arch" --out "$out" --release-dir "$release")
  models=""
  if [ -d "$target_dir/release/models/onnx" ] && [ "$arch" = "$host_arch" ]; then models="$target_dir/release/models"; fi
  # Tự dựng nốt phần OCR: model đã giải nén (export-ocr) thì soát sổ + tải ONNX Runtime chính thức nếu thiếu (sha256 ghim
  # trong script); hỏng thì vẫn ra bản `-draft` thay vì dừng.
  if [ -n "$models" ] && [ "$arch" = x64 ]; then
    bash "$repo/tools/fetch-ocr-models.sh" --out "$models" || echo "⚠ Không dựng xong model OCR, gói sẽ là bản -draft." >&2
  fi
  # Trang giấy phép cần cargo-about: thiếu thì cài vào ~/.cargo (không sudo, vài phút lần đầu).
  if ! command -v cargo-about >/dev/null 2>&1; then
    echo "==> Cài cargo-about (trang giấy phép)"
    cargo install cargo-about --locked --features cli || echo "⚠ Cài cargo-about không xong." >&2
  fi
  [ -z "$models" ] || package+=(--models "$models")
  if [ -z "$models" ] || ! command -v cargo-about >/dev/null 2>&1 \
    || ! { command -v pwsh >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; }; then
    package+=(--draft)
  fi
  bash "$repo/tools/build-deb.sh" "${package[@]}"
  exit 0
fi

rm -rf "$out"
mkdir -p "$out"
for exe in $exes; do cp "$release/$exe" "$out/"; done

warnings=""
if command -v pwsh >/dev/null 2>&1 && command -v cargo-about >/dev/null 2>&1; then
  pwsh -NoProfile -File "$repo/tools/gen-licenses.ps1" -Out "$out/licenses"
else
  warnings="${warnings}⚠ Không có trang giấy phép (cần pwsh + cargo-about).
"
fi

# Model + thư viện ONNX Runtime đã dựng ở target/release/models. Thư viện theo kiến trúc: chỉ dùng đúng máy dựng ra nó.
if [ -d "$target_dir/release/models" ] && [ "$arch" = "$host_arch" ]; then
  cp -R "$target_dir/release/models" "$out/models"
else
  warnings="${warnings}⚠ Không kèm model: OCR chưa chạy được (dựng bằng fastcast/tools/fetch-ocr-models.ps1 vào target/release/models).
"
fi

printf '\nXong: %s\n%s' "$out" "$warnings"
