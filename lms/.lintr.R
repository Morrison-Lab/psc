# lms's own lint config, so linting lms reads this file
# rather than inheriting psc's root .lintr.R (which excludes lms/).
# lms is lint-checked with its own linter set; load its source first
# (pkgload::load_all()) so lms::default_linters() resolves.
linters <- lms::default_linters()

exclusions <- list(
  "tests/testthat.R" = list(undesirable_function_linter = Inf)
)
