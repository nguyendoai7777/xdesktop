#!/usr/bin/env bash
# Nén model OCR để chép sang máy khác (model không nằm trong git): ra release/fastcast/fastcast-ocr-models.tar.gz + .sha256.
# Chỉ lấy model, sổ và giấy phép; bỏ thư viện ONNX Runtime vì nó theo OS (.dll / .dylib / .so).
#   bash export-ocr.sh [thư mục model]      # mặc định fastcast/target/release/models
# Máy nhận: mkdir -p fastcast/target/release/models && tar -xzf fastcast-ocr-models.tar.gz -C fastcast/target/release/models
set -eu
root="$(cd "$(dirname "$0")" && pwd)"
src="${1:-$root/fastcast/target/release/models}"
out="$root/release/fastcast"
name=fastcast-ocr-models.tar.gz

[ -f "$src/manifest.toml" ] && [ -d "$src/onnx" ] || {
  echo "không thấy model ở $src (cần manifest.toml + onnx/); dựng bằng fastcast/tools/fetch-ocr-models.ps1" >&2
  exit 1
}

if command -v sha256sum >/dev/null 2>&1; then sha() { sha256sum "$1" | cut -d' ' -f1; }
else sha() { shasum -a 256 "$1" | cut -d' ' -f1; }; fi

# Soát từng tệp model theo sổ trước khi nén: nén nhầm tệp hỏng thì máy kia mới phát hiện.
listed=0
while read -r path want; do
  [ -f "$src/$path" ] || { echo "thiếu theo sổ: $path" >&2; exit 1; }
  [ "$(sha "$src/$path")" = "$want" ] || { echo "sai sha256 theo sổ: $path" >&2; exit 1; }
  listed=$((listed + 1))
done < <(sed -nE 's/^[[:space:]]*\{[[:space:]]*path[[:space:]]*=[[:space:]]*"(onnx\/[^"]+)",[[:space:]]*sha256[[:space:]]*=[[:space:]]*"([0-9a-f]{64})".*/\1 \2/p' "$src/manifest.toml")
[ "$listed" -gt 0 ] || { echo "sổ không liệt kê tệp model nào: $src/manifest.toml" >&2; exit 1; }
echo "models: $listed tệp khớp sổ"

parts=(manifest.toml onnx)
[ -d "$src/onnxruntime-licenses" ] && parts+=(onnxruntime-licenses)
mkdir -p "$out"
tar -czf "$out/$name" -C "$src" "${parts[@]}"
(cd "$out" && echo "$(sha "$name")  $name" > "$name.sha256")

echo "Xong: $out/$name ($(du -h "$out/$name" | cut -f1))"
cat "$out/$name.sha256"
