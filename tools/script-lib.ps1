# Hàm dùng chung cho build.ps1 của gốc workspace và của từng repo (fastcast, groove, materiant). Nạp sau khi đã tìm ra gốc
# (thư mục có tools/script-lib.ps1 — repo con nằm ở <gốc>/<repo> hoặc worktree <gốc>/.claude/worktrees/<repo>-w<N>):
#   $root = $PSScriptRoot
#   while (-not (Test-Path (Join-Path $root 'tools/script-lib.ps1'))) { $root = Split-Path $root; if (-not $root) { throw '…' } }
#   . (Join-Path $root 'tools/script-lib.ps1')

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
