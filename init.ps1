# Dựng máy mới cho workspace xdesktop (Windows). Idempotent — chạy lại lúc nào cũng được.
#   pwsh init.ps1                    hỏi init project nào
#   pwsh init.ps1 -Project fastcast  không hỏi
# 1. Nối memory của Claude trên máy này vào .claude/memory (track trong git) bằng junction.
# 2. Clone repo của project được chọn (bảng $repos, $projects); repo đã có thì giữ nguyên, không pull.
# 3. Soát công cụ.
param([ValidateSet('fastcast', 'materiant')] [string[]] $Project)
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
}
# Project → các repo cần có.
$projects = [ordered]@{
    'fastcast'  = @('fastcast', 'materiant')
    'materiant' = @('materiant')
}
if (-not $Project) {
    # Đọc bằng [Console]::In: chạy được cả khi stdin là pipe (Git Bash); hết stdin thì lấy mặc định.
    Write-Host 'Bạn muốn init project nào:'
    Write-Host '  [1] fastcast   (kéo fastcast + materiant)  (Enter)'
    Write-Host '  [2] materiant  (chỉ thư viện UI)'
    while (-not $Project) {
        Write-Host -NoNewline 'Chọn (nhiều project thì cách bằng dấu phẩy): '
        $answer = [Console]::In.ReadLine()
        if ([string]::IsNullOrWhiteSpace($answer)) { $answer = '1' }
        $picks = @($answer -split '[,\s]+' | Where-Object { $_ })
        if ($picks | Where-Object { $_ -notin '1', '2' }) { Write-Host 'Nhập 1, 2 hoặc 1,2.'; continue }
        $Project = @($picks | ForEach-Object { @($projects.Keys)[[int]$_ - 1] })
    }
}
$wanted = @($Project | ForEach-Object { $projects[$_] } | Select-Object -Unique)
foreach ($name in $wanted) {
    $dir = Join-Path $root $name
    if (Test-Path (Join-Path $dir '.git')) { Write-Host "✓ $name có sẵn, không kéo lại"; continue }
    if ((Test-Path $dir) -and (Get-ChildItem $dir -Force)) { Write-Warning "$dir có tệp nhưng không phải repo git — dọn tay rồi chạy lại"; continue }
    git clone $repos[$name] $dir
    if ($LASTEXITCODE -ne 0) { throw "clone $name thất bại" }
    Write-Host "✓ $name đã clone"
}

# --- 3. Công cụ ------------------------------------------------------------------------------------------------
foreach ($tool in 'git', 'cargo', 'rustc') {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) { Write-Host "✓ $tool  $((& $tool --version) -join ' ')" } else { Write-Warning "thiếu $tool" }
}
