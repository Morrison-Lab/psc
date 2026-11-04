# Python style decisions

Each entry records a decision, who made it, and why.
The lab Python style is an amendment of Google's Python style guide.
Anything the amendments do not cover follows Google's guide.

## Base guide (Ezra, 2026-11-04)

- Amend Google's guide instead of writing one from scratch.
- Default reference: the lab fork
  [`Morrison-Lab/styleguide`](https://github.com/Morrison-Lab/styleguide),
  linked at a pinned commit of `pyguide.md`.
  Upstream can reword or renumber sections that the amendments cite.
  Syncing from upstream is a reviewed pull request in the fork.
  Status: proposed by Claude, awaiting Ezra's confirmation.
- Pinned commit: `c03dfce4e1763d032e33696d126e5af4c7de03bf`.

## Tooling

- Ruff replaces Google's pylint configuration and the Pyink formatter.
  It is one tool for lint and format, and
  `Morrison-Lab/gha`'s `check-python-package.yml` already runs it.
- Line length stays at Google's 80 characters.
- Docstrings follow Google's format
  (`lint.pydocstyle.convention = "google"`).
- Rule families: pycodestyle, pyflakes, isort, pydocstyle, pyupgrade,
  bugbear, comprehensions and simplify.
  Add a family only with a written reason here.

## Not yet enforced

- No nested function calls
  (the lab rule from [avoiding deep nesting](https://morrison-lab.github.io/psc/chapters/coding-style.html#sec-avoid-nesting)
  applies to Python); Ruff has no such rule, so a custom check is needed.
- Linting Python chunks in `.qmd` files (planned, [#90](https://github.com/Morrison-Lab/psc/issues/90)).
