# Mở nhanh app của workspace để xem tay. Đứng ở gốc workspace:
#   pwsh start.ps1 docs                  gallery materiant (bản master), trang đầu
#   pwsh start.ps1 docs button           mở thẳng trang `button` (theme, style, button, input, toggles, scroll…)
#   pwsh start.ps1 docs button gd1_03    bản đang làm dở ở worktree .claude/worktrees/materiant-gd1_03 (kể cả code
#                                        chưa commit) — tên worktree bỏ tiền tố `materiant-`
#   pwsh start.ps1 launcher              launcher example của materiant (bản master; tham số 2 = worktree)
#   pwsh start.ps1 groove                Groove X (bản master)
#   pwsh start.ps1 fastcast [màn]        Fastcast bản debug (inspector: Ctrl+Shift+I, Ctrl+Shift+C) + daemon giả + cấu hình dev riêng;
#                                        màn = settings (mặc định) | launcher | overlay | ruler | picker (overlay trên màn giả)
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
# Build qua tools/cargo-prune.mjs: build xong dọn bản build cũ trong target/start (target/w<N> chỉ build, không dọn).
$prune = Join-Path $root 'tools\cargo-prune.mjs'

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
        $cargoArgs = @('--manifest-path', (Join-Path $dir 'Cargo.toml'), '-p', 'materiant', '--example', 'gallery')
        Write-Host "gallery từ $dir"
        & node $prune build @cargoArgs
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        if ($Page) { $cargoArgs += @('--', '--page', $Page) }
        & cargo run @cargoArgs
        exit $LASTEXITCODE
    }
    'launcher' {
        # `start.ps1 launcher <worktree>`: launcher không có trang nên worktree là tham số thứ hai.
        $wt = $Page -replace '^materiant-', ''
        $dir = Join-Path $root 'materiant'
        if ($wt) {
            $dir = Join-Path $worktrees "materiant-$wt"
            if (-not (Test-Path $dir)) {
                Write-Host "Không thấy worktree '$wt'. Đang mở:"
                Show-Worktrees
                exit 1
            }
        }
        $name = if ($wt) { $wt } else { 'start' }
        $env:CARGO_TARGET_DIR = Join-Path $root "materiant\target\$name"
        Write-Host "launcher từ $dir"
        & node $prune build --manifest-path (Join-Path $dir 'Cargo.toml') -p materiant --example launcher
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & cargo run --manifest-path (Join-Path $dir 'Cargo.toml') -p materiant --example launcher
        exit $LASTEXITCODE
    }
    'groove' {
        # Dữ liệu thật của máy, cửa sổ ở nơi OS hoặc vị trí đã lưu chọn: lệnh này để chủ dự án xem tay.
        $env:CARGO_TARGET_DIR = Join-Path $root 'groove\target\start'
        & node $prune build --manifest-path (Join-Path $root 'groove\Cargo.toml') -p groove-app
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & cargo run --manifest-path (Join-Path $root 'groove\Cargo.toml') -p groove-app
        exit $LASTEXITCODE
    }
    'fastcast' {
        # Bản debug có inspector, daemon giả (không phím tắt toàn cục, không khay), cấu hình dev riêng: không đụng Fastcast đã cài.
        $screens = [ordered]@{ settings = 'open_settings'; launcher = 'open_launcher'; overlay = 'capture_region'; ruler = 'ruler'; picker = 'color_picker' }
        $screen = if ($Page) { $Page } else { 'settings' }
        if (-not $screens.Contains($screen)) {
            Write-Host "Màn '$screen' không hợp lệ. Hợp lệ: $($screens.Keys -join ', ')"
            exit 1
        }
        $command = $screens[$screen]
        $pipe = '\\.\pipe\fastcast-dev'
        if ([System.IO.Directory]::GetFiles('\\.\pipe\') -contains $pipe) {
            Write-Host 'đã có fake_daemon dev đang chạy (session khác?)'
            exit 1
        }
        $target = Join-Path $root 'fastcast\target\start'
        $env:CARGO_TARGET_DIR = $target
        & node $prune build --manifest-path (Join-Path $root 'fastcast\Cargo.toml') -p fastcast-ui --bin fastcast-ui --example fake_daemon
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        # Cấu hình dev: lần đầu chép từ cấu hình thật (fastcast_core::paths::config_dir = %APPDATA%\fastcast trên Windows).
        $devConfig = Join-Path $target 'dev-config.json'
        $realConfig = Join-Path $env:APPDATA 'fastcast\config.json'
        if (-not (Test-Path $devConfig) -and (Test-Path $realConfig)) { Copy-Item $realConfig $devConfig }
        $env:FASTCAST_CONFIG_FILE = $devConfig
        Write-Host "cấu hình dev: $devConfig"
        if ($command -in 'capture_region', 'ruler', 'color_picker') { $env:FASTCAST_OVERLAY_FAKE = '1' }
        else { Remove-Item Env:FASTCAST_OVERLAY_FAKE -ErrorAction SilentlyContinue }

        Write-Host 'Gõ vào đây: open_launcher, capture_region, ruler, color_picker, open_settings…; quit hoặc Ctrl+C để thoát. Trong cửa sổ: Ctrl+Shift+I mở inspector, Ctrl+Shift+C chọn phần tử.'
        $fake = $null; $ui = $null; $code = 0
        try {
            # Không redirect: daemon thừa hưởng console nên đọc được stdin chủ dự án gõ.
            $fake = Start-Process (Join-Path $target 'debug\examples\fake_daemon.exe') -ArgumentList 'dev' -NoNewWindow -PassThru
            $deadline = [DateTime]::UtcNow.AddSeconds(10)
            while (-not ([System.IO.Directory]::GetFiles('\\.\pipe\') -contains $pipe)) {
                if ($fake.HasExited) { Write-Error 'fake_daemon thoát sớm'; exit 1 }
                if ([DateTime]::UtcNow -gt $deadline) { Write-Error 'fake_daemon không mở pipe sau 10 s'; exit 1 }
                Start-Sleep -Milliseconds 50
            }
            $ui = Start-Process (Join-Path $target 'debug\fastcast-ui.exe') -ArgumentList '--endpoint', 'dev', '--command', $command -NoNewWindow -PassThru
            # Vòng chờ (không WaitForExit) để Ctrl+C dừng được.
            while (-not $fake.HasExited) { Start-Sleep -Milliseconds 200 }
            $code = $fake.ExitCode
        } finally {
            # UI mất daemon mà còn cửa sổ thì chờ đóng cửa sổ cuối ⇒ phải giết.
            if ($ui -and -not $ui.HasExited) { Stop-Process -Id $ui.Id -Force -ErrorAction SilentlyContinue }
            if ($fake -and -not $fake.HasExited) { Stop-Process -Id $fake.Id -Force -ErrorAction SilentlyContinue }
        }
        exit ([int]$code)
    }
    'list' { Show-Worktrees }
    default {
        Get-Content $PSCommandPath -TotalCount 13 | ForEach-Object { $_ -replace '^# ?', '' }
    }
}
