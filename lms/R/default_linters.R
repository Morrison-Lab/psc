#' Default UCD-SERG lintr linters
#'
#' The canonical linter set for UCD-SERG repositories, matching the style
#' guide in the lab manual. Applied repositories consume this from a thin
#' `.lintr.R`:
#'
#' ```r
#' linters <- lms::default_linters()
#' exclusions <- list(...)   # repo-specific, stays local
#' ```
#'
#' @return A list of linters, as produced by
#'   [lintr::linters_with_defaults()].
#' @export
default_linters <- function() {
  lintr::linters_with_defaults(
    return_linter = NULL,
    trailing_whitespace_linter = NULL,
    lintr::redundant_equals_linter(),
    lintr::pipe_consistency_linter(pipe = "|>"),
    lintr::object_name_linter(
      regexes = c(snake_case_ACROs1 = snake_case_acros_regex())
    ),
    lintr::undesirable_function_linter(
      fun = undesirable_functions(),
      symbol_is_undesirable = TRUE
    ),
    lintr::cyclocomp_linter(),
    function_length_linter(),
    function_location_linter(),
    condition_class_linter()
  )
}
