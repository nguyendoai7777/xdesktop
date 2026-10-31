#!/usr/bin/env bash
# Hỏi project rồi nâng version, commit, đánh tag v<version> (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   bash tag.sh                 # không cờ = --patch
#   bash tag.sh -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   bash tag.sh --minor         # 0.1.0 → 0.2.0
#   bash tag.sh --major         # 0.1.0 → 1.0.0
#   bash tag.sh --current       # tag đúng version đang có, không nâng
#   bash tag.sh -p --push       # đẩy luôn commit + tag lên origin
#   bash tag.sh --project materiant --minor     # không hỏi project
# Nâng materiant thì `Cargo.lock` của fastcast đổi theo (build dùng `--locked`), nên fastcast có thêm một commit.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# select_option <tiêu đề> <số thứ tự mặc định> <id|nhãn>… ⇒ gán $picked. ↑ ↓ di chuyển, Enter chọn; vẽ lại tại chỗ bằng mã
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
          printf '\r\033[2K\033[36m> %s\033[0m\n' "${items[i]#*|}"
        else
          printf '\r\033[2K  %s\n' "${items[i]#*|}"
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

bump="" push="" project=""
set_bump() {
  [ -z "$bump" ] || { echo "Chỉ chọn một trong -p, --minor, --major, --current." >&2; exit 2; }
  bump="$1"
}
while [ $# -gt 0 ]; do
  case "$1" in
    -p|--patch) set_bump patch ;;
    --minor) set_bump minor ;;
    --major) set_bump major ;;
    --current) set_bump current ;;
    --push) push=1 ;;
    --project) [ $# -ge 2 ] || { echo "Thiếu tên sau --project." >&2; exit 2; }; project="$2"; shift ;;
    *) echo "Không hiểu tham số: $1" >&2; exit 2 ;;
  esac
  shift
done

[ -n "$bump" ] || bump=patch

if [ -z "$project" ]; then
  select_option 'Đánh tag cho project nào:' 1 'fastcast|fastcast' 'materiant|materiant'
  project="$picked"
fi
case "$project" in
  fastcast|materiant) ;;
  *) echo "Project không hợp lệ: $project" >&2; exit 2 ;;
esac
repo="$root/$project"
[ -d "$repo/.git" ] || { echo "Chưa có $project: chạy bash init.sh." >&2; exit 1; }

git -C "$repo" rev-parse --git-dir >/dev/null
[ -z "$(git -C "$repo" status --porcelain)" ] || { echo "$project còn thay đổi chưa commit, tag sẽ không khớp code." >&2; exit 1; }
branch="$(git -C "$repo" branch --show-current)"
[ "$branch" = master ] || { echo "$project đang ở nhánh '$branch', chỉ tag trên master." >&2; exit 1; }

version="$(sed -n 's/^version = "\(.*\)"$/\1/p' "$repo/Cargo.toml" | head -1)"
[[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || { echo "Version lạ trong Cargo.toml: '$version'" >&2; exit 1; }
major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" patch="${BASH_REMATCH[3]}"
case "$bump" in
  patch) patch=$((patch + 1)) ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  major) major=$((major + 1)); minor=0; patch=0 ;;
esac
next="$major.$minor.$patch"
tag="v$next"
[ -z "$(git -C "$repo" tag --list "$tag")" ] || { echo "Tag $tag đã có." >&2; exit 1; }

if [ "$bump" != current ]; then
  # Chỉ dòng version đầu tiên: của [workspace.package], không đụng dòng version của phụ thuộc.
  tmp="$(mktemp)"
  awk -v next_version="$next" '!done && /^version = "/ { print "version = \"" next_version "\""; done = 1; next } { print }' \
    "$repo/Cargo.toml" > "$tmp"
  cat "$tmp" > "$repo/Cargo.toml"
  rm -f "$tmp"
  (cd "$repo" && cargo update --workspace --offline --quiet)
  git -C "$repo" commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock
  # fastcast build bằng `--locked`, ghi cả version của materiant trong lock.
  if [ "$project" = materiant ] && [ -d "$root/fastcast/.git" ]; then
    git -C "$root/fastcast" diff --quiet -- Cargo.lock || { echo "fastcast/Cargo.lock đang có sửa dở, chưa cập nhật materiant." >&2; exit 1; }
    (cd "$root/fastcast" && cargo update -p materiant --offline --quiet)
    if ! git -C "$root/fastcast" diff --quiet -- Cargo.lock; then
      git -C "$root/fastcast" commit --quiet -m "deps: materiant $tag" -- Cargo.lock
      lock_synced=1
    fi
  fi
fi
git -C "$repo" tag -a "$tag" -m "$tag"
echo "$project: $version → $next, tag $tag ở $(git -C "$repo" rev-parse --short HEAD)"

if [ -n "$push" ]; then
  git -C "$repo" push --quiet origin master "$tag"
  [ -z "${lock_synced:-}" ] || git -C "$root/fastcast" push --quiet origin master
  echo "Đã đẩy master + $tag của $project lên origin${lock_synced:+, cả master của fastcast}."
else
  echo "Chưa đẩy. Đẩy lên: git -C $project push origin master $tag"
  [ -z "${lock_synced:-}" ] || echo "fastcast có commit cập nhật lock: git -C fastcast push origin master"
fi
