# substitutes values into expressions, can be used to retrieve values
substitute_values <- function(x, values=list()){
  vals <- lapply(x$exprs(), function(e){
    e <- substituteDirect(e, values)
    tryCatch( r <- eval(e) # they should evaluate to TRUE, otherwise a rule is broken
            , error=function(x){
              e
            }
            )
  })

  is_logical <- sapply(vals, is.logical)
  if (any(is_logical)){
    if (!all(unlist(vals[is_logical]))){
      warning("Rule broken") # TODO improve
    }
  }
  vals[!is_logical]
}
