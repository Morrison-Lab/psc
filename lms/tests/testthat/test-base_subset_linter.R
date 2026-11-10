message_pattern <- "Don't subset a data frame with base"

test_that("an empty row or column index is flagged", {
  lintr::expect_lint("df[df$x > 0, ]", message_pattern, base_subset_linter())
  lintr::expect_lint("df[, \"y\"]", message_pattern, base_subset_linter())
  lintr::expect_lint(
    "df[, c(\"a\", \"b\")]",
    message_pattern,
    base_subset_linter()
  )
  lintr::expect_lint(
    "x[i, , drop = FALSE]",
    message_pattern,
    base_subset_linter()
  )
})

test_that("vector and list indexing is not flagged", {
  lintr::expect_no_lint("x[i]", base_subset_linter())
  lintr::expect_no_lint("x[-1]", base_subset_linter())
  lintr::expect_no_lint("lst[[i]]", base_subset_linter())
  lintr::expect_no_lint("df$y[is_train]", base_subset_linter())
})

test_that("the dplyr form is not flagged", {
  lintr::expect_no_lint(
    "df |> dplyr::filter(x > 0) |> dplyr::select(y)",
    base_subset_linter()
  )
})

test_that("default_linters(nested_calls = TRUE) includes it", {
  linters <- default_linters(nested_calls = TRUE)
  expect_true("base_subset_linter" %in% names(linters))
  expect_false("base_subset_linter" %in% names(default_linters()))
})
