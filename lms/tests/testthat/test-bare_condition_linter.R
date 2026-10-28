test_that("a non-bare if() condition is flagged", {
  lintr::expect_lint(
    "if (is.na(x)) 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
  lintr::expect_lint(
    "if (sum(lengths(x) == 1)) 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
  lintr::expect_lint(
    "if (a) 1 else if (b > 1) 2",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
})

test_that("a non-bare while() condition is flagged", {
  lintr::expect_lint(
    "while (i < 3) i <- i + 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
})

test_that("bare names and logical literals are not flagged", {
  lintr::expect_no_lint("if (single_plot) 1", bare_condition_linter())
  lintr::expect_no_lint("while (TRUE) break", bare_condition_linter())
  lintr::expect_no_lint("while (not_done) 1", bare_condition_linter())
  lintr::expect_no_lint("if (x # a comment\n) 1", bare_condition_linter())
})

test_that("negated, parenthesized, and numeric conditions are flagged", {
  lintr::expect_lint(
    "if (!x) 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
  lintr::expect_lint(
    "if ((x)) 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
  lintr::expect_lint(
    "if (1) 1",
    "Assign the condition to a named logical variable",
    bare_condition_linter()
  )
})
