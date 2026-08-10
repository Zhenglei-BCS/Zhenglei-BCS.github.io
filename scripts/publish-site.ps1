param(
  [switch]$Render,
  [switch]$NoPrompt,
  [switch]$SkipChecks
)

$ErrorActionPreference = "Stop"

if (-not $SkipChecks) {
  Write-Host "Running pre-publish checks..."
  if ($Render) {
    powershell -ExecutionPolicy Bypass -File "scripts/pre-publish.ps1" -Render
  } else {
    powershell -ExecutionPolicy Bypass -File "scripts/pre-publish.ps1"
  }
}

$cmd = "quarto publish gh-pages --no-browser"
if ($NoPrompt) {
  $cmd += " --no-prompt"
}

Write-Host "Publishing with: $cmd"
Invoke-Expression $cmd

if ($LASTEXITCODE -ne 0) {
  throw "Publish failed with exit code $LASTEXITCODE"
}

Write-Host "Publish step finished."
