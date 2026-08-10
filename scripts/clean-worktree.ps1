param(
  [string[]]$Keep = @(
    'index.qmd',
    'blog.qmd',
    'CCC.qmd',
    'styles.css',
    '_quarto.yml',
    'README.md',
    'category-cloud.js',
    'category-cloud-include.html',
    'copilot-instructions.md',
    'scripts/check-category-case.ps1',
    'scripts/pre-publish.ps1',
    'scripts/publish-site.ps1',
    'scripts/clean-worktree.ps1',
    'posts/check_overdispersion.qmd',
    'posts/Hessian_and_likehood.qmd',
    'posts/OECD TG and Stats.qmd',
    'posts/Plant_Traits.qmd',
    'posts/PseudoR2.qmd',
    'posts/risk_report.qmd',
    'posts/Wan_paper_reading.qmd'
  )
)

$ErrorActionPreference = 'Stop'

function Normalize-PathText([string]$p) {
  return ($p -replace '\\', '/').Trim()
}

$keepSet = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($k in $Keep) {
  [void]$keepSet.Add((Normalize-PathText $k))
}

# 1) Restore tracked changes not explicitly kept.
$trackedChanged = git diff --name-only --
foreach ($f in $trackedChanged) {
  $n = Normalize-PathText $f
  if (-not $keepSet.Contains($n)) {
    git restore --source=HEAD -- "$f" | Out-Null
  }
}

# Also handle staged-but-not-working-tree differences.
$trackedStaged = git diff --name-only --cached --
foreach ($f in $trackedStaged) {
  $n = Normalize-PathText $f
  if (-not $keepSet.Contains($n)) {
    git restore --source=HEAD --staged --worktree -- "$f" | Out-Null
  }
}

# 2) Remove untracked files not explicitly kept.
$untracked = git ls-files --others --exclude-standard
foreach ($f in $untracked) {
  $n = Normalize-PathText $f
  if (-not $keepSet.Contains($n)) {
    if (Test-Path -LiteralPath $f) {
      Remove-Item -LiteralPath $f -Recurse -Force
    }
  }
}

Write-Host 'Cleanup complete. Current status:'
git status --short
