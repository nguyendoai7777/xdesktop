# Dựng máy mới cho workspace xdesktop (Windows). Idempotent — chạy lại lúc nào cũng được.
#   pwsh init.ps1                    hỏi init project nào
#   pwsh init.ps1 -Project fastcast  không hỏi
# 1. Nối memory của Claude trên máy này vào .claude/memory (track trong git) bằng junction.
# 2. Clone repo của project được chọn (bảng $repos, $projects); repo đã có thì giữ nguyên, không pull.
# 3. Soát công cụ.
param([ValidateSet('fastcast', 'materiant', 'groove', 'cloud', 'ferry')] [string[]] $Project)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = $PSScriptRoot

# --- 1. Memory -------------------------------------------------------------------------------------------------
# Claude Code đặt tên thư mục project bằng đường dẫn tuyệt đối, mọi ký tự không phải chữ / số thành '-'
# (E:\codex\xdesktop ⇒ E--codex-xdesktop).
$slug = $root -replace '[^A-Za-z0-9]', '-'
$machineDir = Join-Path $HOME ".claude\projects\$slug\memory"
$shared = Join-Path $root '.claude\memory'
New-Item -ItemType Directory -Force $shared | Out-Null

$item = Get-Item $machineDir -Force -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq 'Junction') {
    if ((Resolve-Path $item.Target).Path -ne (Resolve-Path $shared).Path) {
        Write-Warning "memory: $machineDir đang nối tới $($item.Target), không phải $shared — gỡ junction đó rồi chạy lại."
    } else {
        Write-Host "✓ memory: đã nối $machineDir → $shared"
    }
} else {
    if ($item) {
        # Thư mục thật: dời tệp sang bộ dùng chung. Trùng tên mà khác nội dung ⇒ giữ cả hai, tệp của máy này thêm hậu tố.
        foreach ($f in Get-ChildItem $machineDir -File -Force) {
            $dest = Join-Path $shared $f.Name
            if (-not (Test-Path $dest)) {
                Move-Item $f.FullName $dest
            } elseif ((Get-FileHash $f.FullName).Hash -eq (Get-FileHash $dest).Hash) {
                Remove-Item $f.FullName
            } else {
                $alt = Join-Path $shared ("{0}.{1}{2}" -f $f.BaseName, $env:COMPUTERNAME.ToLower(), $f.Extension)
                Move-Item $f.FullName $alt
                Write-Warning "memory: $($f.Name) khác bản dùng chung — đã giữ thành $(Split-Path $alt -Leaf), gộp tay."
            }
        }
        if (Get-ChildItem $machineDir -Force) {
            throw "memory: $machineDir còn thư mục con, không tự xoá — dọn tay rồi chạy lại."
        }
        Remove-Item $machineDir
    } else {
        New-Item -ItemType Directory -Force (Split-Path $machineDir) | Out-Null
    }
    New-Item -ItemType Junction -Path $machineDir -Target $shared | Out-Null
    Write-Host "✓ memory: nối $machineDir → $shared"
}

# --- 2. Repo con -----------------------------------------------------------------------------------------------
# Thư mục luôn là `materiant` (fastcast trỏ `../materiant`); trên remote tên materiant-rust để khỏi trùng bản web Angular.
$repos = [ordered]@{
    'fastcast'  = 'https://github.com/nguyendoai7777/fastcast.git'
    'materiant' = 'https://github.com/nguyendoai7777/materiant-rust.git'
    'groove'    = 'https://github.com/nguyendoai7777/groove.git'
    # Server chung của các app desktop (D-24); thư mục `cloud`, remote tên desktop-server.
    'cloud'     = 'https://github.com/nguyendoai7777/desktop-server.git'
    # App khay gửi tệp / thư mục sang điện thoại qua WiFi (W-1); thư mục và remote đều tên `ferry`.
    'ferry'     = 'https://github.com/nguyendoai7777/ferry.git'
}
# App dùng server chung `cloud` (D-24): init app ⇒ kéo cloud theo + tạo khung env của app trong cloud/env/. App mới lên
# server: `node cloud/tools/new-app.mjs <app>` rồi thêm tên vào đây (và `cloud_apps` của init.sh).
$cloudApps = @('fastcast')
function Get-Pulls([string] $App) { $r = @($App, 'materiant'); if ($App -in $cloudApps) { $r += 'cloud' }; $r }
# Project → các repo cần có.
$projects = [ordered]@{
    'fastcast'  = Get-Pulls 'fastcast'
    'materiant' = @('materiant')
    'groove'    = Get-Pulls 'groove'
    'cloud'     = @('cloud')
    'ferry'     = Get-Pulls 'ferry'
}
$labels = @(
    "fastcast   (kéo $((Get-Pulls 'fastcast') -join ' + '))",
    'materiant  (chỉ thư viện UI)',
    "groove     (kéo $((Get-Pulls 'groove') -join ' + '))",
    'cloud      (server chung mọi app: tài khoản, license, đồng bộ)',
    "ferry      (kéo $((Get-Pulls 'ferry') -join ' + '))"
)

