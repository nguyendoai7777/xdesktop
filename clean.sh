#!/usr/bin/env bash
# Xoá phần build sinh ra, không đụng mã. Giữ `fastcast/target/release/models` (dựng lại phải chạy Docker) và cache build release
# (`--all` xoá luôn). Tệp đang bị tiến trình giữ thì báo rồi đi tiếp.
set -u
root="$(cd "$(dirname "$0")" && pwd)"
all=false
[ "${1:-}" = "--all" ] && all=true
for repo in fastcast materiant; do
  target="$root/$repo/target"
  [ -d "$target" ] || continue
  for dir in "$target"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    if [ "$repo" = fastcast ] && [ "$name" = release ]; then
      find "$dir" -mindepth 1 -maxdepth 1 ! -name models -exec rm -rf {} +
    elif [ "$repo" = fastcast ] && [ "$name" != debug ] && [ "$all" = false ] && [ -d "$dir/release" ]; then
      echo "giữ cache build release: $repo/target/$name"
    else
      rm -rf "$dir" || echo "chưa xoá được: $dir"
    fi
  done
done
# Thư mục build tạm của worktree trên Windows (ổ ngoài repo).
[ -d /c/xdesktop-target ] && find /c/xdesktop-target -mindepth 1 -maxdepth 1 -exec rm -rf {} +
du -sh "$root/fastcast/target" "$root/materiant/target" 2>/dev/null
