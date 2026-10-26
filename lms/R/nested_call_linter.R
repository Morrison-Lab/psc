#' Nested-call linter
#'
#' Flags a function call passed straight to another call as an argument, as in
#' `f(g(x))`. Name the intermediate result, or chain the steps with a pipe
#' (`|>`), so the data flow reads top to bottom and each value can be
#' inspected.
#'
#' Not flagged, because the outer call interprets the argument itself:
#' - tidyselect helpers (`all_of()`, `starts_with()`, and the rest of
#'   `tidyselect_helpers`), and ggplot2's `aes()` and `vars()`, as the
#'   argument;
#' - anything inside a call to a data-masking or quoting function
#'   (`mutate()`, `filter()`, `summarise()`, `aes()`, `quote()`, and the rest of
#'   `data_masking_verbs`);
#' - the steps of a pipe chain, and formulas, which are not calls to nest.
#'
#' Only a call that is itself an argument is flagged: `f(a + g(x))` and
#' `f(!g(x))` wrap the call in an operator, and are not.
#'
#' @param tidyselect_helpers Names of functions allowed as an argument.
#' @param data_masking_verbs Names of functions whose arguments are
#'   data-masked or quoted, so any call inside them is allowed.
#' @return A [lintr::Linter()] object.
#' @export
nested_call_linter <- function(
  tidyselect_helpers = c(
    "all_of", "any_of", "starts_with", "ends_with", "contains", "matches",
    "num_range", "everything", "last_col", "where", "one_of", "aes", "vars"
  ),
  data_masking_verbs = c(
    "mutate", "transmute", "filter", "summarise", "summarize", "arrange",
    "group_by", "count", "tally", "distinct", "slice", "across", "case_when",
    "if_else", "aes", "quote", "expr", "bquote", "substitute", "vars",
    "with", "within", "subset", "transform"
  )
) {
  is_call <- "expr[1][SYMBOL_FUNCTION_CALL] and OP-LEFT-PAREN"
  called_as <- function(names) {
    if (length(names) == 0) {
      return("self::NO_SUCH_NODE")
    }
    quoted <- paste0("text() = '", names, "'")
    matching <- paste(quoted, collapse = " or ")
    paste0("expr[1]/SYMBOL_FUNCTION_CALL[", matching, "]")
  }
  inside_data_masking <- called_as(data_masking_verbs)
  inner_is_helper <- called_as(tidyselect_helpers)
  # The outer call is exempt when it is, or sits anywhere inside, a call to a
  # data-masking or quoting function, so `mutate(df, a = f(g(b)))` is allowed.
  xpath <- paste0(
    "//expr[", is_call, "][not(ancestor-or-self::expr[", inside_data_masking,
    "])]/expr[position() > 1][", is_call, "][not(", inner_is_helper, ")]"
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    nested <- xml2::xml_find_all(
      source_expression$xml_parsed_content,
      xpath
    )

    lintr::xml_nodes_to_lints(
      nested,
      source_expression = source_expression,
      lint_message = paste(
        "Don't nest function calls: name the intermediate result, or",
        "chain the steps with a pipe."
      ),
      type = "warning"
    )
  })
}
