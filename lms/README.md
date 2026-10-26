# lms --- Lab Manual Style

`lms` ("lab manual style") is the shared UCD-SERG
[`{lintr}`](https://lintr.r-lib.org/) configuration.
It is packaged as a small R package
so every lab repository enforces the **same** linter set
without copy-pasting `.lintr.R` files,
which drift apart over time.

It lives in the `lms/` subdirectory of
[`Morrison-Lab/psc`](https://github.com/Morrison-Lab/psc),
the repository behind
[Principles of Scientific Computing](https://morrison-lab.github.io/psc/).
It was written for, and first kept in, the
[UCD-SERG lab manual](https://github.com/UCD-SERG/lab-manual),
and moved here with its history in October 2026.
It exports:

- `default_linters()` --- the canonical linter set:
  `lintr::linters_with_defaults()` plus the lab's rules.
  Those rules are `|>` pipe consistency,
  snake_case-with-acronyms object names,
  `cli::`-oriented undesirable functions
  and the tidyverse replacements for `data.frame()`, `read.csv()`, `rbind()`, `cbind()`, `gsub()` and the rest of the coding-style chapter's list,
  function-location and function-length checks,
  and condition-class assertions for `testthat` expectations that match `regexp`.
- `undesirable_functions()` --- the underlying undesirable-function map,
  if a repo needs to extend it.

## Using lms in a repository

Each applied repo keeps a thin `.lintr.R`
that calls `lms::default_linters()`
and supplies its **own** local exclusions:

```r
# .lintr.R
if (!requireNamespace("lms", quietly = TRUE)) {
  stop(  # nolint: undesirable_function_linter. .lintr.R is config, not package code.
    "Package 'lms' is required to lint this project. Install it with:\n",
    "  install.packages('remotes')\n",
    "  remotes::install_github(\n",
    "    'Morrison-Lab/psc/lms@3d92ab2bb1115231ebee5ef071e2f4669b160945'\n",
    "  )",
    call. = FALSE
  )
}
linters <- lms::default_linters()

# Exclusions are repo-specific and stay LOCAL --- do not move them into lms.
exclusions <- list(
  `data-raw` = list(pipe_consistency_linter = Inf)
)
```

Install `lms` in CI with an **explicit** step in the lint workflow,
before linting:

```yaml
- name: Install lms (shared linter config)
  run: |
    install.packages("remotes")
    remotes::install_github(
      "Morrison-Lab/psc/lms@3d92ab2bb1115231ebee5ef071e2f4669b160945"
    )
  shell: Rscript {0}
```

For local linting, install `lms` once the same way.

The commit in these examples installs lms 0.1.1,
which predates 0.1.2's handling of a positional `class` argument.
Pin a full commit SHA of psc `main`, as here,
until `lms` has release tags (see [Versioning](#versioning)).

## Do NOT declare lms in DESCRIPTION

`lms` is **lint-only tooling, not a runtime dependency**:
it is a linter configuration, not something your package calls.
Keep it out of `Imports` and `Suggests`,
and do not add a `Remotes:` entry for it.
There are two reasons:

1. **`{pak}` cannot resolve the subdir Remote.**
   A reference to a package in a repo *subdirectory*,
   such as `Morrison-Lab/psc/lms@<ref>`,
   resolves with the `{remotes}` package
   but **not** with `{pak}` or `r-lib/actions/setup-r-dependencies`,
   which fail with `Can't find package called lms`.
   If `lms` is in `Suggests`,
   that failure breaks *every* `{pak}`-based workflow in the consuming repo
   (for example, a bibliography/DOI check),
   even ones unrelated to linting.
2. **CRAN hygiene.**
   `.lintr.R` is a dev-time config file, not test code,
   so `R CMD check` never executes it.
   There is no CRAN footprint,
   and a linter config has no place in a package's declared dependency graph.

The version pin lives in the CI `install_github(...@<ref>)` step,
not in DESCRIPTION.

## Versioning

`lms` releases are meant to be git **tags** on psc `main`,
named `lms-v` plus the `Version:` in `lms/DESCRIPTION`
(for example, `lms-v0.1.2`).
The `lms-` prefix keeps these tags apart from anything else the repository tags.
No `lms-v` tag exists yet,
so pin a commit SHA in the meantime.

To roll out a rule change:
merge it to `main`, bump `Version:`, cut a new tag,
then bump the `@<ref>` in each consuming repo's lint workflow when ready.
Pinning to a tag or commit (not `main`)
means routine edits to the guide never churn downstream linting.

Releases before the move are tags on the lab manual
(`remotes::install_github("UCD-SERG/lab-manual/lms@v0.1.0")`),
and they still install from there.

## Developing lms

Because `default_linters()` includes `object_usage_linter()`,
lint **this** package with the source loaded
so symbols (and `.onLoad()` side effects) resolve correctly.
From the `lms/` directory, run:

```r
pkgload::load_all()
lintr::lint_package()
```

`lms/.lintr.R` sets the linters (`default_linters()`) and exclusions.
It has to be there:
lintr looks for a config in parent directories too,
so without it, linting `lms/` inside psc would read psc's root `.lintr.R`,
which excludes `lms/` and so reports no lints at all.
psc's `lint-lms` CI job runs the same two calls from the repository root,
passing `"lms"` as the path to each.

`.onLoad()` calls `rex::register_shortcuts()`
so the `{rex}` DSL tokens used in the snake_case regex
are not flagged as undefined globals.
After editing `R/` roxygen comments, run `devtools::document()`.
