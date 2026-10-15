#' Which pipe, if any, feeds a call
#'
#' Looks at the token just before a call's `expr` node, skipping comments.
#' The base pipe is a `PIPE` token;
#' a magrittr pipe is a `SPECIAL` token such as `%>%`.
#'
#' @param call The call's `expr` node in lintr's XML parse tree.
#' @return `"|>"`, the magrittr pipe's text (`"%>%"`, `"%T>%"` or `"%<>%"`),
#'   or `NA` when the call is not on the right of a pipe.
#' @noRd
piped_into <- function(call) {
  previous <- xml2::xml_find_first(
    call,
    "preceding-sibling::*[not(self::COMMENT)][1]"
  )
  kind <- xml2::xml_name(previous)
  text <- xml2::xml_text(previous)
  if (identical(kind, "PIPE")) {
    return("|>")
  }
  if (identical(kind, "SPECIAL") && text %in% c("%>%", "%T>%", "%<>%")) {
    return(text)
  }
  NA_character_
}
