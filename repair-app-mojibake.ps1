
$ErrorActionPreference = "Stop"

$file = Join-Path (Get-Location).Path "client\src\App.tsx"

if (!(Test-Path $file)) {
    throw "App.tsx not found."
}

$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$content = [System.IO.File]::ReadAllText($file, $utf8)
$lines = [System.IO.File]::ReadAllLines($file, $utf8)

if ($lines.Length -lt 3140) {
    throw "Unexpected App.tsx structure. No changes made."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = "$file.before-targeted-repair-$stamp.bak"
Copy-Item -LiteralPath $file -Destination $backup

# Repair payment method separator on line 529.
$lines[528] = [regex]::Replace(
    $lines[528],
    '\}\s+[^{}]+\s+\{d\.paymentMethod\}',
    '} | {d.paymentMethod}'
)

# Repair standalone separators on lines 852 and 1958.
foreach ($index in @(851, 1957)) {
    $lines[$index] = [regex]::Replace(
        $lines[$index],
        "\{'\s*[^']*'\s*\}",
        "{' | '}"
    )
}

# Repair package image movement controls.
$lines[3053] = [regex]::Replace(
    $lines[3053],
    '(onClick=\{\(\)=>moveImage\(preview,i,-1\)\}>).*?(</button>)',
    '$1Move up$2'
)

$lines[3053] = [regex]::Replace(
    $lines[3053],
    '(onClick=\{\(\)=>moveImage\(preview,i,1\)\}>).*?(</button>)',
    '$1Move down$2'
)

# Repair notification confirmation text.
$lines[3062] = [regex]::Replace(
    $lines[3062],
    'window\.confirm\(.*?\)',
    "window.confirm('Delete notification: ' + n.title + '?')"
)

# Repair banner confirmation text.
$lines[3086] = [regex]::Replace(
    $lines[3086],
    'window\.confirm\(.*?\)',
    "window.confirm('Delete banner: ' + b.title + '?')"
)

# Repair copyright text using ASCII.
$lines[3139] = [regex]::Replace(
    $lines[3139],
    '\u00C2\u00A9',
    '(c)'
)

$newContent = [string]::Join([Environment]::NewLine, $lines)

if ($newContent -eq $content) {
    Remove-Item -LiteralPath $backup
    throw "No changes were applied. Backup removed."
}

[System.IO.File]::WriteAllText($file, $newContent, $utf8)

Write-Host "Targeted App.tsx repairs completed." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Cyan
