param(
  [switch]$Render
)

$ErrorActionPreference = "Stop"

Write-Host "[1/3] Checking category case consistency..."
powershell -ExecutionPolicy Bypass -File "scripts/check-category-case.ps1"

if ($Render) {
  Write-Host "[2/3] Rendering full site..."
  quarto render
} else {
  Write-Host "[2/3] Skipping full site render (use -Render to enable)."
}

Write-Host "[3/3] Checking for obvious missing local asset references in rendered posts..."
$renderedPosts = Get-ChildItem -Path "docs/posts" -File -Filter "*.html" -ErrorAction SilentlyContinue

$missing = @()
foreach ($html in $renderedPosts) {
  $content = Get-Content -Path $html.FullName -Raw
  $matches = [regex]::Matches($content, 'src="([^"]+)"|href="([^"]+)"')
  foreach ($m in $matches) {
    $p = if ($m.Groups[1].Value) { $m.Groups[1].Value } else { $m.Groups[2].Value }
    if (-not $p) { continue }
    if ($p -match '^(https?:|mailto:|#|javascript:|data:)') { continue }
    if ($p -match '^/') { continue }

    $target = Join-Path $html.DirectoryName $p
    if (-not (Test-Path -LiteralPath $target)) {
      $missing += "$($html.Name): $p"
    }
  }
}

if ($missing.Count -gt 0) {
  Write-Warning "Potential missing local assets detected:"
  $missing | Select-Object -Unique | ForEach-Object { Write-Host " - $_" }
}

Write-Host "Pre-publish checks completed."