# ↑ ↓ di chuyển, Space tích / bỏ, Enter xác nhận. Vẽ lại tại chỗ bằng mã ANSI, phải có ít nhất một mục được tích.
function Select-Checklist([string] $Title, [string[]] $Ids, [string[]] $Labels) {
    $esc = [char]27
    $checked = [bool[]]::new($Ids.Count)
    $cursor = 0
    $hint = '↑ ↓ di chuyển · space chọn · enter xác nhận'
    Write-Host $Title
    [Console]::Write("$esc[?25l")
    try {
        while ($true) {
            for ($i = 0; $i -lt $Ids.Count; $i++) {
                $box = if ($checked[$i]) { '[x]' } else { '[ ]' }
                $line = if ($i -eq $cursor) { "$esc[36m> $box $($Labels[$i])$esc[0m" } else { "  $box $($Labels[$i])" }
                [Console]::Write("`r$esc[2K$line`n")
            }
            [Console]::Write("`r$esc[2K$esc[2m$hint$esc[0m")
            $key = [Console]::ReadKey($true)
            [Console]::Write("`r$esc[$($Ids.Count)A")
            switch ($key.Key) {
                'UpArrow' { $cursor = ($cursor + $Ids.Count - 1) % $Ids.Count }
                'DownArrow' { $cursor = ($cursor + 1) % $Ids.Count }
                'Spacebar' { $checked[$cursor] = -not $checked[$cursor] }
                'Enter' {
                    $picked = @(for ($i = 0; $i -lt $Ids.Count; $i++) { if ($checked[$i]) { $Ids[$i] } })
                    if ($picked.Count) {
                        [Console]::Write("$esc[J")
                        Write-Host "Đã chọn: $($picked -join ', ')"
                        return $picked
                    }
                    $hint = 'chưa chọn project nào, bấm space để chọn'
                }
            }
        }
    } finally {
        [Console]::Write("$esc[?25h")
    }
}

if (-not $Project -and -not [Console]::IsInputRedirected) {
    $Project = Select-Checklist 'Bạn muốn init project nào:' @($projects.Keys) $labels
}
if (-not $Project) {
    # Stdin là pipe (mintty của Git Bash, script): không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
    Write-Host 'Bạn muốn init project nào:'
    Write-Host "  [1] $($labels[0])  (Enter)"
    Write-Host "  [2] $($labels[1])"
    Write-Host "  [3] $($labels[2])"
    Write-Host "  [4] $($labels[3])"
    Write-Host "  [5] $($labels[4])"
    while (-not $Project) {
        Write-Host -NoNewline 'Chọn (nhiều project thì cách bằng dấu phẩy): '
        $answer = [Console]::In.ReadLine()
        if ([string]::IsNullOrWhiteSpace($answer)) { $answer = '1' }
        $picks = @($answer -split '[,\s]+' | Where-Object { $_ })
        if ($picks | Where-Object { $_ -notin '1', '2', '3', '4', '5' }) { Write-Host 'Nhập 1–5 hoặc nhiều số như 1,4.'; continue }
        $Project = @($picks | ForEach-Object { @($projects.Keys)[[int]$_ - 1] })
    }
}
$wanted = @($Project | ForEach-Object { $projects[$_] } | Select-Object -Unique)
foreach ($name in $wanted) {
    $dir = Join-Path $root $name
    if (Test-Path (Join-Path $dir '.git')) { Write-Host "✓ $name có sẵn, không kéo lại"; continue }
    if ((Test-Path $dir) -and (Get-ChildItem $dir -Force)) { Write-Warning "$dir có tệp nhưng không phải repo git — dọn tay rồi chạy lại"; continue }
    if (-not $repos[$name]) { Write-Host "· $name chưa có remote, bỏ qua"; continue }
    git clone $repos[$name] $dir
    if ($LASTEXITCODE -ne 0) { throw "clone $name thất bại" }
    Write-Host "✓ $name đã clone"
}

# Khung env của app dùng server (cloud/env/<app>-dev.env, <app>.env — không theo git): tạo tệp thiếu, thêm biến mới vào
# tệp có sẵn, giá trị đã điền giữ nguyên. Giá trị bí mật vẫn phải điền / chép tay. Chọn `cloud` ⇒ mọi app dùng server.
# @(…) bọc ngoài: một app thì Select-Object trả chuỗi trần, splat chuỗi trần không ra đối số.
$envApps = @(@(foreach ($p in $Project) { if ($p -eq 'cloud') { $cloudApps } elseif ($p -in $cloudApps) { $p } }) | Select-Object -Unique)
$newApp = Join-Path $root 'cloud/tools/new-app.mjs'
if ($envApps -and (Test-Path $newApp)) {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        & node $newApp --env-only @envApps
    } else {
        Write-Warning "thiếu node: bỏ qua khung env của cloud ($($envApps -join ', ')) — cài Node rồi chạy lại"
    }
}

# --- 2b. Lịch sử git thẳng (D-12): pull luôn rebase, mọi repo đang có --------------------------------------------
foreach ($repo in @($root) + @(Get-ChildItem -Directory $root | ForEach-Object FullName)) {
    if (-not (Test-Path (Join-Path $repo '.git'))) { continue }
    git -C $repo config pull.rebase true
    git -C $repo config rebase.autoStash true
}

# --- 3. Công cụ ------------------------------------------------------------------------------------------------
foreach ($tool in 'git', 'cargo', 'rustc') {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) { Write-Host "✓ $tool  $((& $tool --version) -join ' ')" } else { Write-Warning "thiếu $tool" }
}
