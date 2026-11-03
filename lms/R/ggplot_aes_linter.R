#' ggplot() aesthetic-mapping linter
#'
#' Flags an `aes()` call written inside a call to `ggplot()`, as in
#' `ggplot(df, aes(x, y))`. Pipe the data into a bare `ggplot()` layer,
#' then add the mapping as its own layer: `df |> ggplot() + aes(x, y)`.
#' This is the no-nested-calls policy applied to `ggplot()`,
#' which [nested_call_linter()] does not enforce
#' because it allows `aes()` as an argument.
#'
#' Both `ggplot()` and `ggplot2::ggplot()` are checked,
#' and the mapping may be named (`mapping = aes(x, y)`) or positional.
#' An `aes()` inside a layer such as `geom_point(aes(color = g))` is not flagged.
#'
#' @return A [lintr::Linter()] object.
#' @export
ggplot_aes_linter <- function() {
  xpath <- paste0(
    "//expr[expr[1]/SYMBOL_FUNCTION_CALL[text() = 'ggplot']]",
    "/expr[position() > 1][expr[1]/SYMBOL_FUNCTION_CALL[text() = 'aes']]"
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
        "Don't nest aes() inside ggplot(): pipe the data into ggplot()",
        "and add the mapping as its own layer (`+ aes(x, y)`)."
      ),
      type = "warning"
    )
  })
}
