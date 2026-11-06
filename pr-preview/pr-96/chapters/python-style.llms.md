# Python Code Style

Code

Published

Last modified: 2026-11-06 13:34:54 (PST)

# 1 Base guide

The lab’s Python style is an amendment of [Google’s Python style guide](https://github.com/Morrison-Lab/styleguide/blob/c03dfce4e1763d032e33696d126e5af4c7de03bf/pyguide.md), read in the lab’s fork at a pinned commit. Follow that guide for everything the amendments below do not change. Google’s current wording is at [google.github.io/styleguide/pyguide.html](https://google.github.io/styleguide/pyguide.html).

# 2 Amendments

## 2.1 Linting and formatting with Ruff

[Ruff](https://docs.astral.sh/ruff/) replaces the pylint configuration and the Pyink formatter that Google’s guide mentions. It lints and formats in one tool.

- Lint settings live in the lab’s `python/ruff.toml` in the `Morrison-Lab/psc` repository. Copy it to the root of a repository as `ruff.toml`.
- Line length stays at 80 characters, as in Google’s guide.
- Docstrings follow Google’s format.
- Rule families are pycodestyle, pyflakes, isort, pydocstyle, pyupgrade, bugbear, comprehensions and simplify.

CI runs the checks and fails on any finding.

## 2.2 No nested function calls

The lab’s [no-nested-calls rule](../chapters/coding-style.llms.md#sec-avoid-nesting) applies to Python. Give each intermediate result a name. Method chaining is fine. Ruff cannot check this rule, so it is not yet enforced.

# 3 Planned work

- Run the checks through `Morrison-Lab/gha`’s `check-python-package` workflow in every repository that contains Python.
- Run `check-python-qmd-chunks` in every repository whose `.qmd` files contain Python chunks.
- Open an issue when upstream changes Google’s guide.

These are tracked in [\#90](https://github.com/Morrison-Lab/psc/issues/90).

Back to top
