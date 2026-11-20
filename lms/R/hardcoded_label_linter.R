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
#' * every argument of `xlab()` and `ylab()`,
#'   and an `xlab`, `ylab` or `zlab` argument of any call
#'   other than `c()`, `list()`, `set_variable_labels()` and `var_label()`,
#'   such as base graphics' `plot()` and `hist()`;
#' * the `name` argument (named, or the first positional one) of every
#'   `scale_*()` except `scale_discrete_manual()` and the identity scales,
#'   whose first argument is the aesthetics,
#'   and the `title` argument (named or first positional) of every `guide_*()`;
#' * `col.names` of `kable()`, `colnames` of `datatable()`,
#'   and every argument of `gt::cols_label()`
#'   and `flextable::set_header_labels()`.
#'
#' An argument is flagged when its value is a string literal,
#' a `c()` or `list()` call with a string literal among its values,
#' or a `paste()`, `paste0()`, `sprintf()`, `glue()`, `md()` or `html()` call
#' with a string literal among its unnamed arguments,
#' nested up to three calls deep (`c(count = paste0("Number of ", unit))`).
#' Named options such as `sep = ""` and `collapse = ", "` are not label text.
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
  # an argument with no name: the token before it, skipping comments,
  # is "(" or ",", not "="
  is_unnamed <- "not(preceding-sibling::*[not(self::COMMENT)][1][self::EQ_SUB])"
  every_arg <- "/expr[position() > 1]"
  # the first positional argument, wherever it sits among named ones
  first_positional <- paste0("/expr[position() > 1][", is_unnamed, "][1]")

  plot_args <- any_text(c(
    "title", "subtitle", "caption", "tag", "alt", "alt_insight"
  ))
  label_funs <- any_text(c("xlab", "ylab", "cols_label", "set_header_labels"))
  scale_call <- call_of("starts-with(text(), 'scale_')")
  # scales whose first argument is the aesthetics, not the name
  aesthetic_first <- any_text(c(
    "scale_discrete_manual", "scale_discrete_identity",
    "scale_continuous_identity"
  ))
  named_first_scale <- call_of(paste0(
    "starts-with(text(), 'scale_') and not(", aesthetic_first, ")"
  ))
  guide_call <- call_of("starts-with(text(), 'guide_')")
  variable_arg <- paste0("not(", plot_args, ")")
  # an xlab = "..." inside these calls names a label, not an axis title
  label_containers <- any_text(c(
    "c", "list", "set_variable_labels", "var_label"
  ))
  axis_arg_call <- call_of(paste0("not(", label_containers, ")"))
  arg_paths <- c(
    paste0(call_of("text() = 'labs'"), named_arg(variable_arg)),
    paste0(call_of(label_funs), every_arg),
    paste0(call_of("text() = 'kable'"), named_arg("text() = 'col.names'")),
    paste0(call_of("text() = 'datatable'"), named_arg("text() = 'colnames'")),
    paste0(scale_call, named_arg("text() = 'name'")),
    paste0(named_first_scale, first_positional),
    paste0(guide_call, named_arg("text() = 'title'")),
    paste0(guide_call, first_positional),
    # base graphics: plot(x, y, xlab = "..."), hist(x, xlab = "...")
    paste0(axis_arg_call, named_arg(any_text(c("xlab", "ylab", "zlab"))))
  )

  literal_paths <- paste0(arg_paths, "[", literal_label_test(), "]")
  paste(literal_paths, collapse = " | ")
}

# XPath test, relative to an argument's expr, for a value that hardcodes
# a label: a string literal; a c() or list() with one among its values;
# or a paste(), paste0(), sprintf(), glue(), md() or html() with one among
# its unnamed arguments (named ones such as `sep` and `collapse` are
# options, not label text). Builders nest up to three levels deep.
literal_label_test <- function(depth = 3L) {
  any_fun <- function(values) {
    quoted <- paste0("text() = '", values, "'")
    tests <- paste(quoted, collapse = " or ")
    paste0("expr[1]/SYMBOL_FUNCTION_CALL[", tests, "]")
  }
  collectors <- any_fun(c("c", "list"))
  formatters <- any_fun(c("paste", "paste0", "sprintf", "glue", "md", "html"))
  is_unnamed <- "not(preceding-sibling::*[not(self::COMMENT)][1][self::EQ_SUB])"

  test <- "STR_CONST"
  for (i in seq_len(depth)) {
    test <- paste0(
      "STR_CONST",
      " or (", collectors, " and expr[position() > 1][", test, "])",
      " or (", formatters, " and expr[position() > 1][", is_unnamed, "][",
      test, "])"
    )
  }
  test
}
