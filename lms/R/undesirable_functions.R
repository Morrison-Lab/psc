#' Undesirable functions for UCD-SERG repositories
#'
#' The default lintr undesirable-function map, extended with the UCD-SERG
#' conventions: base and rlang messaging functions are steered toward their
#' `cli::` equivalents, `library()` is discouraged inside package code, base R
#' functions with a tidyverse replacement (`data.frame()`, `read.csv()`,
#' `rbind()`, `gsub()`, and the rest of the function-name swaps in the
#' coding-style chapter) are steered toward their tidyverse replacements, and
#' a few of lintr's defaults (`structure()`, `browser()`) are dropped.
#'
#' Exported so a downstream repository can further `lintr::modify_defaults()`
#' it if a single repo needs to diverge, without copy-pasting the whole map.
#'
#' @return A named character vector suitable for
#'   [lintr::undesirable_function_linter()]'s `fun` argument.
#' @export
undesirable_functions <- function() {
  lintr::modify_defaults(
    defaults = lintr::default_undesirable_functions,

    # following https://github.com/r-lib/devtools/blob/2aa51ef/.lintr.R:
    # Base messaging
    "message" = "use cli::cli_inform()",
    "warning" = "use cli::cli_warn()",
    "stop" = "use cli::cli_abort()",
    # rlang messaging
    "inform" = "use cli::cli_inform()",
    "warn" = "use cli::cli_warn()",
    "abort" = "use cli::cli_abort()",
    # older cli
    "cli_alert_danger" = "use cli::cli_inform()",
    "cli_alert_info" = "use cli::cli_inform()",
    "cli_alert_success" = "use cli::cli_inform()",
    "cli_alert_warning" = "use cli::cli_inform()",

    # Tidyverse replacements, as listed in the coding-style chapter
    # (chapters/coding-style/tidyverse-replacements.qmd).
    "data.frame" = "use tibble::tibble()",
    "read.csv" = "use readr::read_csv()",
    "write.csv" = "use readr::write_csv()",
    "readRDS" = "use readr::read_rds()",
    "saveRDS" = "use readr::write_rds()",
    "rbind" = "use dplyr::bind_rows() (or `# nolint` for matrices)",
    "cbind" = "use dplyr::bind_cols() (or `# nolint` for matrices)",
    "grep" = paste(
      "use stringr::str_which()",
      "(or stringr::str_subset() for value = TRUE)"
    ),
    "gsub" = "use stringr::str_replace_all()",
    "sessionInfo" = "use sessioninfo::session_info()",

    library = paste(
      "\nuse `::`, `usethis::use_import_from()`, or `withr::local_package()`",
      "instead of modifying the global search path.",
      "\nSee:\n",
      "<https://r-pkgs.org/code.html#sec-code-r-landscape> and\n",
      "<https://r-pkgs.org/testing-design.html#sec-testing-design-self-contained>", # nolint: line_length_linter.
      "\nfor more details."
    ),

    structure = NULL,
    browser = NULL
    # see https://github.com/r-lib/lintr/pull/2227 and
    # rebuttal https://github.com/r-lib/lintr/pull/2227#issuecomment-1800302675
  )
}
