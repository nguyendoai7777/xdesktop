#!/usr/bin/env bash
# Xoá phần build sinh ra, không đụng mã. Giữ `fastcast/target/release/models` (dựng lại phải chạy Docker) và cache build release
# (`--all` xoá luôn), thư mục build của worktree cố định `target/w<N>` (D-18; `--all` xoá luôn). Tệp đang bị tiến trình giữ
# thì báo rồi đi tiếp.
set -u
root="$(cd "$(dirname "$0")" && pwd)"
all=false
[ "${1:-}" = "--all" ] && all=true
for repo in fastcast materiant groove; do
  target="$root/$repo/target"
  [ -d "$target" ] || continue
  for dir in "$target"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    if [[ "$name" == w[0-9]* ]] && [ "$all" = false ]; then
      echo "giữ build của worktree cố định: $repo/target/$name"
    elif [ "$repo" = fastcast ] && [ "$name" = release ]; then
      find "$dir" -mindepth 1 -maxdepth 1 ! -name models -exec rm -rf {} +
    elif [ "$repo" = fastcast ] && [ "$name" != debug ] && [ "$all" = false ] && [ -d "$dir/release" ]; then
      echo "giữ cache build release: $repo/target/$name"
    else
      rm -rf "$dir" || echo "chưa xoá được: $dir"
    fi
  done
done
# Thư mục tạm của cargo (`.cargo/config.toml` đặt TMP / TEMP vào đây thay cho %TEMP%): xoá hết trừ `.gitignore`, cả trong
# worktree cố định — tệp tạm không phải cache, không cần giữ.
for tmp in "$root"/*/.cargo/tmp "$root"/.claude/worktrees/*/.cargo/tmp; do
  [ -d "$tmp" ] && find "$tmp" -mindepth 1 -maxdepth 1 ! -name .gitignore -exec rm -rf {} + 2>/dev/null
done
# KHÔNG đụng `groove/src-tauri/target`: `x86_64-pc-windows-msvc/release/groovex.exe` là bản Tauri để đối soát.
# Thư mục build tạm của worktree trên Windows (ổ ngoài repo).
[ -d /c/xdesktop-target ] && find /c/xdesktop-target -mindepth 1 -maxdepth 1 -exec rm -rf {} +
du -sh "$root/fastcast/target" "$root/materiant/target" "$root/groove/target" 2>/dev/null
