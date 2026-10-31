#!/usr/bin/env bash
# Đánh tag v<version> cho commit hiện tại của fastcast (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   bash tag.sh                 # tag đúng version đang có
#   bash tag.sh -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   bash tag.sh --minor         # 0.1.0 → 0.2.0
#   bash tag.sh --major         # 0.1.0 → 1.0.0
#   bash tag.sh -p --push       # đẩy luôn commit + tag lên origin
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$root/fastcast"

bump="" push=""
set_bump() {
  [ -z "$bump" ] || { echo "Chỉ chọn một trong -p, --minor, --major." >&2; exit 2; }
  bump="$1"
}
while [ $# -gt 0 ]; do
  case "$1" in
    -p|--patch) set_bump patch ;;
    --minor) set_bump minor ;;
    --major) set_bump major ;;
    --push) push=1 ;;
    *) echo "Không hiểu tham số: $1" >&2; exit 2 ;;
  esac
  shift
done

git -C "$repo" rev-parse --git-dir >/dev/null
[ -z "$(git -C "$repo" status --porcelain)" ] || { echo "fastcast còn thay đổi chưa commit, tag sẽ không khớp code." >&2; exit 1; }
branch="$(git -C "$repo" branch --show-current)"
[ "$branch" = master ] || { echo "fastcast đang ở nhánh '$branch', chỉ tag trên master." >&2; exit 1; }

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

if [ -n "$bump" ]; then
  # Chỉ dòng version đầu tiên: của [workspace.package], không đụng dòng version của phụ thuộc.
  tmp="$(mktemp)"
  awk -v next_version="$next" '!done && /^version = "/ { print "version = \"" next_version "\""; done = 1; next } { print }' \
    "$repo/Cargo.toml" > "$tmp"
  cat "$tmp" > "$repo/Cargo.toml"
  rm -f "$tmp"
  (cd "$repo" && cargo update --workspace --offline --quiet)
  git -C "$repo" commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock
fi
git -C "$repo" tag -a "$tag" -m "$tag"
echo "$version → $next, tag $tag ở $(git -C "$repo" rev-parse --short HEAD)"

if [ -n "$push" ]; then
  git -C "$repo" push --quiet origin master "$tag"
  echo "Đã đẩy master + $tag lên origin."
else
  echo "Chưa đẩy. Đẩy lên: git -C fastcast push origin master $tag"
fi
