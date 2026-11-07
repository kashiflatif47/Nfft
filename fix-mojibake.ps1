$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$app = "client/src/App.tsx"
$css = "client/src/styles.css"

# Create backups before editing
Copy-Item $app "$app.before-mojibake-fix.bak" -Force
Copy-Item $css "$css.before-mojibake-fix.bak" -Force

$lines = [System.Collections.Generic.List[string]]::new()
[System.IO.File]::ReadAllLines((Resolve-Path $app)) | ForEach-Object {
    $lines.Add($_)
}

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match 'Fee .*Net \$') {
        $lines[$i] = [regex]::Replace(
            $line,
            "\{\s*'[^']*\u00C3[^']*'\s*\}",
            "{' | '}"
        )
    }
    elseif ($line -match 'Business \$.*Commission \$') {
        $lines[$i] = [regex]::Replace(
            $line,
            '\u00C3.*?Commission',
            ' | Commission'
        )
    }
    elseif ($line -match 'm\.title&&<small>') {
        $lines[$i] = '            {m.title&&<small>{m.title}</small>}'
    }
    elseif ($line -match 'Privacy requests') {
        $lines[$i] = "    {heading:'Privacy requests',body:'For requests about personal information, write to [SUPPORT_EMAIL] with the subject Privacy Request. The operator may ask for reasonable verification before responding and may retain records where required by law.'},"
    }
    elseif ($line -match 'support-message') {
        $lines[$i] = [regex]::Replace(
            $line,
            '\u00C3.*?\{m\.createdAt',
            ' | {m.createdAt'
        )
    }
    elseif ($line -match 'conversation\?\.userId\?\.mobile') {
        $lines[$i] = [regex]::Replace(
            $line,
            '\u00C3.*?\$\{chat\.conversation\.userId\.mobile\}',
            '${chat.conversation.userId.mobile}'
        )
    }
    elseif ($line -match "senderRole==='member'") {
        $lines[$i] = [regex]::Replace(
            $line,
            '\u00C3.*?\{m\.createdAt',
            ' | {m.createdAt'
        )
    }
    elseif ($line -match 'paymentMethod') {
        $lines[$i] = [regex]::Replace(
            $line,
            "\{\s*'[^']*\u00C3[^']*'\s*\}",
            "{' | '}"
        )
    }
}

[System.IO.File]::WriteAllLines(
    (Resolve-Path $app),
    $lines,
    [System.Text.UTF8Encoding]::new($false)
)

$cssPath = (Resolve-Path $css).Path
$cssLines = [System.IO.File]::ReadAllLines($cssPath)

for ($i = 0; $i -lt $cssLines.Length; $i++) {
    if ($cssLines[$i] -match 'content:' -and $cssLines[$i] -match '\u00E2') {
        $cssLines[$i] = '  content: ">";'
    }
}

[System.IO.File]::WriteAllLines(
    $cssPath,
    $cssLines,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Targeted mojibake repairs completed. Backups created." -ForegroundColor Green