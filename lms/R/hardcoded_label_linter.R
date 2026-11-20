#' Hardcoded label linter
#'
#' Flags a string literal written as a variable's label
#' while a plot or table is being built.
#' Attach each label to the data once, in preprocessing,
#' with `labelled::set_variable_labels()`,
#' and let the plot or table read it:
#' ggplot2 (4.0.0 and later) titles an axis or legend
#' with the `label` attribute of the variable mapped to it,
#' and gtsummary reads the same attribute.
#' A table function that does not read it takes the labels from the data,
#' as in `knitr::kable(col.names = wage_names)`,
#' with `wage_names` made by
#' `labelled::var_label(df, unlist = TRUE, null_action = "fill")`.
#'
#' The linter checks:
#'
#' * `labs()`, except `title`, `subtitle`, `caption`, `tag`, `alt` and
#'   `alt_insight`, which describe the plot, not a variable;
#'   a `dictionary` is checked too, so a label for a computed variable
#'   such as `count` goes in a named vector made in preprocessing
#'   (`labs(dictionary = wage_labels)`);
#' * every argument of `xlab()` and `ylab()`;
#' * the `name` argument (named or first) of every `scale_*()`,
#'   and the `title` argument (named or first) of every `guide_*()`;
#' * `col.names` of `kable()`, `colnames` of `datatable()`,
#'   and every argument of `gt::cols_label()`
#'   and `flextable::set_header_labels()`.
#'
#' An argument is flagged when its value is a string literal,
#' or a `c()`, `list()`, `paste()`, `paste0()`, `sprintf()` or `glue()` call
#' with a string literal among its arguments.
#' A label read from the data (`labelled::var_label(df$x)`),
#' a math label (`expression(beta)`) and `NULL` are not flagged.
#'
#' @return A [lintr::Linter()] object.
#' @export
hardcoded_label_linter <- function() {
  xpath <- hardcoded_label_xpath()
  flag_message <- paste(
    "Don't hardcode a variable label while building a plot or table:",
    "set it on the data in preprocessing",
    "(`labelled::set_variable_labels()`)",
    "and let the plot or table read it."
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content
    nodes <- xml2::xml_find_all(xml, xpath)

    lintr::xml_nodes_to_lints(
      nodes,
      source_expression = source_expression,
      lint_message = flag_message,
      type = "warning"
    )
  })
}

# XPath to the argument values that hardcode a label.
hardcoded_label_xpath <- function() {
  any_text <- function(values) {
    quoted <- paste0("text() = '", values, "'")
    paste(quoted, collapse = " or ")
  }
  call_of <- function(test) {
    paste0("//expr[expr[1]/SYMBOL_FUNCTION_CALL[", test, "]]")
  }
  named_arg <- function(test) {
    paste0("/SYMBOL_SUB[", test, "]/following-sibling::expr[1]")
  }
  every_arg <- "/expr[position() > 1]"
  first_arg <- "/expr[preceding-sibling::*[1][self::OP-LEFT-PAREN]]"

  plot_args <- any_text(c(
    "title", "subtitle", "caption", "tag", "alt", "alt_insight"
  ))
  label_funs <- any_text(c("xlab", "ylab", "cols_label", "set_header_labels"))
  scale_call <- call_of("starts-with(text(), 'scale_')")
  guide_call <- call_of("starts-with(text(), 'guide_')")
  variable_arg <- paste0("not(", plot_args, ")")
  arg_paths <- c(
    paste0(call_of("text() = 'labs'"), named_arg(variable_arg)),
    paste0(call_of(label_funs), every_arg),
    paste0(call_of("text() = 'kable'"), named_arg("text() = 'col.names'")),
    paste0(call_of("text() = 'datatable'"), named_arg("text() = 'colnames'")),
    paste0(scale_call, named_arg("text() = 'name'")),
    paste0(scale_call, first_arg),
    paste0(guide_call, named_arg("text() = 'title'")),
    paste0(guide_call, first_arg)
  )

  # a string literal, or c(), paste0() and the like with one as an argument
  builders <- any_text(c("c", "list", "paste", "paste0", "sprintf", "glue"))
  is_literal <- paste0(
    "[STR_CONST or (expr[1]/SYMBOL_FUNCTION_CALL[", builders, "]",
    " and expr[position() > 1][STR_CONST])]"
  )
  literal_paths <- paste0(arg_paths, is_literal)
  paste(literal_paths, collapse = " | ")
}
