## Some Notes

-   [Site URL](https://zhenglei-bcs.github.io/)


## Writing Posts

- Start posts in the posts folder as .qmd. 
- Render a single post while drafting: `quarto render posts/<name>.qmd`

## Pre-Publish Check

- Run checks before commit/publish:
	- `powershell -ExecutionPolicy Bypass -File scripts/pre-publish.ps1`
- Optional full site render before checks:
	- `powershell -ExecutionPolicy Bypass -File scripts/pre-publish.ps1 -Render`

This validates:
- category case consistency,
- missing generated post HTML,
- missing local asset references in rendered post pages.

## Publish (One Command)

- Recommended end-to-end flow:
	- `powershell -ExecutionPolicy Bypass -File scripts/publish-site.ps1`

Optional flags:
- `-Render` : run full site render as part of pre-publish checks.
- `-NoPrompt` : pass `--no-prompt` to Quarto publish.
- `-SkipChecks` : publish directly without running pre-publish checks.

After publish, if the live page still appears old, verify GitHub Pages source is set to `gh-pages` and `/ (root)`.

## Copilot Collaboration

- See `copilot-instructions.md` for workflow and style preferences while co-writing posts and publishing.
