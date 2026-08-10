# Copilot Collaboration Notes

Purpose: Keep content and publishing workflows consistent when using Copilot in this repo.

## Writing Workflow

1. Draft new content in `posts/*.qmd` (or `blog/*.qmd` for blog entries).
2. Render only the file you are editing while drafting.
3. Keep edits focused; avoid bulk changes to generated output unless intentionally doing a full site refresh.

## Commands

- Render one post:
  - `quarto render posts/<name>.qmd`
- Run pre-publish checks:
  - `powershell -ExecutionPolicy Bypass -File scripts/pre-publish.ps1`
- Publish to GitHub Pages (`gh-pages`):
  - `powershell -ExecutionPolicy Bypass -File scripts/publish-site.ps1`

## Commit Hygiene

- Prefer source-first commits (`*.qmd`, `_quarto.yml`, `styles.css`, helper scripts).
- If generated files change broadly, keep that in a separate commit.
- Before publish, run `git status --short` and confirm only intended files are modified.

## Review Checklist

- Category names use consistent casing.
- New local images/files referenced by posts exist.
- Track links and category pages render correctly.
- Category cloud renders on intended pages.
