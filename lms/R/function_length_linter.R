#' Function-length linter
#'
#' Flags function definitions (including `\(...)` lambdas) that span more
#' lines than `length_limit`, matching the provisional heuristic documented
#' in "Function Length Limits" in *Principles of Scientific Computing*
#' (<https://morrison-lab.github.io/psc/>)
#' ("use `<150` lines... as a trigger to reassess decomposition, not a hard
#' constraint"). lintr has no built-in linter for this
#' (see <https://github.com/r-lib/lintr/issues/361>); `cyclocomp_linter()`
#' covers the complementary branching-complexity heuristic.
#'
#' @param length_limit Maximum number of lines a function definition may
#'   span before being flagged. Defaults to 150, matching the documented
#'   heuristic.
#' @return A [lintr::Linter()] object.
#' @export
function_length_linter <- function(length_limit = 150L) {
  xpath <- "//FUNCTION/parent::expr | //OP-LAMBDA/parent::expr"

  lintr::Linter(linter_level = "expression", function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content
    fun_defs <- xml2::xml_find_all(xml, xpath)

    n_lines <- as.integer(xml2::xml_attr(fun_defs, "line2")) -
      as.integer(xml2::xml_attr(fun_defs, "line1")) + 1L

    lintr::xml_nodes_to_lints(
      fun_defs[n_lines > length_limit],
      source_expression = source_expression,
      lint_message = sprintf(
        paste0(
          "Function spans more than %d lines; consider decomposing it (see ",
          "https://morrison-lab.github.io/psc/chapters/",
          "coding-practices.html#sec-function-length-limits)."
        ),
        length_limit
      ),
      type = "warning"
    )
  })
}
