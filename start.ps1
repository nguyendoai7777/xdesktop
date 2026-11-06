# Lớp bọc cho Windows PowerShell: mọi logic nằm ở start.sh (một mã cho mọi OS) — script này chỉ tìm Git Bash rồi chuyển
# nguyên đối số sang; start.sh lại chỉ định tuyến sang `<repo>/start.sh`. Cách dùng: đầu start.sh hoặc `pwsh start.ps1 help`.
#   pwsh start.ps1 [docs [trang] [worktree] | launcher [worktree] | groove | fastcast [màn] [--plan=<plan>] | list]
# Không gọi `bash` trần: trên Windows nó thường là WSL (system32\bash.exe), không có Rust / Node / cấu hình của máy.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { Write-Error 'Không thấy git (Git for Windows) — cần Git Bash để chạy start.sh.' }
# git.exe ở <Git>\cmd\, <Git>\bin\ hoặc <Git>\mingw64\bin\ ⇒ đi ngược lên tới thư mục có bin\bash.exe.
$gitBash = $null
$dir = Split-Path $git.Source
while ($dir -and -not $gitBash) {
    $candidate = Join-Path $dir 'bin\bash.exe'
    if (Test-Path -LiteralPath $candidate) { $gitBash = $candidate }
    $dir = Split-Path $dir
}
if (-not $gitBash) { Write-Error "Không thấy Git Bash (bin\bash.exe) quanh $($git.Source)" }

& $gitBash (Join-Path $PSScriptRoot 'start.sh') @args
exit $LASTEXITCODE
