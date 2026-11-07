
$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$folders = @(
    "client/src",
    "client/public",
    "server/src",
    "server/tests"
)

$extensions = @(
    ".ts", ".tsx", ".js", ".jsx", ".css",
    ".scss", ".html", ".json", ".svg", ".xml",
    ".yml", ".yaml", ".md", ".txt", ".sql"
)

$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$cp1252 = [System.Text.Encoding]::GetEncoding(
    1252,
    [System.Text.EncoderExceptionFallback]::new(),
    [System.Text.DecoderExceptionFallback]::new()
)

$markers = @(
    [string][char]0x00C3,
    [string][char]0x00C2,
    [string][char]0x00E2,
    [string][char]0x00EF,
    [string][char]0xFFFD
)

function Get-Score([string]$s) {
    $n = 0
    foreach ($m in $markers) {
        $n += [regex]::Matches($s, [regex]::Escape($m)).Count
    }
    return $n
}

function Convert-Layer([string]$s) {
    try {
        $bytes = $cp1252.GetBytes($s)
        return $utf8.GetString($bytes)
    }
    catch {
        return $null
    }
}

$scanned = 0
$changed = 0
$review = 0

foreach ($folder in $folders) {
    $base = Join-Path $root $folder
    if (!(Test-Path $base)) { continue }

    $files = Get-ChildItem -LiteralPath $base -Recurse -File |
        Where-Object {
            $extensions -contains $_.Extension.ToLower() -and
            $_.FullName -notmatch '[\\/](node_modules|\.git|dist|build|coverage|backup[^\\/]*|_backup[^\\/]*|patch-backup[^\\/]*)[\\/]'
        }

    foreach ($file in $files) {
        $scanned++

        try {
            $original = [System.IO.File]::ReadAllText($file.FullName, $utf8)
            $current = $original
            $before = Get-Score $current

            if ($before -eq 0) { continue }

            for ($i = 0; $i -lt 3; $i++) {
                $candidate = Convert-Layer $current
                if ($null -eq $candidate) { break }

                if ((Get-Score $candidate) -lt (Get-Score $current)) {
                    $current = $candidate
                }
                else {
                    break
                }
            }

            if ($current -ne $original) {
                $backup = "$($file.FullName).before-mojibake-$stamp.bak"
                Copy-Item -LiteralPath $file.FullName -Destination $backup
                [System.IO.File]::WriteAllText($file.FullName, $current, $utf8)

                $changed++
                Write-Host "REPAIRED: $($file.FullName)" -ForegroundColor Green
            }
            else {
                $review++
                Write-Host "MANUAL REVIEW: $($file.FullName)" -ForegroundColor Yellow
            }
        }
        catch {
            $review++
            Write-Host "SKIPPED: $($file.FullName)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Scanned: $scanned"
Write-Host "Repaired: $changed"
Write-Host "Manual review / skipped: $review"
Write-Host "Backups created beside changed files."

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

