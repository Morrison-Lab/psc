#' Condition-class linter for testthat expectations
#'
#' Flags `expect_error()`, `expect_warning()`, and `expect_message()` calls
#' that assert on message text (`regexp`) without
#' also asserting on a condition `class`.
#' Either argument may be named, partially named, or positional;
#' `match_expectation_args()` matches them as R does.
#'
#' Matching only message text is brittle:
#' wording can change while the underlying condition type stays correct.
#' Prefer asserting the class,
#' and optionally add `regexp =` for extra precision.
#'
#' @return A [lintr::Linter()] object.
#' @noRd
condition_class_linter <- function() {
  target_functions <- c("expect_error", "expect_warning", "expect_message")
  calls_xpath <- paste(
    "//SYMBOL_FUNCTION_CALL[text() = ",
    paste(sprintf("'%s'", target_functions), collapse = " or text() = "),
    "]/ancestor::expr[OP-LEFT-PAREN][1]",
    sep = ""
  )

  lintr::Linter(linter_level = "expression", function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    calls <- xml2::xml_find_all(
      source_expression$xml_parsed_content,
      calls_xpath
    )
    if (!length(calls)) {
      return(list())
    }

    needs_class <- vapply(calls, function(call) {
      supplied <- match_expectation_args(call)
      "regexp" %in% supplied && !("class" %in% supplied)
    }, logical(1))

    lintr::xml_nodes_to_lints(
      calls[needs_class],
      source_expression = source_expression,
      lint_message = paste(
        "When matching a condition message in `expect_error()`,",
        "`expect_warning()`, or `expect_message()`, include a `class =`",
        "assertion instead of relying on `regexp` alone."
      ),
      type = "warning"
    )
  })
}
