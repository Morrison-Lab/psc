lint_message <- "Name the arguments of aes\\(\\)"

test_that("unnamed aes() arguments are flagged", {
  lintr::expect_lint("aes(x, y = y)", lint_message, aes_args_named_linter())
  lintr::expect_lint("aes(x = x, y)", lint_message, aes_args_named_linter())
  lintr::expect_lint("aes(Lag1)", lint_message, aes_args_named_linter())
  lintr::expect_lint(
    "ggplot2::aes(day, y = Volume)",
    lint_message,
    aes_args_named_linter()
  )
  lintr::expect_lint(
    "df |> ggplot() + aes(to_hp(x), y = y)",
    lint_message,
    aes_args_named_linter()
  )
})

test_that("each unnamed argument gets its own lint", {
  lints <- lintr::lint(
    text = "aes(x, y, colour = g)",
    linters = list(aes_args_named_linter = aes_args_named_linter())
  )
  expect_length(lints, 2)
})

test_that("named aes() arguments are not flagged", {
  lintr::expect_no_lint("aes(x = x, y = y)", aes_args_named_linter())
  lintr::expect_no_lint(
    "df |> ggplot2::ggplot() + ggplot2::aes(x = day, y = Volume)",
    aes_args_named_linter()
  )
  lintr::expect_no_lint("geom_point(aes(colour = g))", aes_args_named_linter())
})

test_that("arguments that cannot take a name are not flagged", {
  lintr::expect_no_lint("aes(...)", aes_args_named_linter())
  lintr::expect_no_lint("aes(!!!mapping)", aes_args_named_linter())
  lintr::expect_no_lint("aes(!!mapping)", aes_args_named_linter())
  lintr::expect_lint("aes(..., x)", lint_message, aes_args_named_linter())
})

test_that("only ggplot2's aes() is checked", {
  lintr::expect_no_lint("obj$aes(x, y)", aes_args_named_linter())
  lintr::expect_no_lint("other::aes(x, y)", aes_args_named_linter())
  lintr::expect_lint("ggplot2::aes(x)", lint_message, aes_args_named_linter())
})

test_that("other functions' unnamed arguments are not flagged", {
  lintr::expect_no_lint("geom_point(data = d)", aes_args_named_linter())
  lintr::expect_no_lint("head(data, 1)", aes_args_named_linter())
})

test_that("default_linters(nested_calls = TRUE) includes it", {
  linters <- default_linters(nested_calls = TRUE)
  expect_true("aes_args_named_linter" %in% names(linters))
  expect_false("aes_args_named_linter" %in% names(default_linters()))
})
