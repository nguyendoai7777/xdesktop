# Mở nhanh app của workspace để xem tay. Đứng ở gốc workspace:
#   pwsh start.ps1 docs                  gallery materiant (bản master), trang đầu
#   pwsh start.ps1 docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   pwsh start.ps1 docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                        chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   pwsh start.ps1 list                  liệt kê worktree đang mở
# Master build ở materiant/target/start; worktree build ở materiant/target/<worktree> (thư mục của chính session đó —
# không build nguội lại, nhưng có thể chờ khoá khi session đang build). Không trộn: cargo dễ đưa ra exe của nguồn khác.
# Trong gallery: ↑ / ↓ đổi trang, Ctrl+T xoay Light / Dark / System.
param(
    [Parameter(Position = 0)] [string]$App = 'help',
    [Parameter(Position = 1)] [string]$Page = '',
    [Parameter(Position = 2)] [string]$Worktree = ''
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = $PSScriptRoot
$worktrees = Join-Path $root '.claude\worktrees'

function Show-Worktrees {
    $found = Get-ChildItem $worktrees -Directory -Filter 'materiant-*' -ErrorAction SilentlyContinue
    if (-not $found) { 'Không có worktree materiant nào đang mở.'; return }
    foreach ($d in $found) {
        $branch = git -C $d.FullName branch --show-current 2>$null
        "  {0,-14} {1}" -f ($d.Name -replace '^materiant-', ''), $branch
    }
}

switch ($App) {
    'docs' {
        $dir = Join-Path $root 'materiant'
        if ($Worktree) {
            $dir = Join-Path $worktrees "materiant-$($Worktree -replace '^materiant-', '')"
            if (-not (Test-Path $dir)) {
                Write-Host "Không thấy worktree '$Worktree'. Đang mở:"
                Show-Worktrees
                exit 1
            }
        }
        # Mỗi nguồn một thư mục build (cargo trộn worktree trong cùng target ⇒ dễ ra exe của nguồn khác).
        $name = if ($Worktree) { $Worktree -replace '^materiant-', '' } else { 'start' }
        $env:CARGO_TARGET_DIR = Join-Path $root "materiant\target\$name"
        $cargoArgs = @('run', '--manifest-path', (Join-Path $dir 'Cargo.toml'), '-p', 'materiant', '--example', 'gallery')
        if ($Page) { $cargoArgs += @('--', '--page', $Page) }
        Write-Host "gallery từ $dir"
        & cargo @cargoArgs
        exit $LASTEXITCODE
    }
    'list' { Show-Worktrees }
    default {
        Get-Content $PSCommandPath -TotalCount 9 | ForEach-Object { $_ -replace '^# ?', '' }
    }
}
