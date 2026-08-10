param(
  [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$qmdFiles = Get-ChildItem -Path $Root -Recurse -File -Filter "*.qmd" |
  Where-Object { $_.FullName -notmatch "[\\/]_site[\\/]" -and $_.FullName -notmatch "[\\/]docs[\\/]" }

$allCats = @()

foreach ($file in $qmdFiles) {
  $lines = Get-Content -Path $file.FullName
  $inYaml = $false
  $yamlSeen = $false
  $inCategories = $false

  foreach ($line in $lines) {
    if (-not $yamlSeen -and $line -match '^---\s*$') {
      $inYaml = $true
      $yamlSeen = $true
      continue
    }
    if ($inYaml -and $line -match '^---\s*$') {
      break
    }
    if (-not $inYaml) {
      continue
    }

    if ($line -match '^\s*categories\s*:\s*$') {
      $inCategories = $true
      continue
    }

    if ($inCategories) {
      if ($line -match '^\s*-\s*(.+?)\s*$') {
        $cat = $matches[1].Trim('"', "'").Trim()
        if ($cat) {
          $allCats += [pscustomobject]@{ Category = $cat; File = $file.FullName }
        }
        continue
      }

      if ($line -match '^\s*\w+\s*:') {
        $inCategories = $false
      }
    }
  }
}

if (-not $allCats.Count) {
  Write-Host "No categories found in frontmatter."
  exit 0
}

$groups = $allCats | Group-Object { $_.Category.ToLowerInvariant() }
$conflicts = @()

foreach ($g in $groups) {
  $variants = $g.Group | Select-Object -ExpandProperty Category -Unique
  if ($variants.Count -gt 1) {
    $conflicts += [pscustomobject]@{
      Key = $g.Name
      Variants = ($variants -join ", ")
      Files = ($g.Group | Select-Object -ExpandProperty File -Unique)
    }
  }
}

if ($conflicts.Count -eq 0) {
  Write-Host "Category casing check passed."
  exit 0
}

Write-Error "Category casing conflicts detected:`n$($conflicts | ForEach-Object { "- $($_.Variants)" } | Out-String)"
exit 1
