test_that("expect_error with positional regexp and no class is flagged", {
  lintr::expect_lint(
    'expect_error(f(), "bad input")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})

test_that("expect_error with named regexp and no class is flagged", {
  lintr::expect_lint(
    'expect_error(f(), regexp = "bad input")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})

test_that("expect_warning with regexp and no class is flagged", {
  lintr::expect_lint(
    'expect_warning(f(), regexp = "deprecated")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})

test_that("expect_message with regexp and no class is flagged", {
  lintr::expect_lint(
    'expect_message(f(), regexp = "informative")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})

test_that("regexp with class is allowed", {
  lintr::expect_no_lint(
    'expect_error(f(), regexp = "bad input", class = "my_pkg_error")',
    lms:::condition_class_linter()
  )
})

test_that("expect_message with regexp and class is allowed", {
  lintr::expect_no_lint(
    'expect_message(f(), regexp = "informative", class = "my_pkg_message")',
    lms:::condition_class_linter()
  )
})

test_that("expect_error without regexp or with info is not flagged", {
  lintr::expect_no_lint("expect_error(f())", lms:::condition_class_linter())
  lintr::expect_no_lint(
    'expect_error(f(), class = "my_pkg_error")',
    lms:::condition_class_linter()
  )
  lintr::expect_no_lint(
    'expect_error(f(), info = "details")',
    lms:::condition_class_linter()
  )
})

test_that("a positional class after a positional regexp is allowed", {
  lintr::expect_no_lint(
    'expect_error(f(), "bad input", "my_pkg_error")',
    lms:::condition_class_linter()
  )
  lintr::expect_no_lint(
    'expect_warning(f(), "deprecated", "my_pkg_warning")',
    lms:::condition_class_linter()
  )
})

test_that("a positional argument fills class when regexp is named", {
  lintr::expect_no_lint(
    'expect_error(f(), regexp = "bad input", "my_pkg_error")',
    lms:::condition_class_linter()
  )
})

test_that("a partially named class is allowed", {
  lintr::expect_no_lint(
    'expect_error(f(), "bad input", cla = "my_pkg_error")',
    lms:::condition_class_linter()
  )
})

test_that("a positional regexp after a named object is flagged", {
  lintr::expect_lint(
    'expect_error(object = f(), "bad input")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})

test_that("info is not mistaken for class", {
  lintr::expect_lint(
    'expect_error(f(), "bad input", info = "details")',
    "include a `class =` assertion",
    lms:::condition_class_linter()
  )
})
