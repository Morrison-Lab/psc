message <- "Don't nest aes\\(\\) inside ggplot\\(\\)"

test_that("aes() inside ggplot() is flagged", {
  lintr::expect_lint(
    "ggplot(df, aes(x, y))",
    message,
    ggplot_aes_linter()
  )
  lintr::expect_lint(
    "ggplot(aes(x, y))",
    message,
    ggplot_aes_linter()
  )
})

test_that("the namespaced and named forms are flagged", {
  lintr::expect_lint(
    "ggplot2::ggplot(df, ggplot2::aes(x, y))",
    message,
    ggplot_aes_linter()
  )
  lintr::expect_lint(
    "ggplot(df, mapping = aes(x, y))",
    message,
    ggplot_aes_linter()
  )
  lintr::expect_lint(
    "df |> ggplot2::ggplot(ggplot2::aes(x, y))",
    message,
    ggplot_aes_linter()
  )
})

test_that("aes() added as its own layer is not flagged", {
  lintr::expect_no_lint(
    "df |> ggplot2::ggplot() + ggplot2::aes(x, y)",
    ggplot_aes_linter()
  )
  lintr::expect_no_lint(
    "fig_aes <- aes(x, y)\nggplot(df, fig_aes)",
    ggplot_aes_linter()
  )
  lintr::expect_no_lint("ggplot(df)", ggplot_aes_linter())
})

test_that("aes() inside a layer is not flagged", {
  lintr::expect_no_lint(
    "ggplot(df, fig_aes) + geom_point(aes(colour = g))",
    ggplot_aes_linter()
  )
  lintr::expect_no_lint(
    "ggplot2::geom_point(ggplot2::aes(colour = g))",
    ggplot_aes_linter()
  )
})

test_that("default_linters(nested_calls = TRUE) includes it", {
  linters <- default_linters(nested_calls = TRUE)
  expect_true("ggplot_aes_linter" %in% names(linters))
  expect_false("ggplot_aes_linter" %in% names(default_linters()))
})
