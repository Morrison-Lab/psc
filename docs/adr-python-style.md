# ADR: Python style as an amendment of Google's guide

## Status

Accepted for the base guide and the Ruff tooling (Ezra, 2026-11-04).
Proposed, awaiting Ezra's confirmation: the lab fork as the default reference.

## Context

The lab has an R style guide and the shared `lms` lintr package, and nothing for Python.
Google publishes a Python style guide, and the lab forked it as
[`Morrison-Lab/styleguide`](https://github.com/Morrison-Lab/styleguide) for review.
`Morrison-Lab/gha` already has a `check-python-package.yml` workflow that runs Ruff, but no repository calls it.
Google's guide assumes pylint and the Pyink formatter.
Upstream can reword or renumber the sections that the lab's amendments cite.

## Decision

- We will write the lab style as an amendment of Google's guide, not from scratch (Ezra, 2026-11-04).
- We will link the lab fork at a pinned commit of `pyguide.md` as the default reference for anything the amendments do not cover.
  Syncing from upstream will be a reviewed pull request in the fork.
  The pinned commit is `c03dfce4e1763d032e33696d126e5af4c7de03bf`.
- We will use Ruff for linting and formatting, in place of pylint and Pyink.
- We will keep Google's 80-character line length and Google's docstring format
  (`lint.pydocstyle.convention = "google"`).
- We will enable these rule families: pycodestyle, pyflakes, isort, pydocstyle, pyupgrade, bugbear, comprehensions and simplify.
  Adding a family needs a written reason in a new or superseding ADR.
- The lab's no-nested-calls rule applies to Python.

## Consequences

- Repositories copy `python/ruff.toml` to their root, and CI fails on findings.
- Ruff has no rule for nested calls, so that amendment needs a custom check before it is enforced.
- Python chunks in `.qmd` files are not linted until the extraction check in [#90](https://github.com/Morrison-Lab/psc/issues/90) lands.
- Pinning the fork means someone must sync it from upstream on purpose; a weekly watcher will open an issue when upstream changes.
