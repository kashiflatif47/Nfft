$ErrorActionPreference = "Stop"

$file = Join-Path (Get-Location).Path "client\src\styles.css"

if (!(Test-Path $file)) {
    throw "styles.css not found. Run from project root."
}

$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$content = [System.IO.File]::ReadAllText($file, $utf8)
$marker = "ZIVOPLUS COMPLETE MAROON BACKGROUND PATCH"

if ($content.Contains($marker)) {
    throw "Complete background patch already exists. No changes made."
}

$backup = "$file.before-complete-background-$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
Copy-Item $file $backup

$css = @"

/* ZIVOPLUS COMPLETE MAROON BACKGROUND PATCH */

:root {
    --navy: #260800;
    --blue: #681600;
    --deep: #210600;
    --royal: #791900;
    --panel: #421000;
    --line: #d78b20;
    --gold: #ffca28;
    --light: #ffb52e;
    --muted: #e8c6a2;
}

html,
body {
    background: #210600 !important;
}

body {
    background: radial-gradient(circle at 20% 0, #681600 0, #260800 45%, #210600 100%) !important;
}

.auth-card,
.card,
.panel,
.package,
.modal,
.settings-box,
.upload-preview,
.member-id,
.form input,
.form select,
.form textarea,
.auth input {
    background: #421000 !important;
    border-color: #d78b20 !important;
}

.auth input,
.form input,
.form select,
.form textarea,
.upload-preview {
    background: #260800 !important;
}

.shell header,
.bottom {
    background: #260800 !important;
    border-color: #d78b20 !important;
}

.hero,
.banner,
.banner-carousel,
.deposit-method,
.capital-highlight,
.security-note,
.details,
.actions,
.notification-history,
.site-disclaimer,
.legal-page,
.banner-empty {
    background: linear-gradient(135deg, #260800, #421000 55%, #681600) !important;
    border-color: #d78b20 !important;
}

.package-art,
.banner-media,
.banner-fallback,
.banner-controls,
.banner-controls > button,
.actions a,
.list .row button,
.notice {
    background: #681600 !important;
    border-color: #d78b20 !important;
}

.banner-fallback {
    background: radial-gradient(circle at 30% 20%, #791900, #260800) !important;
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

.bottom a {
    color: #e8c6a2 !important;
}

.bottom a:hover {
    color: #ffca28 !important;
}

/* END ZIVOPLUS COMPLETE MAROON BACKGROUND PATCH */

"@

[System.IO.File]::AppendAllText($file, "`r`n$css", $utf8)

Write-Host "Complete Golden Maroon background patch applied." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Cyan
