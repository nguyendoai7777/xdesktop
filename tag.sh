#!/usr/bin/env bash
# Hỏi project (space tích, enter xác nhận, chọn được nhiều) rồi nâng version, commit, đánh tag v<version> (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   bash tag.sh                 # không cờ = --patch
#   bash tag.sh -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   bash tag.sh --minor         # 0.1.0 → 0.2.0
#   bash tag.sh --major         # 0.1.0 → 1.0.0
#   bash tag.sh --current       # tag đúng version đang có, không nâng
#   bash tag.sh -p --push       # đẩy luôn commit + tag lên origin
#   bash tag.sh --project materiant --minor     # không hỏi project; nhiều project: --project fastcast,materiant
# Nâng materiant thì `Cargo.lock` của fastcast / groove đổi theo (build dùng `--locked`), nên app có thêm một commit.
# Release note (D-22, khuôn `docs/release-notes.md`): mỗi tag cần `<repo>/release-notes/v<version>.md`. Thiếu thì script tạo khung
# rồi dừng; điền xong (xoá dòng `<!-- release-note: … -->`) chạy lại. Tệp đi kèm commit nâng version và làm nội dung tag.
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
  select_checklist 'Đánh tag cho project nào:' 'fastcast|fastcast' 'groove|Groovex (groove)' 'materiant|materiant'
  projects="$selected"
fi
if [ -z "$projects" ]; then
  # Stdin là pipe: không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
  echo 'Đánh tag cho project nào:'
  echo '  [1] fastcast  (Enter)'
  echo '  [2] materiant'
  echo '  [3] groove'
  while [ -z "$projects" ]; do
    printf 'Chọn (nhiều project thì cách bằng dấu phẩy): '
    read -r answer || answer=""
    [ -n "$answer" ] || answer=1
    for pick in $(printf '%s' "$answer" | tr ',' ' '); do
      case "$pick" in
        1) projects="$projects fastcast" ;;
        2) projects="$projects materiant" ;;
        3) projects="$projects groove" ;;
        *) echo 'Nhập 1, 2, 3 hoặc vd 1,2.'; projects=""; break ;;
      esac
    done
  done
fi

# materiant trước: app có commit cập nhật lock thì tag của app chứa luôn commit đó.
order=""
for name in materiant fastcast groove; do
  case " $projects " in *" $name "*) order="$order $name" ;; esac
done
for name in $projects; do
  case "$name" in
    fastcast|materiant|groove) ;;
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

notes_marker='<!-- release-note: điền xong thì xoá dòng này -->'
# notes_file <repo> <version> ⇒ đường dẫn tệp release note của tag đó.
notes_file() { echo "$root/$1/release-notes/v$2.md"; }
# write_notes_stub <name> <version>: khung theo `docs/release-notes.md`.
write_notes_stub() {
  local file
  file="$(notes_file "$1" "$2")"
  mkdir -p "$(dirname "$file")"
  cat > "$file" <<NOTES
# $1 v$2 ($(date +%Y-%m-%d))

$notes_marker

## Mới

- 

## Sửa lỗi

- 

## Thay đổi khác

- 
NOTES
}

read_version() { sed -n 's/^version = "\(.*\)"$/\1/p' "$root/$1/Cargo.toml" | head -1; }

# Soát hết trước khi đụng gì: một project hỏng thì không project nào đổi.
notes_missing=""
for name in $order; do
  repo="$root/$name"
  [ -d "$repo/.git" ] || { echo "Chưa có $name: chạy bash init.sh." >&2; exit 1; }
  version="$(read_version "$name")"
  next="$(next_version "$version")" || { echo "Version lạ trong $name/Cargo.toml: '$version'" >&2; exit 1; }
  # Tệp release note của tag này được phép đang sửa / chưa commit: nó đi cùng commit nâng version.
  dirty="$(git -C "$repo" status --porcelain --untracked-files=all | grep -v " release-notes/v$next.md$" || true)"
  [ -z "$dirty" ] || { echo "$name còn thay đổi chưa commit, tag sẽ không khớp code." >&2; exit 1; }
  branch="$(git -C "$repo" branch --show-current)"
  [ "$branch" = master ] || { echo "$name đang ở nhánh '$branch', chỉ tag trên master." >&2; exit 1; }
  [ -z "$(git -C "$repo" tag --list "v$next")" ] || { echo "Tag v$next của $name đã có." >&2; exit 1; }
  notes="$(notes_file "$name" "$next")"
  if [ ! -f "$notes" ]; then
    write_notes_stub "$name" "$next"
    echo "Chưa có release note: đã tạo khung $name/release-notes/v$next.md — điền rồi chạy lại." >&2
    notes_missing=1
  elif grep -qF "$notes_marker" "$notes"; then
    echo "$name/release-notes/v$next.md còn dòng mẫu: điền xong thì xoá dòng '$notes_marker'." >&2
    notes_missing=1
  fi
done
[ -z "$notes_missing" ] || exit 1

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
    git -C "$repo" add -- "release-notes/$tag.md"
    git -C "$repo" commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock "release-notes/$tag.md"
    # App build bằng `--locked`, ghi cả version của materiant trong lock.
    if [ "$name" = materiant ]; then
      for app in fastcast groove; do
        [ -d "$root/$app/.git" ] || continue
        git -C "$root/$app" diff --quiet -- Cargo.lock || { echo "$app/Cargo.lock đang có sửa dở, chưa cập nhật materiant." >&2; exit 1; }
        (cd "$root/$app" && cargo update -p materiant --offline --quiet)
        if ! git -C "$root/$app" diff --quiet -- Cargo.lock; then
          git -C "$root/$app" commit --quiet -m "deps: materiant $tag" -- Cargo.lock
          lock_synced="$lock_synced $app"
        fi
      done
    fi
  elif [ -n "$(git -C "$repo" status --porcelain -- "release-notes/$tag.md")" ]; then
    git -C "$repo" add -- "release-notes/$tag.md"
    git -C "$repo" commit --quiet -m "release notes: $tag" -- "release-notes/$tag.md"
  fi
  # Nội dung tag = release note (changelog); `verbatim` giữ dòng `#` của markdown.
  git -C "$repo" tag -a "$tag" --cleanup=verbatim -F "$(notes_file "$name" "$next")"
  echo "$name: $version → $next, tag $tag ở $(git -C "$repo" rev-parse --short HEAD)"
  pushes="$pushes$name $tag"$'\n'
done
# App chỉ có commit cập nhật lock, không có tag mới.
for app in $lock_synced; do
  case " $order " in *" $app "*) ;; *) pushes="${pushes}$app"$'\n' ;; esac
done

while read -r name tag; do
  [ -n "$name" ] || continue
  if [ -n "$push" ]; then
    git -C "$root/$name" push --quiet origin master $tag
    echo "Đã đẩy $name lên origin."
  else
    echo "Chưa đẩy. Đẩy lên: git -C $name push origin master${tag:+ $tag}"
  fi
done <<< "$pushes"
