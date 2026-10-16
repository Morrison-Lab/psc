#' Split a call's arguments into slots
#'
#' Walks the children of a call's `expr` node in lintr's XML parse tree,
#' between its parentheses, and splits them at each `OP-COMMA`.
#' Comments are skipped.
#' A slot is named when it holds `EQ_SUB`;
#' the name drops surrounding backticks or quotes,
#' so `` `class` = x `` and `"class" = x` both name `class`.
#'
#' @param call The call's `expr` node in lintr's XML parse tree.
#' @return A list with one element per argument slot, each a list with
#'   `name` (the argument name, or `NA` when unnamed) and
#'   `text` (the argument value's source text, `""` for an empty argument).
#' @noRd
call_arg_slots <- function(call) {
  children <- xml2::xml_children(call)
  kinds <- xml2::xml_name(children)
  inside <- seq_along(kinds) > match("OP-LEFT-PAREN", kinds) &
    seq_along(kinds) < length(kinds) &
    kinds != "COMMENT"
  args <- children[inside]
  arg_kinds <- kinds[inside]
  if (!length(args)) {
    return(list())
  }

  # A factor keeps an empty slot (such as the first in `f(, x)`), which
  # would otherwise have no elements and be dropped by split().
  slot_id <- cumsum(arg_kinds == "OP-COMMA")
  slot_id <- factor(slot_id, levels = 0:max(slot_id))
  lapply(split(seq_along(args), slot_id), function(idx) {
    idx <- idx[arg_kinds[idx] != "OP-COMMA"]
    eq <- which(arg_kinds[idx] == "EQ_SUB")
    if (length(eq)) {
      name <- gsub("^[`'\"]|[`'\"]$", "", xml2::xml_text(args[[idx[1]]]))
      value <- idx[-seq_len(eq[1])]
    } else {
      name <- NA_character_
      value <- idx
    }
    text <- paste(xml2::xml_text(args[value]), collapse = "")
    list(name = name, text = text)
  })
}
