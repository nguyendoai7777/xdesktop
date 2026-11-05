# Build bản release. Hỏi project (fastcast / groove / materiant docs) rồi, với fastcast, OS → kiến trúc → chip (Enter = máy
# đang chạy). Đứng ở gốc workspace:
#   pwsh ./build.ps1
#   pwsh ./build.ps1 -Project fastcast -Os windows -Arch x64 -Chip intel-amd   # không hỏi
#   pwsh ./build.ps1 -f                                         # -Force: biên dịch lại mã của ta, giữ thư viện đã build
# Groovex: bản cài cho máy đang chạy ở release/groove/. materiant: chỉ gallery docs, ra release/materiant/materiant-docs.exe.
# Tên đầu ra: <app>_<version>_<os>_<arch>[_avx2].<đuôi>. Ra release/fastcast/fastcast_<version>_win_<arch>[_avx2]/ (bốn exe, models,
# licenses — chạy `fst.exe`). Windows x64 phổ thông có đủ NSIS + model thì thêm bản cài release/fastcast/fastcast_<version>_win_x64.exe. Chỉ build được cho OS đang chạy: thiếu SDK để link chéo OS.
param(
    [ValidateSet('windows', 'macos', 'linux')] [string] $Os,
    [ValidateSet('x64', 'arm64')] [string] $Arch,
    [ValidateSet('intel-amd', 'avx2', 'intel', 'apple', 'snapdragon', 'arm')] [string] $Chip,
    [Alias('f')] [switch] $Force,
    [switch] $Pro,
    [ValidateSet('fastcast', 'groove', 'materiant')] [string] $Project
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = $PSScriptRoot
$repo = Join-Path $root 'fastcast'

# Radio, chỉ chọn một: ↑ ↓ di chuyển, Enter chọn; vẽ lại tại chỗ bằng mã ANSI. Stdin là pipe (mintty của Git Bash, script): không đọc được phím
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
                    $line = if ($i -eq $cursor) { "$esc[36m(•) $($Options[$i].Label)$esc[0m" } else { "( ) $($Options[$i].Label)" }
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
function Option([string] $Id, [string] $Label) { [pscustomobject]@{ Id = $Id; Label = $Label } }

# -Os / -Arch / -Chip chỉ có ở fastcast: có cờ đó thì khỏi hỏi project.
if (-not $Project -and ($Os -or $Arch -or $Chip)) { $Project = 'fastcast' }
if (-not $Project) {
    $Project = Select-Option 'Build project nào:' @(
        (Option 'fastcast' 'Fastcast'), (Option 'groove' 'Groovex'), (Option 'materiant' 'materiant (docs only)'))
}

# Groovex: bản cài cho đúng máy đang chạy, ra release/groove/. Dựng thật do script của repo groove.
if ($Project -eq 'groove') {
    if ($Os -or $Arch -or $Chip) { throw 'groove chỉ build cho máy đang chạy, không nhận -Os, -Arch, -Chip.' }
    if (-not $IsWindows) { throw 'macOS, Linux: bash build.sh --project groove' }
    if ($Force) {
        cargo clean --release --manifest-path (Join-Path $root 'groove/Cargo.toml') -p groove-app -p groove -p groove-audio -p groove-core -p groove-library -p materiant
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    & (Join-Path $root 'groove/packaging/windows/build-installer.ps1') -OutDir (Join-Path $root 'release/groove')
    exit $LASTEXITCODE
}

# materiant chỉ có gallery docs (assets nhúng sẵn trong exe): ra release/materiant/materiant-docs[.exe].
if ($Project -eq 'materiant') {
    if ($Os -or $Arch -or $Chip) { throw 'materiant chỉ build cho máy đang chạy, không nhận -Os, -Arch, -Chip.' }
    $manifest = Join-Path $root 'materiant/Cargo.toml'
    if (-not (Test-Path $manifest)) { Write-Error 'Thiếu materiant: chạy pwsh init.ps1.' -ErrorAction Continue; exit 1 }
    if ($Force) {
        cargo clean --release --manifest-path $manifest -p materiant
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    node (Join-Path $root 'tools/cargo-prune.mjs') build --release --locked --manifest-path $manifest -p materiant --example gallery
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $targetDir = (cargo metadata --format-version 1 --no-deps --manifest-path $manifest | ConvertFrom-Json).target_directory
    $suffix = if ($IsWindows) { '.exe' } else { '' }
    $out = Join-Path $root 'release/materiant'
    New-Item -ItemType Directory -Force $out | Out-Null
    Copy-Item -Force -LiteralPath (Join-Path $targetDir "release/examples/gallery$suffix") -Destination (Join-Path $out "materiant-docs$suffix")
    Write-Host "`nXong: $(Join-Path $out "materiant-docs$suffix")"
    exit 0
}

$hostOs = if ($IsMacOS) { 'macos' } elseif ($IsLinux) { 'linux' } else { 'windows' }
$hostArch = if ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'x64' }

if (-not $Os) {
    $oses = @((Option 'windows' 'Windows'), (Option 'macos' 'macOS'), (Option 'linux' 'Linux'))
    $Os = Select-Option 'Build cho OS nào:' $oses ([array]::FindIndex($oses, [Predicate[object]] { $args[0].Id -eq $hostOs }))
}
if ($Os -ne $hostOs) {
    Write-Error "Máy này chạy $hostOs, không link được bản $Os. Chạy build trên máy $Os." -ErrorAction Continue
    exit 1
}
if (-not $Arch) {
    $arches = @((Option 'x64' 'x64 (64-bit Intel / AMD)'), (Option 'arm64' 'arm64'))
    $Arch = Select-Option 'Kiến trúc:' $arches $(if ($hostArch -eq 'arm64') { 1 } else { 0 })
}

$chips = switch ("$Os-$Arch") {
    { $_ -in 'windows-x64', 'linux-x64' } {
        Option 'intel-amd' 'Intel / AMD, chạy trên mọi máy'
        Option 'avx2' 'Intel / AMD đời mới có AVX2 (x86-64-v3), máy cũ không chạy được'
    }
    'windows-arm64' { Option 'snapdragon' 'Snapdragon' }
    'macos-x64' { Option 'intel' 'Intel' }
    'macos-arm64' { Option 'apple' 'Apple Silicon (M1 trở lên)' }
    'linux-arm64' { Option 'arm' 'ARM 64-bit' }
}
$chips = @($chips)
if ($Chip) {
    if ($Chip -notin $chips.Id) { Write-Error "Chip $Chip không có ở $Os $Arch. Chọn: $($chips.Id -join ', ')." -ErrorAction Continue; exit 1 }
} else {
    $Chip = Select-Option 'Loại chip:' $chips
}

$triple = @{
    'windows-x64'   = 'x86_64-pc-windows-msvc'
    'windows-arm64' = 'aarch64-pc-windows-msvc'
    'macos-x64'     = 'x86_64-apple-darwin'
    'macos-arm64'   = 'aarch64-apple-darwin'
    'linux-x64'     = 'x86_64-unknown-linux-gnu'
    'linux-arm64'   = 'aarch64-unknown-linux-gnu'
}["$Os-$Arch"]

if (-not (Test-Path (Join-Path $repo 'Cargo.toml')) -or -not (Test-Path (Join-Path $root 'materiant/Cargo.toml'))) {
    Write-Error 'Thiếu fastcast hoặc materiant: chạy pwsh init.ps1 rồi chọn fastcast.' -ErrorAction Continue
    exit 1
}

Write-Host "`n==> $triple, chip $Chip"
if ((rustup target list --installed) -notcontains $triple) {
    rustup target add $triple
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
if ($Chip -eq 'avx2') { $env:RUSTFLAGS = "$env:RUSTFLAGS -C target-cpu=x86-64-v3".Trim() }

# Luôn --target: RUSTFLAGS không lan sang build script, mỗi target một thư mục. Không feature `dev-env` (bản phát hành).
Push-Location $repo
try {
    if ($Force) {
        cargo clean --release --target $triple -p fastcast-core -p fastcast-capture -p fastcast-daemon -p fastcast-ui -p fastcast-ocr -p fastcast-video -p fastcast-sync -p materiant
        if ($LASTEXITCODE -ne 0) { throw "cargo clean failed (exit $LASTEXITCODE)" }
    }
    # Build qua tools/cargo-prune.mjs: build xong dọn bản build cũ (cùng crate, hash khác) trong thư mục build vừa dùng.
    node (Join-Path $root 'tools/cargo-prune.mjs') build --release --locked --target $triple -p fastcast-daemon -p fastcast-ui -p fastcast-ocr -p fastcast-video -p fastcast-sync --bins @(if ($Pro) { '--features', 'fastcast-core/pro-unlock' })
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}
$targetDir = (cargo metadata --format-version 1 --no-deps --manifest-path (Join-Path $repo 'Cargo.toml') | ConvertFrom-Json).target_directory
$release = Join-Path $targetDir "$triple/release"
$version = ((cargo metadata --format-version 1 --no-deps --manifest-path (Join-Path $repo 'Cargo.toml') | ConvertFrom-Json).packages | Where-Object name -EQ 'fastcast-daemon').version
# Tên tệp: {app}_{version}_{os}_{arch}[_avx2]; Linux theo tên kiến trúc Debian.
$osName = @{ windows = 'win'; macos = 'macos'; linux = 'linux' }[$Os]
$archName = if ($Os -eq 'linux') { @{ x64 = 'amd64'; arm64 = 'arm64' }[$Arch] } else { $Arch }
# Bản nghiệm thu Pro (D-23): feature `pro-unlock`, hậu tố `_pro` để không lẫn với bản phát hành.
$outName = "fastcast_${version}_${osName}_$archName$(if ($Chip -eq 'avx2') { '_avx2' })$(if ($Pro) { '_pro' })"
$suffix = if ($Os -eq 'windows') { '.exe' } else { '' }

$devVars = 'FASTCAST_OCR_EXE', 'FASTCAST_REC_EXE', 'FASTCAST_REC_WINDOW', 'FASTCAST_OCR_MODELS'
$exes = 'fst', 'fastcast-ui', 'fastcast-ocr', 'fastcast-rec', 'fastcast-sync'
foreach ($exe in $exes) {
    $text = [Text.Encoding]::Latin1.GetString([IO.File]::ReadAllBytes((Join-Path $release "$exe$suffix")))
    $found = $devVars | Where-Object { $text.Contains($_) }
    if ($found) { Write-Error "$exe còn biến chạy thử: $($found -join ', ')" -ErrorAction Continue; exit 1 }
    # Inspector (D-19) chỉ có ở bản debug: bản cài mà còn chuỗi của nó thì build sai profile.
    if ($exe -eq 'fastcast-ui' -and ('inspector-pick', 'Hover to highlight' | Where-Object { $text.Contains($_) })) {
        Write-Error 'fastcast-ui còn inspector (bản debug?)' -ErrorAction Continue; exit 1
    }
}

$releaseRoot = Join-Path $root 'release/fastcast'
$out = Join-Path $releaseRoot $outName
if (Test-Path -LiteralPath $out) { Remove-Item -Recurse -Force -LiteralPath $out }
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($exe in $exes) { Copy-Item -LiteralPath (Join-Path $release "$exe$suffix") -Destination $out }

$warnings = @()
if (Get-Command cargo-about -ErrorAction Ignore) {
    & (Join-Path $repo 'tools/gen-licenses.ps1') -Out (Join-Path $out 'licenses')
} else {
    $warnings += 'Không có trang giấy phép (cargo install cargo-about --locked --features cli).'
}

# Model + dll ONNX Runtime đã dựng ở target/release/models (tools/fetch-ocr-models.ps1). dll theo kiến trúc: chỉ dùng
# đúng máy dựng ra nó.
$models = Join-Path $targetDir 'release/models'
$hasModels = (Test-Path -LiteralPath $models) -and $Arch -eq $hostArch
if ($hasModels) {
    Copy-Item -Recurse -LiteralPath $models -Destination (Join-Path $out 'models')
} else {
    $warnings += 'Không kèm model: OCR chưa chạy được (dựng bằng fastcast/tools/fetch-ocr-models.ps1 vào target/release/models).'
}

$setup = $null
# Bản cài tự build lại không `pro-unlock`: bản `-Pro` chỉ ra thư mục exe rời.
if ("$Os-$Arch-$Chip" -eq 'windows-x64-intel-amd' -and $hasModels -and -not $Pro) {
    $nsis = (Get-Command makensis -ErrorAction Ignore).Source
    foreach ($path in (Join-Path $root '../tools/nsis/makensis.exe'), (Join-Path ${env:ProgramFiles(x86)} 'NSIS/makensis.exe')) {
        if (-not $nsis -and (Test-Path -LiteralPath $path)) { $nsis = (Resolve-Path $path).Path }
    }
    if ($nsis) {
        & (Join-Path $repo 'tools/build-installer.ps1') -Target $triple -ModelsSource $models -Makensis $nsis
        $setup = Join-Path $releaseRoot "fastcast_${version}_win_x64.exe"
        foreach ($file in "fastcast_${version}_win_x64.exe", "fastcast_${version}_win_x64.exe.sha256") {
            Move-Item -Force -LiteralPath (Join-Path $repo "dist/$file") -Destination $releaseRoot
        }
    } else {
        $warnings += 'Không có bản cài: thiếu NSIS (winget install NSIS.NSIS).'
    }
}

Write-Host "`nXong: $out"
if ($setup) { Write-Host "Bản cài: $setup" }
foreach ($w in $warnings) { Write-Warning $w }
