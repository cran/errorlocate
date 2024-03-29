negate_ <- function(e, ...){
  op <- op_to_s(e)

  # don't do double negation: that complicates analysis of expressions
  if (op == '!'){
    return(consume(e[[2]]))
  }

  expr <- if (is.call(e) && op != '('){
    if (op == "!="){
      substitute( l == r, list(l = left(e), r = right(e)))
    } else if (op == "=="){
      if (is.logical(right(e))){
        substitute( l == r, list(l = left(e), r = !right(e)))
      } else {
        substitute( l != r, list(l = left(e), r = right(e)))
      }
    } else if (op %in% c("||", "|")){
      substitute( (nl & nr), list( nl = invert_or_negate(e[[2]])
                                 , nr = invert_or_negate(e[[3]])
                                 )
                )

    } else {
      substitute( !(e), list(e=e) )
    }
  } else {
    substitute( !e, list(e=e))
  }
  expr
}

invert_ <- function(e, ...){
  op <- op_to_s(e)
  s <- switch (op,
    "<"   = ">=",
    ">"   = "<=",
    "<="  = ">",
    ">="  = "<",
    #  "==" = "!=",
    # "!="  = "==",
    stop(op, " not supported")
  )
  substitute(a %op% b, list(a=left(e), b=right(e), "%op%"=as.symbol(s)))
}

is_ratio <- function(e){
  op <- op_to_s(e)

  if (!op %in% c(">=", "<=", "==", "<", ">")){
    return(FALSE)
  }

  n <- consume(right(e))
  if (!is.numeric(n)){
    return(FALSE)
  }

  ratio <- consume(left(e))
  op <- op_to_s(ratio)
  if (op != "/"){
    return(FALSE)
  }

  numerator <- consume(left(ratio))
  denominator <- consume(right(ratio))
  return(  is_lin_(numerator, top=FALSE)
        && is_lin_(denominator, top=FALSE)
        )
}

# assumes expression is a ratio
rewrite_ratio <- function(e){
  if (is_ratio(e)){
    op <- op(e)
    ratio <- consume(left(e))
    n <- consume(right(e))
    denom <- consume(right(ratio))
    rhs <- if (n == 1) denom else bquote(.(n) * .(denom))
    substitute(lhs %op% rhs, list( lhs = consume(left(ratio))
                                 , rhs = rhs
                                 , "%op%" = op
                                 )
              )
  } else {
    e
  }
}

is_num_range <- function(e){
  op <- as.character(node(e))
  if (!(op %in% c("in_range", "validate::in_range"))){
    return(FALSE)
  }
  if (is_lin_(e[[3]], top=FALSE) && is_lin_(e[[4]], top=FALSE)){
    return(TRUE)
  }
  FALSE
}

rewrite_in_range <- function(e){
  if (is_num_range(e)){
    substitute((.var >= .min) & (.var <= .max)
              , list( .var = e[[2]]
                    , .min = e[[3]]
                    , .max = e[[4]]
                    )
              )
  } else {
   e
  }
}
