#' Typed columns that contain a reactive expression

as_reactive_logical <- function(x, expr) {
  UseMethod("as_reactive_logical")
}

new_reactive_lgl  <- function(x, expr) {
  stopifnot(rlang::is_expression(expr))
  structure(x, 
            class = c("reactive_lgl", "logical"),
            expr = expr)
}

as_reactive_logical.logical <- function(x, expr) {
  new_reactive_lgl(x, expr)
}


#' adapated from Ops.numeric_version and Jim Hester's code in bench repo
Ops.reactive_lgl <- function (e1, e2) {
  if (nargs() == 1L) {
    stop(
      sprintf("unary '%s' not defined for \"reactive_lgl\" objects", .Generic),
         call. = FALSE
      )
  }
  
  boolean <- switch(.Generic,
                    `==` = TRUE,
                    `|` = TRUE,
                    `&` = TRUE,
                    `!` = TRUE,
                    `!=` = TRUE,
                    `<` = TRUE,
                    `>` = TRUE,
                    `<=` = TRUE,
                    `>=` = TRUE,
                    FALSE)
  if (!boolean) {
    stop(sprintf("'%s' not meaningful for \"reactive_lgl\" objects", .Generic),
         call. = FALSE)
  }
  
  if (inherits(e1, "reactive_lgl")) {
    e1_expr <- get_reactive_expr(e1)
  } else {
    e1_expr <- enquo(e1)
  }
  
  if (inherits(e2, "reactive_lgl")) {
    e2_expr <- get_reactive_expr(e2)
  } else {
    e2_expr <- enquo(e2)
  }

  ops_expr <- quo({
    match.fun(!!.Generic)(!!e1_expr, !!e2_expr)
  })
  
  value <- NextMethod(.Generic)
  as_reactive_logical(value, ops_expr)
}



as_reactive_numeric <- function(x, expr) {
  UseMethod("as_reactive_numeric")
}

new_reactive_num <- function(x, expr) {
  stopifnot(rlang::is_expression(expr))
  structure(x, 
            class = c("reactive_num", "numeric"),
            expr = expr)
}

as_reactive_numeric.numeric <- function(x, expr) {
  new_reactive_num(x, expr)
}
