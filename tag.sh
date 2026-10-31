#!/usr/bin/env bash
# Hỏi project (space tích, enter xác nhận, chọn được nhiều) rồi nâng version, commit, đánh tag v<version> (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   bash tag.sh                 # không cờ = --patch
#   bash tag.sh -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   bash tag.sh --minor         # 0.1.0 → 0.2.0
#   bash tag.sh --major         # 0.1.0 → 1.0.0
#   bash tag.sh --current       # tag đúng version đang có, không nâng
#   bash tag.sh -p --push       # đẩy luôn commit + tag lên origin
#   bash tag.sh --project materiant --minor     # không hỏi project; nhiều project: --project fastcast,materiant
# Nâng materiant thì `Cargo.lock` của fastcast đổi theo (build dùng `--locked`), nên fastcast có thêm một commit.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

bump="" push="" projects=""
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
    --project) [ $# -ge 2 ] || { echo "Thiếu tên sau --project." >&2; exit 2; }; projects="$projects $(printf '%s' "$2" | tr ',' ' ')"; shift ;;
    *) echo "Không hiểu tham số: $1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$bump" ] || bump=patch

if [ -z "$projects" ] && [ -t 0 ]; then
  select_checklist 'Đánh tag cho project nào:' 'fastcast|fastcast' 'materiant|materiant'
  projects="$selected"
fi
if [ -z "$projects" ]; then
  # Stdin là pipe: không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
  echo 'Đánh tag cho project nào:'
  echo '  [1] fastcast  (Enter)'
  echo '  [2] materiant'
  while [ -z "$projects" ]; do
    printf 'Chọn (nhiều project thì cách bằng dấu phẩy): '
    read -r answer || answer=""
    [ -n "$answer" ] || answer=1
    for pick in $(printf '%s' "$answer" | tr ',' ' '); do
      case "$pick" in
        1) projects="$projects fastcast" ;;
        2) projects="$projects materiant" ;;
        *) echo 'Nhập 1, 2 hoặc 1,2.'; projects=""; break ;;
      esac
    done
  done
fi

# materiant trước: fastcast có commit cập nhật lock thì tag của fastcast chứa luôn commit đó.
order=""
for name in materiant fastcast; do
  case " $projects " in *" $name "*) order="$order $name" ;; esac
done
for name in $projects; do
  case "$name" in
    fastcast|materiant) ;;
    *) echo "Project không hợp lệ: $name" >&2; exit 2 ;;
  esac
done

next_version() { # <version hiện tại> ⇒ in version mới
  [[ "$1" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || return 1
  local major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" patch="${BASH_REMATCH[3]}"
  case "$bump" in
    patch) patch=$((patch + 1)) ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    major) major=$((major + 1)); minor=0; patch=0 ;;
  esac
  echo "$major.$minor.$patch"
}

read_version() { sed -n 's/^version = "\(.*\)"$/\1/p' "$root/$1/Cargo.toml" | head -1; }

# Soát hết trước khi đụng gì: một project hỏng thì không project nào đổi.
for name in $order; do
  repo="$root/$name"
  [ -d "$repo/.git" ] || { echo "Chưa có $name: chạy bash init.sh." >&2; exit 1; }
  [ -z "$(git -C "$repo" status --porcelain)" ] || { echo "$name còn thay đổi chưa commit, tag sẽ không khớp code." >&2; exit 1; }
  branch="$(git -C "$repo" branch --show-current)"
  [ "$branch" = master ] || { echo "$name đang ở nhánh '$branch', chỉ tag trên master." >&2; exit 1; }
  version="$(read_version "$name")"
  next="$(next_version "$version")" || { echo "Version lạ trong $name/Cargo.toml: '$version'" >&2; exit 1; }
  [ -z "$(git -C "$repo" tag --list "v$next")" ] || { echo "Tag v$next của $name đã có." >&2; exit 1; }
done

lock_synced=""
pushes=""
for name in $order; do
  repo="$root/$name"
  version="$(read_version "$name")"
  next="$(next_version "$version")"
  tag="v$next"
  if [ "$bump" != current ]; then
    # Chỉ dòng version đầu tiên: của gói / [workspace.package], không đụng dòng version của phụ thuộc.
    tmp="$(mktemp)"
    awk -v next_version="$next" '!done && /^version = "/ { print "version = \"" next_version "\""; done = 1; next } { print }' \
      "$repo/Cargo.toml" > "$tmp"
    cat "$tmp" > "$repo/Cargo.toml"
    rm -f "$tmp"
    (cd "$repo" && cargo update --workspace --offline --quiet)
    git -C "$repo" commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock
    # fastcast build bằng `--locked`, ghi cả version của materiant trong lock.
    if [ "$name" = materiant ] && [ -d "$root/fastcast/.git" ]; then
      git -C "$root/fastcast" diff --quiet -- Cargo.lock || { echo "fastcast/Cargo.lock đang có sửa dở, chưa cập nhật materiant." >&2; exit 1; }
      (cd "$root/fastcast" && cargo update -p materiant --offline --quiet)
      if ! git -C "$root/fastcast" diff --quiet -- Cargo.lock; then
        git -C "$root/fastcast" commit --quiet -m "deps: materiant $tag" -- Cargo.lock
        lock_synced=1
      fi
    fi
  fi
  git -C "$repo" tag -a "$tag" -m "$tag"
  echo "$name: $version → $next, tag $tag ở $(git -C "$repo" rev-parse --short HEAD)"
  pushes="$pushes$name $tag"$'\n'
done
# fastcast chỉ có commit cập nhật lock, không có tag mới.
case " $order " in *" fastcast "*) ;; *) [ -z "$lock_synced" ] || pushes="${pushes}fastcast"$'\n' ;; esac

while read -r name tag; do
  [ -n "$name" ] || continue
  if [ -n "$push" ]; then
    git -C "$root/$name" push --quiet origin master $tag
    echo "Đã đẩy $name lên origin."
  else
    echo "Chưa đẩy. Đẩy lên: git -C $name push origin master${tag:+ $tag}"
  fi
done <<< "$pushes"
