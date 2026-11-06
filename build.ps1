# Build bản release — chỉ hỏi / định tuyến; việc thật nằm ở `<repo>/build.ps1` của từng project. Hỏi project (Fastcast / Groovex /
# materiant docs) rồi gọi sang script của nó; fastcast hỏi tiếp OS → kiến trúc → chip (Enter = máy đang chạy) → plan (Free / Pro).
# Đứng ở gốc workspace:
#   pwsh ./build.ps1
#   pwsh ./build.ps1 -Project fastcast -Os windows -Arch x64 -Chip intel-amd   # không hỏi (có -Os / -Arch / -Chip ⇒ fastcast)
#   pwsh ./build.ps1 -f                                         # -Force: biên dịch lại mã của ta, giữ thư viện đã build
#   pwsh ./build.ps1 -Pro                                       # = -Plan pro: fastcast mở sẵn Pro để nghiệm thu (D-23), tên có `_pro`
# Groovex: bản cài cho máy đang chạy ở release/groove/. materiant: chỉ gallery docs, ra release/materiant/materiant-docs.exe.
# Fastcast: release/fastcast/fastcast_<version>_win_<arch>[_avx2][_pro]/ + bản cài NSIS (x64 phổ thông). Chỉ build được cho OS
# đang chạy. macOS / Linux: script của project chuyển sang build.sh.
param(
    [ValidateSet('windows', 'macos', 'linux')] [string] $Os,
    [ValidateSet('x64', 'arm64')] [string] $Arch,
    [ValidateSet('intel-amd', 'avx2', 'intel', 'apple', 'snapdragon', 'arm')] [string] $Chip,
    [Alias('f')] [switch] $Force,
    [switch] $Pro,
    [ValidateSet('free', 'pro')] [string] $Plan,
    [ValidateSet('fastcast', 'groove', 'materiant')] [string] $Project
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = $PSScriptRoot
. (Join-Path $root 'tools/script-lib.ps1')

# -Os / -Arch / -Chip / plan chỉ có ở fastcast: có cờ đó thì khỏi hỏi project.
if (-not $Project -and ($Os -or $Arch -or $Chip -or $Pro -or $Plan)) { $Project = 'fastcast' }
if (-not $Project) {
    $Project = Select-Option 'Build project nào:' @(
        (Option 'fastcast' 'Fastcast'), (Option 'groove' 'Groovex'), (Option 'materiant' 'materiant (docs only)'))
}
$forward = @{}
if ($Force) { $forward.Force = $true }
if ($Project -eq 'fastcast') {
    foreach ($name in 'Os', 'Arch', 'Chip', 'Plan') {
        $value = Get-Variable $name -ValueOnly
        if ($value) { $forward[$name] = $value }
    }
    if ($Pro) { $forward.Pro = $true }
} elseif ($Os -or $Arch -or $Chip -or $Pro -or $Plan) {
    throw "$Project chỉ build cho máy đang chạy, không nhận -Os, -Arch, -Chip, -Pro, -Plan."
}
$script = Join-Path $root "$Project/build.ps1"
if (-not (Test-Path -LiteralPath $script)) { Write-Error "Thiếu $Project (hoặc $Project/build.ps1): chạy pwsh init.ps1 rồi chọn $Project." -ErrorAction Continue; exit 1 }
& $script @forward
exit $LASTEXITCODE
