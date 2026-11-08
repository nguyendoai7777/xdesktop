#!/usr/bin/env bash
# Build bản release — chỉ hỏi / định tuyến; việc thật nằm ở `<repo>/build.sh` của từng project. Hỏi project (Fastcast / Groovex /
# materiant docs) rồi gọi sang script của nó; fastcast hỏi tiếp OS → kiến trúc → chip (Enter = máy đang chạy) → plan
# (Free / Pro). Đứng ở gốc workspace:
#   bash build.sh
#   bash build.sh --project fastcast --os linux --arch x64 --chip intel-amd      # không hỏi (có cờ OS / kiến trúc / chip ⇒ fastcast)
#   bash build.sh -f                                          # --force: biên dịch lại mã của ta, giữ thư viện đã build
#   bash build.sh --pro                                       # = --plan=pro: fastcast mở sẵn Pro để nghiệm thu (D-23), tên có `_pro`
# Mọi cờ khác --project chuyển nguyên sang `<repo>/build.sh` (xem đầu tệp đó). Ra release/<app>/<app>_<version>_<os>_<arch>
# [_avx2][_pro][_draft].<đuôi> (vd. fastcast_0.1.4_linux_amd64.deb; macOS kèm Fastcast.app); materiant ra
# release/materiant/materiant-docs. Chỉ build được cho OS đang chạy. Git Bash trên Windows: script của project đá sang build.ps1.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$root/tools/script-lib.sh"

project="" fastcast_only="" forward=()
while [ $# -gt 0 ]; do
  case "$1" in
    --project) project="${2:-}"; shift 2 || { echo "--project cần giá trị: fastcast, groove, materiant" >&2; exit 1; } ;;
    --project=*) project="${1#--project=}"; shift ;;
    # --os / --arch / --chip / plan chỉ có ở fastcast: có cờ đó thì khỏi hỏi project.
    --os|--arch|--chip|--plan) fastcast_only=1; forward+=("$1" "${2:-}"); shift 2 || shift ;;
    --pro|--free|--plan=*) fastcast_only=1; forward+=("$1"); shift ;;
    *) forward+=("$1"); shift ;;
  esac
done

if [ -z "$project" ]; then
  if [ -n "$fastcast_only" ]; then project=fastcast
  else xd_select 'Build project nào:' 1 'fastcast|Fastcast' 'groove|Groovex' 'materiant|materiant (docs only)'; project="$picked"; fi
fi
case "$project" in
  fastcast|groove|materiant) ;;
  *) echo "--project: fastcast, groove hoặc materiant" >&2; exit 1 ;;
esac
script="$root/$project/build.sh"
[ -f "$script" ] || { echo "Thiếu $project (hoặc $project/build.sh): chạy bash init.sh rồi chọn $project." >&2; exit 1; }
exec bash "$script" ${forward[@]+"${forward[@]}"}
