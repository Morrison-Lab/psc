#' Which leading testthat expectation formals a call supplies
#'
#' Matches a call's arguments to the first three formals of
#' `expect_error()`, `expect_warning()`, and `expect_message()`
#' (`object`, `regexp`, `class`) the way R does:
#' named arguments first, by exact or unique partial match,
#' then unnamed arguments, in order, to the formals still unmatched.
#' All three formals come before `...`, so partial matching applies to them.
#'
#' A call on the right of `|>` or a magrittr pipe (`%>%`, `%T>%`, `%<>%`)
#' gets the piped value as its first unnamed argument,
#' unless the call places it with a placeholder:
#' `_` as a named argument for `|>`, or `.` as any argument for magrittr.
#' An empty argument, as in `f(x, , y)` or `f(x, regexp = )`,
#' takes its slot but supplies nothing.
#' A forwarded `...` could supply any formal,
#' so a call containing one is reported as supplying all three.
#'
#' @param call The call's `expr` node in lintr's XML parse tree.
#' @return A character vector of the formals among
#'   `object`, `regexp`, and `class` that the call supplies.
#' @noRd
match_expectation_args <- function(call) {
  formals <- c("object", "regexp", "class")
  slots <- call_arg_slots(call)

  texts <- vapply(slots, function(slot) slot$text, character(1))
  if ("..." %in% texts) {
    return(formals)
  }

  arg_names <- vapply(slots, function(slot) slot$name, character(1))
  is_named <- !is.na(arg_names)
  unnamed_texts <- texts[!is_named]
  matches <- pmatch(arg_names[is_named], formals)
  hit <- !is.na(matches)
  matched <- formals[matches[hit]]
  # A named argument with an empty value (`regexp = `) takes its formal
  # but supplies nothing.
  named <- matched[nzchar(texts[is_named][hit])]

  # A pipe passes its left side as the first unnamed argument,
  # unless the call places it with a placeholder:
  # `_` in a named argument for `|>`, or `.` in any argument for magrittr.
  pipe <- piped_into(call)
  placed <- if (identical(pipe, "|>")) {
    "_" %in% texts[is_named]
  } else {
    "." %in% texts
  }
  if (!is.na(pipe) && !placed) {
    unnamed_texts <- c("<piped value>", unnamed_texts)
  }

  unmatched <- setdiff(formals, matched)
  n_filled <- min(length(unnamed_texts), length(unmatched))
  filled <- unmatched[seq_len(n_filled)]
  supplied <- nzchar(unnamed_texts[seq_len(n_filled)])

  c(named, filled[supplied])
}
