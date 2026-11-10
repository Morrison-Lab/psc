#' Base data-frame subsetting linter
#'
#' Flags a `[` call with an empty index, such as `df[i, ]` or `df[, j]`.
#' Subset a data frame with `dplyr::filter()` for rows
#' and `dplyr::select()` for columns,
#' and extract a column with `dplyr::pull()`.
#' A linter cannot tell a data frame from a matrix,
#' so mark a matrix index with `# nolint`.
#' Indexing a vector (`x[i]`) and `[[` are not flagged.
#'
#' @return A [lintr::Linter()] object.
#' @export
base_subset_linter <- function() {
  after_comma <- "OP-COMMA[following-sibling::*[1][self::OP-RIGHT-BRACKET]]"
  before_comma <- "OP-LEFT-BRACKET[following-sibling::*[1][self::OP-COMMA]]"
  between_commas <- "OP-COMMA[following-sibling::*[1][self::OP-COMMA]]"
  xpath <- paste0(
    "//expr[OP-LEFT-BRACKET][",
    after_comma, " or ", before_comma, " or ", between_commas,
    "]"
  )

  message <- paste(
    "Don't subset a data frame with base [].",
    "Use dplyr::filter() for rows, dplyr::select() for columns,",
    "and dplyr::pull() for one column (`# nolint` for a matrix)."
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }
    nodes <- xml2::xml_find_all(source_expression$xml_parsed_content, xpath)
    lintr::xml_nodes_to_lints(
      nodes,
      source_expression = source_expression,
      lint_message = message,
      type = "warning"
    )
  })
}
