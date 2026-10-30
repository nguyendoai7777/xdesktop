#!/usr/bin/env bash
# Build bản release của fastcast. Hỏi OS → kiến trúc → chip rồi build (Enter = máy đang chạy). Đứng ở gốc workspace:
#   bash build.sh
#   bash build.sh --os linux --arch x64 --chip intel-amd      # không hỏi
# Ra fastcast/dist/<target>[-avx2]/ (bốn exe, models, licenses — chạy `fst`). Chỉ build được cho OS đang chạy: thiếu SDK
# để link chéo OS. Git Bash trên Windows ⇒ đá sang build.ps1.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$root/fastcast"

os="" arch="" chip=""
while [ $# -gt 0 ]; do
  case "$1" in
    --os) os="$2"; shift 2 ;;
    --arch) arch="$2"; shift 2 ;;
    --chip) chip="$2"; shift 2 ;;
    *) echo "Không hiểu tham số: $1" >&2; exit 1 ;;
  esac
done

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    forward=()
    [ -n "$os" ] && forward+=(-Os "$os")
    [ -n "$arch" ] && forward+=(-Arch "$arch")
    [ -n "$chip" ] && forward+=(-Chip "$chip")
    exec pwsh -NoProfile -File "$(cygpath -w "$root/build.ps1")" ${forward[@]+"${forward[@]}"} ;;
  Darwin) host_os=macos ;;
  *) host_os=linux ;;
esac
case "$(uname -m)" in
  arm64|aarch64) host_arch=arm64 ;;
  *) host_arch=x64 ;;
esac

# select_option <tiêu đề> <số thứ tự mặc định> <id|nhãn>… ⇒ gán $picked. Hết stdin thì lấy mặc định.
select_option() {
  local title="$1" default="$2" answer i=1 item
  shift 2
  if [ $# -eq 1 ]; then echo "$title ${1#*|}"; picked="${1%%|*}"; return; fi
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
(cd "$repo" && cargo build --release --locked --target "$triple" \
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

out="$repo/dist/$out_name"
rm -rf "$out"
mkdir -p "$out"
for exe in $exes; do cp "$release/$exe" "$out/"; done

warnings=""
if command -v pwsh >/dev/null 2>&1 && command -v cargo-about >/dev/null 2>&1; then
  pwsh -NoProfile -File "$repo/tools/gen-licenses.ps1" -Out "$out/licenses"
else
  warnings="$warnings⚠ Không có trang giấy phép (cần pwsh + cargo-about).
"
fi

# Model + thư viện ONNX Runtime đã dựng ở target/release/models. Thư viện theo kiến trúc: chỉ dùng đúng máy dựng ra nó.
if [ -d "$target_dir/release/models" ] && [ "$arch" = "$host_arch" ]; then
  cp -R "$target_dir/release/models" "$out/models"
else
  warnings="$warnings⚠ Không kèm model: OCR chưa chạy được (dựng bằng fastcast/tools/fetch-ocr-models.ps1 vào target/release/models).
"
fi

printf '\nXong: %s\n%s' "$out" "$warnings"
