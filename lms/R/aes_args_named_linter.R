#' aes() argument-name linter
#'
#' Flags every unnamed argument of `aes()`.
#' Name the aesthetics, as in `aes(x = day, y = Volume)`,
#' not `aes(day, Volume)`,
#' so a reader sees which variable goes to which aesthetic
#' without remembering the argument order.
#' The rule holds for a single argument too: write `aes(x = Lag1)`.
#'
#' Both `aes()` and `ggplot2::aes()` are checked,
#' wherever the call appears (a layer, a `+ aes()` layer, or a stored mapping).
#'
#' @return A [lintr::Linter()] object.
#' @export
aes_args_named_linter <- function() {
  # ggplot2's aes(), bare or qualified, not obj$aes() or another package's aes()
  is_aes <- paste0(
    "expr[1][SYMBOL_FUNCTION_CALL[text() = 'aes']",
    " and not(OP-DOLLAR)",
    " and (not(SYMBOL_PACKAGE) or SYMBOL_PACKAGE[text() = 'ggplot2'])]"
  )
  aes_call <- paste0("//expr[", is_aes, "]")
  starts_arg <- "preceding-sibling::*[1][self::OP-LEFT-PAREN or self::OP-COMMA]"
  # `...` forwarding and !! / !!! unquoting cannot take a name
  not_forwarded <- "not(self::expr[SYMBOL[text() = '...'] or OP-EXCLAMATION])"
  xpath <- paste0(aes_call, "/expr[", starts_arg, " and ", not_forwarded, "]")

  message <- paste(
    "Name the arguments of aes():",
    "write `aes(x = day, y = Volume)`, not `aes(day, Volume)`."
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
      lint_message = message,
      type = "warning"
    )
  })
}
