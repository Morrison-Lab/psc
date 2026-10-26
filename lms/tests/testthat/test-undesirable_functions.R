undesirable_linter <- function() {
  lintr::undesirable_function_linter(
    fun = undesirable_functions(),
    symbol_is_undesirable = TRUE
  )
}

test_that("base R functions with tidyverse replacements are flagged", {
  lintr::expect_lint(
    "grep('a', x)",
    "use stringr::str_which()",
    undesirable_linter()
  )
  lintr::expect_lint(
    "d <- data.frame(a = 1)",
    "use tibble::tibble()",
    undesirable_linter()
  )
  lintr::expect_lint(
    "read.csv('a.csv')",
    "use readr::read_csv()",
    undesirable_linter()
  )
  lintr::expect_lint(
    "sessionInfo()",
    "use sessioninfo::session_info()",
    undesirable_linter()
  )
})

test_that("rbind() and cbind() point to the matrix exception", {
  lintr::expect_lint(
    "cbind(a, b)",
    "use dplyr::bind_cols\\(\\) \\(or `# nolint` for matrices\\)",
    undesirable_linter()
  )
  lintr::expect_lint(
    "rbind(a, b)",
    "use dplyr::bind_rows\\(\\) \\(or `# nolint` for matrices\\)",
    undesirable_linter()
  )
})

test_that("the tidyverse replacements themselves are not flagged", {
  lintr::expect_no_lint("dplyr::bind_cols(a, b)", undesirable_linter())
  lintr::expect_no_lint("stringr::str_which(x, 'a')", undesirable_linter())
})
