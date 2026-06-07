# build.ps1 — inline styles.css and app.js into a single portable HTML file.
# Output: dist/coin-quest.html
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot

$html = Get-Content (Join-Path $dir 'index.html') -Raw
$css  = Get-Content (Join-Path $dir 'styles.css') -Raw
$js   = Get-Content (Join-Path $dir 'app.js') -Raw

# literal (.Replace) — NOT -replace — so $ and {} in CSS/JS are left untouched
$html = $html.Replace('<link rel="stylesheet" href="styles.css" />', "<style>`n$css`n</style>")
$html = $html.Replace('<script src="app.js"></script>', "<script>`n$js`n</script>")

$out = Join-Path $dir 'dist'
New-Item -ItemType Directory -Force $out | Out-Null
$target = Join-Path $out 'coin-quest.html'

# write UTF-8 without BOM
[System.IO.File]::WriteAllText($target, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Built $target ($([math]::Round((Get-Item $target).Length / 1kb, 1)) KB)"
