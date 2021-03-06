#' @export
#' @rdname sql_build
sql_render <- function(query, con = NULL, ...) {
  UseMethod("sql_render")
}

#' @export
sql_render.tbl_lazy <- function(query, con = query$con, ...) {
  # only used for testing
  qry <- sql_build(query$ops, con = con, ...)
  sql_render(qry, con = con, ...)
}

#' @export
sql_render.tbl_sql <- function(query, con = query$src$con, ...) {
  # only used for testing
  qry <- sql_build(query$ops, con = con, ...)
  sql_render(qry, con = con, ...)
}

#' @export
sql_render.op <- function(query, con = NULL, ...) {
  sql_render(sql_build(query, ...), con = con, ...)
}

#' @export
sql_render.select_query <- function(query, con = NULL, ..., root = FALSE) {
  from <- sql_subquery(con, sql_render(query$from, con, ..., root = root), name = NULL)

  sql_select(
    con, query$select, from, where = query$where, group_by = query$group_by,
    having = query$having, order_by = query$order_by, limit = query$limit,
    distinct = query$distinct,
    ...
  )
}

#' @export
sql_render.ident <- function(query, con = NULL, ..., root = TRUE) {
  if (root) {
    sql_select(con, sql("*"), query)
  } else {
    query
  }
}

#' @export
sql_render.sql <- function(query, con = NULL, ...) {
  query
}

#' @export
sql_render.join_query <- function(query, con = NULL, ..., root = FALSE) {
  from_x <- sql_subquery(con, sql_render(query$x, con, ..., root = root), name = "TBL_LEFT")
  from_y <- sql_subquery(con, sql_render(query$y, con, ..., root = root), name = "TBL_RIGHT")

  sql_join(con, from_x, from_y, vars = query$vars, type = query$type, by = query$by)
}

#' @export
sql_render.semi_join_query <- function(query, con = NULL, ..., root = FALSE) {
  from_x <- sql_subquery(con, sql_render(query$x, con, ..., root = root), name = "TBL_LEFT")
  from_y <- sql_subquery(con, sql_render(query$y, con, ..., root = root), name = "TBL_RIGHT")

  sql_semi_join(con, from_x, from_y, anti = query$anti, by = query$by)
}

#' @export
sql_render.set_op_query <- function(query, con = NULL, ..., root = FALSE) {
  from_x <- sql_render(query$x, con, ..., root = TRUE)
  from_y <- sql_render(query$y, con, ..., root = TRUE)

  sql_set_op(con, from_x, from_y, method = query$type)
}
