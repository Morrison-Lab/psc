#' snake_case object-name regex (uppercase acronyms allowed)
#'
#' Builds the regex used by the object-name linter so that names like
#' `snake_case_ACROs1` (uppercase acronyms, optional trailing digits) are
#' accepted. See <https://github.com/r-lib/lintr/issues/2844> for background.
#'
#' Constructed with `rex::rex()`, which evaluates its arguments in an
#' environment that registers the rex shortcuts (`start`, `upper`, `digit`,
#' `%or%`, ...), so the package does **not** need to attach rex.
#'
#' @return A single regular-expression string.
#' @noRd
snake_case_acros_regex <- function() {
  rex::rex(
    start,
    maybe("."),
    list(some_of(upper), maybe("s"), zero_or_more(digit)) %or%
      list(some_of(lower), zero_or_more(digit)),
    zero_or_more(
      "_",
      list(some_of(upper), maybe("s"), zero_or_more(digit)) %or%
        list(some_of(lower), zero_or_more(digit))
    ),
    end
  )
}
