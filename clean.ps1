# Dọn phần build sinh ra: xem clean.sh. `-All` xoá luôn cache build release. Windows chạy qua Git Bash.
param([switch]$All)
$bash = Join-Path (Split-Path (Split-Path (Get-Command git).Source)) 'bin/bash.exe'
& $bash (Join-Path $PSScriptRoot 'clean.sh') $(if ($All) { '--all' })
