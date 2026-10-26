test_that("a call passed straight to another call is flagged", {
  lintr::expect_lint(
    "f(g(x))",
    "Don't nest function calls",
    nested_call_linter()
  )
  lintr::expect_lint(
    "pkg::f(pkg::g(x))",
    "Don't nest function calls",
    nested_call_linter()
  )
  lintr::expect_lint(
    "f(a = g(x))",
    "Don't nest function calls",
    nested_call_linter()
  )
})

test_that("each nesting level is flagged", {
  lintr::expect_lint(
    "f(g(h(x)))",
    list(
      list(message = "Don't nest function calls"),
      list(message = "Don't nest function calls")
    ),
    nested_call_linter()
  )
})

test_that("named intermediates and pipes are not flagged", {
  lintr::expect_no_lint("y <- g(x)\nf(y)", nested_call_linter())
  lintr::expect_no_lint("x |> g() |> f()", nested_call_linter())
  lintr::expect_no_lint("f(x[1])", nested_call_linter())
  lintr::expect_no_lint("f(function(z) g(z))", nested_call_linter())
  lintr::expect_no_lint("f(~ g(x))", nested_call_linter())
})

test_that("tidyselect helpers and aes() are allowed as arguments", {
  lintr::expect_no_lint("select(df, all_of(v))", nested_call_linter())
  lintr::expect_no_lint("ggplot(d, aes(x = x))", nested_call_linter())
})

test_that("arguments of data-masking verbs are allowed", {
  lintr::expect_no_lint("mutate(df, a = log(b))", nested_call_linter())
  lintr::expect_no_lint(
    "ggplot(d) + geom_point(aes(x = f(y)))",
    nested_call_linter()
  )
})

test_that("a call wrapped in an operator is not flagged", {
  lintr::expect_no_lint("f(a + g(x))", nested_call_linter())
  lintr::expect_no_lint("f(!g(x))", nested_call_linter())
  lintr::expect_no_lint("f((g(x)))", nested_call_linter())
})

test_that("nothing inside a data-masking verb is flagged", {
  lintr::expect_no_lint("mutate(df, a = f(g(b)))", nested_call_linter())
  lintr::expect_no_lint("quote(f(g(x)))", nested_call_linter())
  lintr::expect_no_lint("bquote(f(g(x)))", nested_call_linter())
})

test_that("an empty allow-list flags every nested call", {
  lintr::expect_lint(
    "mutate(df, a = f(g(b)))",
    list(
      list(message = "Don't nest function calls"),
      list(message = "Don't nest function calls")
    ),
    nested_call_linter(data_masking_verbs = character())
  )
  lintr::expect_lint(
    "select(df, all_of(v))",
    "Don't nest function calls",
    nested_call_linter(tidyselect_helpers = character())
  )
})

test_that("default_linters() adds the nesting linters only on request", {
  off <- names(default_linters())
  on <- names(default_linters(nested_calls = TRUE))
  expect_false(any(c("nested_call_linter", "bare_condition_linter") %in% off))
  expect_true(all(c("nested_call_linter", "bare_condition_linter") %in% on))
})
