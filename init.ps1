# Dựng máy mới cho workspace xdesktop (Windows). Idempotent — chạy lại lúc nào cũng được.
#   pwsh init.ps1
# 1. Nối memory của Claude trên máy này vào .claude/memory (track trong git) bằng junction.
# 2. Clone repo app / thư viện còn thiếu (bảng $repos — điền remote khi tạo repo).
# 3. Soát công cụ.
$ErrorActionPreference = 'Stop'
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
# Remote rỗng = repo mới chỉ có local (Q-2) — không clone được, chỉ báo.
$repos = [ordered]@{
    'fastcast'     = ''
    'materiant'    = ''
}
foreach ($name in $repos.Keys) {
    $dir = Join-Path $root $name
    if (Test-Path (Join-Path $dir '.git')) { Write-Host "✓ $name có sẵn"; continue }
    if (-not $repos[$name]) { Write-Warning "$name chưa có remote — chép tay từ máy khác hoặc điền remote vào init.ps1 / init.sh"; continue }
    git clone $repos[$name] $dir
}

# --- 3. Công cụ ------------------------------------------------------------------------------------------------
foreach ($tool in 'git', 'cargo', 'rustc') {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) { Write-Host "✓ $tool  $((& $tool --version) -join ' ')" } else { Write-Warning "thiếu $tool" }
}
