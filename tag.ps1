# Hỏi project rồi nâng version, commit, đánh tag v<version> (version ở Cargo.toml gốc của repo). Đứng ở gốc workspace:
#   pwsh ./tag.ps1                 # không cờ = --patch
#   pwsh ./tag.ps1 -p | --patch    # 0.1.0 → 0.1.1, commit version rồi tag
#   pwsh ./tag.ps1 --minor         # 0.1.0 → 0.2.0
#   pwsh ./tag.ps1 --major         # 0.1.0 → 1.0.0
#   pwsh ./tag.ps1 --current       # tag đúng version đang có, không nâng
#   pwsh ./tag.ps1 -p --push       # đẩy luôn commit + tag lên origin
#   pwsh ./tag.ps1 -Project materiant --minor     # không hỏi project
# Nâng materiant thì `Cargo.lock` của fastcast đổi theo (build dùng `--locked`), nên fastcast có thêm một commit.
param(
    [ValidateSet('fastcast', 'materiant')] [string] $Project,
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

# ↑ ↓ di chuyển, Enter chọn; vẽ lại tại chỗ bằng mã ANSI. Stdin là pipe (mintty của Git Bash, script): không đọc được phím
# lẻ ⇒ gõ số qua [Console]::In; hết stdin thì lấy mặc định.
function Select-Option([string] $Title, [object[]] $Options, [int] $Default = 0) {
    if ($Options.Count -eq 1) { Write-Host "$Title $($Options[0].Label)"; return $Options[0].Id }
    if (-not [Console]::IsInputRedirected) {
        $esc = [char]27
        $cursor = $Default
        Write-Host $Title
        [Console]::Write("$esc[?25l")
        try {
            while ($true) {
                for ($i = 0; $i -lt $Options.Count; $i++) {
                    $line = if ($i -eq $cursor) { "$esc[36m> $($Options[$i].Label)$esc[0m" } else { "  $($Options[$i].Label)" }
                    [Console]::Write("`r$esc[2K$line`n")
                }
                [Console]::Write("`r$esc[2K$esc[2m↑ ↓ di chuyển · enter chọn$esc[0m")
                $key = [Console]::ReadKey($true)
                [Console]::Write("`r$esc[$($Options.Count)A")
                switch ($key.Key) {
                    'UpArrow' { $cursor = ($cursor + $Options.Count - 1) % $Options.Count }
                    'DownArrow' { $cursor = ($cursor + 1) % $Options.Count }
                    'Enter' {
                        # Xoá cả dòng tiêu đề rồi in lại kèm lựa chọn.
                        [Console]::Write("$esc[1A`r$esc[J")
                        Write-Host "$Title $($Options[$cursor].Label)"
                        return $Options[$cursor].Id
                    }
                }
            }
        } finally {
            [Console]::Write("$esc[?25h")
        }
    }
    Write-Host $Title
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  [{0}] {1}{2}" -f ($i + 1), $Options[$i].Label, $(if ($i -eq $Default) { '  (Enter)' }))
    }
    while ($true) {
        Write-Host -NoNewline 'Chọn: '
        $answer = [Console]::In.ReadLine()
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Options[$Default].Id }
        $n = 0
        if ([int]::TryParse($answer, [ref]$n) -and $n -ge 1 -and $n -le $Options.Count) { return $Options[$n - 1].Id }
        Write-Host "Nhập số từ 1 đến $($Options.Count)."
    }
}

foreach ($arg in $Rest) {
    switch ($arg) {
        '--patch' { $Patch = $true }
        '--minor' { $Minor = $true }
        '--major' { $Major = $true }
        '--current' { $Current = $true }
        '--push' { $Push = $true }
        default { throw "Không hiểu tham số: $arg" }
    }
}

if (-not $Project) {
    $Project = Select-Option 'Đánh tag cho project nào:' @(
        @{ Id = 'fastcast'; Label = 'fastcast' }
        @{ Id = 'materiant'; Label = 'materiant' }
    )
}
$repo = Join-Path $PSScriptRoot $Project
$fastcast = Join-Path $PSScriptRoot 'fastcast'
if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { throw "Chưa có ${Project}: chạy init.ps1." }

function Invoke-Git { & git -C $repo @args; if ($LASTEXITCODE -ne 0) { throw "git $args failed (exit $LASTEXITCODE)" } }

if (@($Patch, $Minor, $Major, $Current).Where({ $_ }).Count -gt 1) { throw 'Chỉ chọn một trong -p, --minor, --major, --current.' }
if (-not ($Patch -or $Minor -or $Major -or $Current)) { $Patch = $true }
if (Invoke-Git status --porcelain) { throw "$Project còn thay đổi chưa commit, tag sẽ không khớp code." }
$branch = Invoke-Git branch --show-current
if ($branch -ne 'master') { throw "$Project đang ở nhánh '$branch', chỉ tag trên master." }

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

if (-not $Current) {
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
    # fastcast build bằng `--locked`, ghi cả version của materiant trong lock.
    if ($Project -eq 'materiant' -and (Test-Path -LiteralPath (Join-Path $fastcast '.git'))) {
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
            git -C $fastcast commit --quiet -m "deps: materiant $tag" -- Cargo.lock
            if ($LASTEXITCODE -ne 0) { throw "git commit failed (exit $LASTEXITCODE)" }
            $lockSynced = $true
        }
    }
}
Invoke-Git tag -a $tag -m $tag
Write-Host "${Project}: $version → $next, tag $tag ở $(Invoke-Git rev-parse --short HEAD)"

if ($Push) {
    Invoke-Git push --quiet origin master $tag
    if ($lockSynced) {
        git -C $fastcast push --quiet origin master
        if ($LASTEXITCODE -ne 0) { throw "git push failed (exit $LASTEXITCODE)" }
    }
    Write-Host "Đã đẩy master + $tag của $Project lên origin."
} else {
    Write-Host "Chưa đẩy. Đẩy lên: git -C $Project push origin master $tag"
    if ($lockSynced) { Write-Host 'fastcast có commit cập nhật lock: git -C fastcast push origin master' }
}
