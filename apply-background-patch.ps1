$ErrorActionPreference = "Stop"

$file = Join-Path (Get-Location).Path "client\src\styles.css"

if (!(Test-Path $file)) {
    throw "client/src/styles.css not found. Project root se run karo."
}

$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$content = [System.IO.File]::ReadAllText($file, $utf8)
$marker = "ZIVOPLUS MAROON BACKGROUND ONLY PATCH"

if ($content.Contains($marker)) {
    throw "Patch pehle se maujood hai. No changes made."
}

$backup = "$file.before-background-patch-$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
Copy-Item $file $backup

$css = @"

/* ZIVOPLUS MAROON BACKGROUND ONLY PATCH */
.capital-highlight,
.security-note,
.details,
.actions,
.notification-history,
.site-disclaimer,
.legal-page {
    background: linear-gradient(135deg, #260800, #421000 55%, #681600) !important;
    border-color: #d78b20 !important;
}

.support-message.member {
    background: #421000 !important;
    border-color: #d78b20 !important;
}

.support-message.admin {
    background: #681600 !important;
    border-color: #d78b20 !important;
}

.support-conversation:hover,
.support-conversation.selected {
    background: #421000 !important;
    border-color: #ffb52e !important;
}

.capital-highlight,
.security-note,
.details,
.actions,
.notification-history,
.site-disclaimer,
.legal-page,
.support-message.member,
.support-message.admin,
.support-conversation:hover,
.support-conversation.selected {
    box-shadow: 0 4px 18px rgba(0, 0, 0, 0.22) !important;
}
/* END ZIVOPLUS MAROON BACKGROUND ONLY PATCH */

"@

[System.IO.File]::AppendAllText($file, "`r`n$css", $utf8)

Write-Host "Golden Maroon background patch applied." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Cyan
