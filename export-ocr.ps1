# Nén model OCR ra release/fastcast: xem export-ocr.sh. `-Models <thư mục>` đổi nguồn. Windows chạy qua Git Bash.
param([string]$Models)
$bash = Join-Path (Split-Path (Split-Path (Get-Command git).Source)) 'bin/bash.exe'
& $bash (Join-Path $PSScriptRoot 'export-ocr.sh') $(if ($Models) { $Models -replace '\\', '/' })
exit $LASTEXITCODE
