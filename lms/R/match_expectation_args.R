#' Which leading testthat expectation formals a call supplies
#'
#' Matches a call's arguments to the first three formals of
#' `expect_error()`, `expect_warning()`, and `expect_message()`
#' (`object`, `regexp`, `class`) the way R does:
#' named arguments first, by exact or unique partial match,
#' then unnamed arguments, in order, to the formals still unmatched.
#' All three formals come before `...`, so partial matching applies to them.
#'
#' @param call The call's `expr` node in lintr's XML parse tree.
#' @return A character vector of the formals among
#'   `object`, `regexp`, and `class` that the call supplies.
#' @noRd
match_expectation_args <- function(call) {
  formals <- c("object", "regexp", "class")

  arg_names <- xml2::xml_text(xml2::xml_find_all(call, "./SYMBOL_SUB"))
  matches <- pmatch(arg_names, formals)
  named <- formals[matches[!is.na(matches)]]

  # An unnamed argument is an `expr` child right after `(` or `,`;
  # a named argument's value follows `EQ_SUB` instead.
  n_unnamed <- length(xml2::xml_find_all(
    call,
    "./expr[preceding-sibling::*[1][self::OP-LEFT-PAREN or self::OP-COMMA]]"
  ))
  unmatched <- setdiff(formals, named)
  unnamed <- unmatched[seq_len(min(n_unnamed, length(unmatched)))]

  c(named, unnamed)
}
