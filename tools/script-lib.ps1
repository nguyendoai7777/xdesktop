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

# Ô tích, chọn được nhiều: ↑ ↓ di chuyển, Space tích / bỏ, Enter xác nhận (phải tích ít nhất một mục). $Checked: id tích sẵn.
# Stdin là pipe ⇒ gõ số cách bằng dấu phẩy; Enter = các mục tích sẵn (không có thì mục đầu). Trả về mảng id theo thứ tự danh sách.
function Select-Many([string] $Title, [object[]] $Options, [string[]] $Checked = @()) {
    if ($Options.Count -eq 1) { Write-Host "$Title $($Options[0].Label)"; return @($Options[0].Id) }
    $flags = [bool[]]@($Options | ForEach-Object { $_.Id -in $Checked })
    if (-not [Console]::IsInputRedirected) {
        $esc = [char]27
        $cursor = [Math]::Max(0, [array]::IndexOf($flags, $true))
        $hint = '↑ ↓ di chuyển · space tích / bỏ · enter xác nhận'
        Write-Host $Title
        [Console]::Write("$esc[?25l")
        try {
            while ($true) {
                for ($i = 0; $i -lt $Options.Count; $i++) {
                    $box = if ($flags[$i]) { '[x]' } else { '[ ]' }
                    $line = if ($i -eq $cursor) { "$esc[36m$box $($Options[$i].Label)$esc[0m" } else { "$box $($Options[$i].Label)" }
                    [Console]::Write("`r$esc[2K$line`n")
                }
                [Console]::Write("`r$esc[2K$esc[2m$hint$esc[0m")
                $key = [Console]::ReadKey($true)
                [Console]::Write("`r$esc[$($Options.Count)A")
                switch ($key.Key) {
                    'UpArrow' { $cursor = ($cursor + $Options.Count - 1) % $Options.Count }
                    'DownArrow' { $cursor = ($cursor + 1) % $Options.Count }
                    'Spacebar' { $flags[$cursor] = -not $flags[$cursor] }
                    'Enter' {
                        $picked = @(for ($i = 0; $i -lt $Options.Count; $i++) { if ($flags[$i]) { $Options[$i] } })
                        if ($picked.Count) {
                            # Xoá cả dòng tiêu đề rồi in lại kèm lựa chọn.
                            [Console]::Write("$esc[1A`r$esc[J")
                            Write-Host "$Title $(($picked | ForEach-Object Label) -join ', ')"
                            return @($picked.Id)
                        }
                        $hint = 'chưa tích mục nào, bấm space để tích'
                    }
                }
            }
        } finally {
            [Console]::Write("$esc[?25h")
        }
    }
    $defaults = @(for ($i = 0; $i -lt $Options.Count; $i++) { if ($flags[$i]) { $i + 1 } })
    if (-not $defaults.Count) { $defaults = @(1) }
    Write-Host $Title
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  [{0}] {1}{2}" -f ($i + 1), $Options[$i].Label, $(if (($i + 1) -in $defaults) { '  (Enter)' }))
    }
    while ($true) {
        Write-Host -NoNewline 'Chọn (nhiều mục thì cách bằng dấu phẩy): '
        $answer = [Console]::In.ReadLine()
        $picks = if ([string]::IsNullOrWhiteSpace($answer)) { $defaults } else { @($answer -split '[,\s]+' | Where-Object { $_ }) }
        $n = 0
        if (-not ($picks | Where-Object { -not ([int]::TryParse("$_", [ref]$n) -and $n -ge 1 -and $n -le $Options.Count) })) {
            $set = @($picks | ForEach-Object { [int]"$_" })
            return @(for ($i = 0; $i -lt $Options.Count; $i++) { if (($i + 1) -in $set) { $Options[$i].Id } })
        }
        Write-Host "Nhập số từ 1 đến $($Options.Count), vd 1,2."
    }
}
