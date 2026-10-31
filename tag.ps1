# Đánh tag v<version> cho commit hiện tại của fastcast (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   pwsh ./tag.ps1                 # tag đúng version đang có
#   pwsh ./tag.ps1 -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   pwsh ./tag.ps1 --minor         # 0.1.0 → 0.2.0
#   pwsh ./tag.ps1 --major         # 0.1.0 → 1.0.0
#   pwsh ./tag.ps1 -p --push       # đẩy luôn commit + tag lên origin
param(
    [Alias('p')] [switch] $Patch,
    [switch] $Minor,
    [switch] $Major,
    [switch] $Push,
    # PowerShell không tự nhận cờ hai gạch: đọc ở đây để gõ giống tag.sh.
    [Parameter(ValueFromRemainingArguments)] [string[]] $Rest
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$repo = Join-Path $PSScriptRoot 'fastcast'
foreach ($arg in $Rest) {
    switch ($arg) {
        '--patch' { $Patch = $true }
        '--minor' { $Minor = $true }
        '--major' { $Major = $true }
        '--push' { $Push = $true }
        default { throw "Không hiểu tham số: $arg" }
    }
}

function Invoke-Git { & git -C $repo @args; if ($LASTEXITCODE -ne 0) { throw "git $args failed (exit $LASTEXITCODE)" } }

if (@($Patch, $Minor, $Major).Where({ $_ }).Count -gt 1) { throw 'Chỉ chọn một trong -p, --minor, --major.' }
if (Invoke-Git status --porcelain) { throw 'fastcast còn thay đổi chưa commit, tag sẽ không khớp code.' }
$branch = Invoke-Git branch --show-current
if ($branch -ne 'master') { throw "fastcast đang ở nhánh '$branch', chỉ tag trên master." }

$manifest = Join-Path $repo 'Cargo.toml'
$text = [IO.File]::ReadAllText($manifest)
# Chỉ dòng version đầu tiên: của [workspace.package], không đụng dòng version của phụ thuộc.
$pattern = [regex] '(?m)^version = "(\d+)\.(\d+)\.(\d+)"(\r?)$'
$found = $pattern.Match($text)
if (-not $found.Success) { throw 'Không đọc được version trong Cargo.toml.' }
$x, $y, $z = 1..3 | ForEach-Object { [int] $found.Groups[$_].Value }
$version = "$x.$y.$z"
if ($Patch) { $z++ }
if ($Minor) { $y++; $z = 0 }
if ($Major) { $x++; $y = 0; $z = 0 }
$next = "$x.$y.$z"
$tag = "v$next"
if (Invoke-Git tag --list $tag) { throw "Tag $tag đã có." }

if ($Patch -or $Minor -or $Major) {
    $line = "version = `"$next`"$($found.Groups[4].Value)"
    $text = $text.Remove($found.Index, $found.Length).Insert($found.Index, $line)
    [IO.File]::WriteAllText($manifest, $text, [Text.UTF8Encoding]::new($false))
    Push-Location $repo
    try {
        cargo update --workspace --offline --quiet
        if ($LASTEXITCODE -ne 0) { throw "cargo update failed (exit $LASTEXITCODE)" }
    } finally {
        Pop-Location
    }
    Invoke-Git commit --quiet -m "release: $tag" -- Cargo.toml Cargo.lock
}
Invoke-Git tag -a $tag -m $tag
Write-Host "$version → $next, tag $tag ở $(Invoke-Git rev-parse --short HEAD)"

if ($Push) {
    Invoke-Git push --quiet origin master $tag
    Write-Host "Đã đẩy master + $tag lên origin."
} else {
    Write-Host "Chưa đẩy. Đẩy lên: git -C fastcast push origin master $tag"
}
