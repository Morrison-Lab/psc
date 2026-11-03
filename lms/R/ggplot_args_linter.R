#' ggplot() arguments linter
#'
#' Flags any argument passed to `ggplot()`.
#' Pipe the primary data into a bare `ggplot()` layer,
#' then add the aesthetic mapping as its own layer:
#' `df |> ggplot() + aes(x, y)`, not `ggplot(df, aes(x, y))`
#' and not `ggplot(data = df)`.
#' This is the no-nested-calls policy applied to `ggplot()`,
#' which [nested_call_linter()] does not enforce
#' because it allows `aes()` as an argument.
#'
#' Both `ggplot()` and `ggplot2::ggplot()` are checked,
#' and arguments may be named (`data = df`, `mapping = aes(x, y)`)
#' or positional.
#' An `aes()` inside a layer such as `geom_point(aes(color = g))`
#' is not flagged.
#'
#' @return A [lintr::Linter()] object.
#' @export
ggplot_args_linter <- function() {
  ggplot_call <- "//expr[expr[1]/SYMBOL_FUNCTION_CALL[text() = 'ggplot']]"
  is_aes <- "expr[1]/SYMBOL_FUNCTION_CALL[text() = 'aes']"
  aes_xpath <- paste0(ggplot_call, "/expr[position() > 1][", is_aes, "]")
  data_xpath <- paste0(ggplot_call, "/expr[position() > 1][not(", is_aes, ")]")

  aes_message <- paste(
    "Don't nest aes() inside ggplot(): pipe the data into ggplot()",
    "and add the mapping as its own layer (`+ aes(x, y)`)."
  )
  data_message <- paste(
    "Don't pass data to ggplot(): pipe the primary data into a bare",
    "ggplot() (`df |> ggplot() + aes(x, y)`)."
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content
    aes_nodes <- xml2::xml_find_all(xml, aes_xpath)
    data_nodes <- xml2::xml_find_all(xml, data_xpath)

    aes_lints <- lintr::xml_nodes_to_lints(
      aes_nodes,
      source_expression = source_expression,
      lint_message = aes_message,
      type = "warning"
    )
    data_lints <- lintr::xml_nodes_to_lints(
      data_nodes,
      source_expression = source_expression,
      lint_message = data_message,
      type = "warning"
    )
    c(aes_lints, data_lints)
  })
}
