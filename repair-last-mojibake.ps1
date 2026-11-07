
$ErrorActionPreference = "Stop"

$file = Join-Path (Get-Location).Path "client\src\App.tsx"
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$content = [System.IO.File]::ReadAllText($file, $utf8)

$pattern = 'days[^<>{}\r\n]{1,80}(\{Number\(p\.profitPercent)'
$count = [regex]::Matches($content, $pattern).Count

if ($count -ne 1) {
    throw "Expected exactly one matching separator. Found: $count. No changes made."
}

$backup = "$file.before-final-mojibake-repair-$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
Copy-Item $file $backup

$fixed = [regex]::Replace($content, $pattern, 'days | $1', 1)
[System.IO.File]::WriteAllText($file, $fixed, $utf8)

Write-Host "Final confirmed separator repaired." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Cyan
