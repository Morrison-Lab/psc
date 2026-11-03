aes_message <- "Don't nest aes\\(\\) inside ggplot\\(\\)"
data_message <- "Don't pass data to ggplot\\(\\)"

test_that("aes() inside ggplot() is flagged", {
  lintr::expect_lint(
    "ggplot(aes(x, y))",
    aes_message,
    ggplot_args_linter()
  )
  lintr::expect_lint(
    "ggplot2::ggplot(ggplot2::aes(x, y))",
    aes_message,
    ggplot_args_linter()
  )
  lintr::expect_lint(
    "ggplot(mapping = aes(x, y))",
    aes_message,
    ggplot_args_linter()
  )
  lintr::expect_lint(
    "df |> ggplot2::ggplot(ggplot2::aes(x, y))",
    aes_message,
    ggplot_args_linter()
  )
})

test_that("data passed to ggplot() is flagged", {
  lintr::expect_lint("ggplot(df)", data_message, ggplot_args_linter())
  lintr::expect_lint(
    "ggplot(data = df)",
    data_message,
    ggplot_args_linter()
  )
  lintr::expect_lint(
    "ggplot2::ggplot(df) + aes(x, y)",
    data_message,
    ggplot_args_linter()
  )
  lintr::expect_lint(
    "ggplot(read_csv(path))",
    data_message,
    ggplot_args_linter()
  )
})

test_that("data and mapping together give one lint each", {
  lints <- lintr::lint(
    text = "ggplot(df, aes(x, y))",
    linters = list(ggplot_args_linter = ggplot_args_linter())
  )
  messages <- vapply(lints, function(lint) lint$message, character(1))
  expect_match(messages[1], data_message)
  expect_match(messages[2], aes_message)
  expect_length(lints, 2)
})

test_that("the piped form with aes() as its own layer is not flagged", {
  lintr::expect_no_lint(
    "df |> ggplot2::ggplot() + ggplot2::aes(x, y)",
    ggplot_args_linter()
  )
  lintr::expect_no_lint("ggplot()", ggplot_args_linter())
})

test_that("aes() inside a layer is not flagged", {
  lintr::expect_no_lint(
    "df |> ggplot() + aes(x, y) + geom_point(aes(colour = g))",
    ggplot_args_linter()
  )
  lintr::expect_no_lint(
    "ggplot2::geom_point(ggplot2::aes(colour = g))",
    ggplot_args_linter()
  )
})

test_that("default_linters(nested_calls = TRUE) includes it", {
  linters <- default_linters(nested_calls = TRUE)
  expect_true("ggplot_args_linter" %in% names(linters))
  expect_false("ggplot_args_linter" %in% names(default_linters()))
})
