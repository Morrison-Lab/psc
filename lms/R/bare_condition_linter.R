#' Bare-condition linter
#'
#' Flags an `if()` or `while()` whose condition is anything but a bare name or
#' a literal. Compute the condition into a named logical first, then test the
#' name: the name documents the test, puts each comparison on its own line
#' where a misplaced parenthesis is visible in review, and can be inspected
#' before the branch runs. The real bug that motivated the rule, a misplaced
#' parenthesis in `sum(lengths(x) == 1)`, was fixed in
#' <https://github.com/UCD-SERG/serodynamics/pull/326>.
#'
#' For a `while()` loop, compute the named condition before the loop and
#' recompute it at the end of the loop body. `while (TRUE)` is allowed.
#'
#' @return A [lintr::Linter()] object.
#' @export
bare_condition_linter <- function() {
  # The condition is the first `expr` child of an `if` or `while` expression;
  # an `else if` is itself an `if` expression, so it is covered too.
  xpath <- "
    //expr[IF or WHILE]/expr[1][
      not(
        count(*) = 1
        and (SYMBOL or NUM_CONST[text() = 'TRUE' or text() = 'FALSE'])
      )
    ]
  "

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    conditions <- xml2::xml_find_all(
      source_expression$xml_parsed_content,
      xpath
    )

    lintr::xml_nodes_to_lints(
      conditions,
      source_expression = source_expression,
      lint_message = paste(
        "Assign the condition to a named logical variable first, then test",
        "the name."
      ),
      type = "warning"
    )
  })
}
