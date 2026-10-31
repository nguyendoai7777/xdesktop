# Hỏi project (space tích, enter xác nhận, chọn được nhiều) rồi nâng version, commit, đánh tag v<version> (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   pwsh ./tag.ps1                 # không cờ = --patch
#   pwsh ./tag.ps1 -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   pwsh ./tag.ps1 --minor         # 0.1.0 → 0.2.0
#   pwsh ./tag.ps1 --major         # 0.1.0 → 1.0.0
#   pwsh ./tag.ps1 --current       # tag đúng version đang có, không nâng
#   pwsh ./tag.ps1 -p --push       # đẩy luôn commit + tag lên origin
#   pwsh ./tag.ps1 -Project materiant --minor     # không hỏi project; nhiều project: -Project fastcast,materiant
# Nâng materiant thì `Cargo.lock` của fastcast đổi theo (build dùng `--locked`), nên fastcast có thêm một commit.
param(
    [ValidateSet('fastcast', 'materiant')] [string[]] $Project,
    [Alias('p')] [switch] $Patch,
    [switch] $Minor,
    [switch] $Major,
    [switch] $Current,
    [switch] $Push,
    # PowerShell không tự nhận cờ hai gạch: đọc ở đây để gõ giống tag.sh.
    [Parameter(ValueFromRemainingArguments)] [string[]] $Rest
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

if (@($Patch, $Minor, $Major, $Current).Where({ $_ }).Count -gt 1) { throw 'Chỉ chọn một trong -p, --minor, --major, --current.' }
if (-not ($Patch -or $Minor -or $Major -or $Current)) { $Patch = $true }

$ids = 'fastcast', 'materiant'
if (-not $Project -and -not [Console]::IsInputRedirected) {
    $Project = Select-Checklist 'Đánh tag cho project nào:' $ids $ids
}
if (-not $Project) {
    # Stdin là pipe (mintty của Git Bash, script): không đọc được phím lẻ ⇒ gõ số; hết stdin thì lấy mặc định.
    Write-Host 'Đánh tag cho project nào:'
    Write-Host '  [1] fastcast  (Enter)'
    Write-Host '  [2] materiant'
    while (-not $Project) {
        Write-Host -NoNewline 'Chọn (nhiều project thì cách bằng dấu phẩy): '
        $answer = [Console]::In.ReadLine()
        if ([string]::IsNullOrWhiteSpace($answer)) { $answer = '1' }
        $picks = @($answer -split '[,\s]+' | Where-Object { $_ })
        if ($picks | Where-Object { $_ -notin '1', '2' }) { Write-Host 'Nhập 1, 2 hoặc 1,2.'; continue }
        $Project = @($picks | ForEach-Object { $ids[[int]$_ - 1] })
    }
}
# materiant trước: fastcast có commit cập nhật lock thì tag của fastcast chứa luôn commit đó.
$order = @('materiant', 'fastcast' | Where-Object { $_ -in $Project })

$fastcast = Join-Path $PSScriptRoot 'fastcast'
# Chỉ dòng version đầu tiên: của gói / [workspace.package], không đụng dòng version của phụ thuộc.
$pattern = [regex] '(?m)^version = "(\d+)\.(\d+)\.(\d+)"(\r?)$'

function Invoke-Git([string] $Repo) { & git -C $Repo @args; if ($LASTEXITCODE -ne 0) { throw "git $args failed (exit $LASTEXITCODE)" } }

function Get-Plan([string] $Name) {
    $manifest = Join-Path $PSScriptRoot "$Name/Cargo.toml"
    $text = [IO.File]::ReadAllText($manifest)
    $found = $pattern.Match($text)
    if (-not $found.Success) { throw "Không đọc được version trong $Name/Cargo.toml." }
    $x, $y, $z = 1..3 | ForEach-Object { [int] $found.Groups[$_].Value }
    $version = "$x.$y.$z"
    if ($Patch) { $z++ }
    if ($Minor) { $y++; $z = 0 }
    if ($Major) { $x++; $y = 0; $z = 0 }
    @{ Manifest = $manifest; Text = $text; Found = $found; Version = $version; Next = "$x.$y.$z"; Tag = "v$x.$y.$z" }
}

# Soát hết trước khi đụng gì: một project hỏng thì không project nào đổi.
foreach ($name in $order) {
    $repo = Join-Path $PSScriptRoot $name
    if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { throw "Chưa có ${name}: chạy init.ps1." }
    if (Invoke-Git $repo status --porcelain) { throw "$name còn thay đổi chưa commit, tag sẽ không khớp code." }
    $branch = Invoke-Git $repo branch --show-current
    if ($branch -ne 'master') { throw "$name đang ở nhánh '$branch', chỉ tag trên master." }
    $plan = Get-Plan $name
    if (Invoke-Git $repo tag --list $plan.Tag) { throw "Tag $($plan.Tag) của $name đã có." }
}

$pushes = @()
$lockSynced = $false
foreach ($name in $order) {
    $repo = Join-Path $PSScriptRoot $name
    $plan = Get-Plan $name
    $tag = $plan.Tag
    if (-not $Current) {
        $found = $plan.Found
        $line = "version = `"$($plan.Next)`"$($found.Groups[4].Value)"
        $text = $plan.Text.Remove($found.Index, $found.Length).Insert($found.Index, $line)
        [IO.File]::WriteAllText($plan.Manifest, $text, [Text.UTF8Encoding]::new($false))
        Push-Location $repo
        try {
            cargo update --workspace --offline --quiet
            if ($LASTEXITCODE -ne 0) { throw "cargo update failed (exit $LASTEXITCODE)" }
        } finally {
            Pop-Location
        }
        Invoke-Git $repo commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock
        # fastcast build bằng `--locked`, ghi cả version của materiant trong lock.
        if ($name -eq 'materiant' -and (Test-Path -LiteralPath (Join-Path $fastcast '.git'))) {
            git -C $fastcast diff --quiet -- Cargo.lock
            if ($LASTEXITCODE -ne 0) { throw 'fastcast/Cargo.lock đang có sửa dở, chưa cập nhật materiant.' }
            Push-Location $fastcast
            try {
                cargo update -p materiant --offline --quiet
                if ($LASTEXITCODE -ne 0) { throw "cargo update failed (exit $LASTEXITCODE)" }
            } finally {
                Pop-Location
            }
            git -C $fastcast diff --quiet -- Cargo.lock
            if ($LASTEXITCODE -ne 0) {
                Invoke-Git $fastcast commit --quiet -m "deps: materiant $tag" -- Cargo.lock
                $lockSynced = $true
            }
        }
    }
    Invoke-Git $repo tag -a $tag -m $tag
    Write-Host "${name}: $($plan.Version) → $($plan.Next), tag $tag ở $(Invoke-Git $repo rev-parse --short HEAD)"
    $pushes += , @($name, $tag)
}
# fastcast chỉ có commit cập nhật lock, không có tag mới.
if ($lockSynced -and 'fastcast' -notin $order) { $pushes += , @('fastcast') }

foreach ($entry in $pushes) {
    $name = $entry[0]
    $refs = @('master') + @($entry | Select-Object -Skip 1)
    if ($Push) {
        Invoke-Git (Join-Path $PSScriptRoot $name) push --quiet origin @refs
        Write-Host "Đã đẩy $name lên origin."
    } else {
        Write-Host "Chưa đẩy. Đẩy lên: git -C $name push origin $($refs -join ' ')"
    }
}
