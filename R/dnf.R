op <- function(e){
  if (is.call(e)) { e[[1]]
  } else { e }
}

node <- op

op_to_s <- function(e){
  deparse(op(e))
}

left <- function(e){
  if (length(e) >= 2) e[[2]]
}


right <- function(e){
  if (length(e) >= 3) e[[3]]
}

# look ahead
la <- function(e){
  op_to_s(left(e))
}

# consume tokens, typically handy for brackets
consume <- function(e, token = "("){
  while(op_to_s(e) ==  token){
    e = left(e)
  }
  e
}

is_lin_eq <- function(e){
  is_lin_(e) && op_to_s(e) == "=="
}

invert_or_negate <- function(e){
  if (is_lin_(e)){
    if (is_lin_eq(e)){
      # Dirty Hack but it works for now. Ideally this should be split in two statements
      substitute( l < r | l > r, list(l = left(e), r = right(e)))
    } else {
      invert_(e)
    }
  } else {
    negate_(e)
  }
}

# convert an expression to its disjunctive normal form
as_dnf <- function(expr, ...){
  # assumes that the expression has been tested with is.conditional
  clauses <- list()
  # remove "("
  expr <- consume(expr)
  op_if <- op_to_s(expr)

  cond <- NULL
  cons <- expr

  if (op_if == "if") {
    cond <- left(expr)
    cons <- right(expr)
  } else if (op_if %in% c("|", "||")){
    if (la(expr) == "!"){ # this is a rewritten if statement
      cons <- right(expr)
      cond <- left(left(expr))
    }
  } else if(op_if == "!"){
    cond <- left(expr)
    cons <- NULL
  } else if (is_cat_(expr) || is_lin_(expr)){
    return(structure(list(expr), class="dnf"))
  } else if (op_if %in% c("&", "&&")){
  } else {
    stop("Invalid expression")
  }
  # build condition clauses
  if (!is.null(cond)){
    cond <- consume(cond)
    op_and <- op_to_s(cond)

    while(op_and %in% c("&", "&&")){
      clauses[[length(clauses) + 1]] <- invert_or_negate(consume(right(cond)))
      cond <- consume(left(cond))
      op_and <- op_to_s(cond)
    }
    clauses[[length(clauses) + 1]] <- invert_or_negate(cond)
    clauses <- rev(clauses)
  }

  # build consequent clauses
  if (!is.null(cons)){
    cons <- consume(cons)
    op_or <- op_to_s(cons)
    while(op_or %in% c("|", "||")){
      #TODO improve nested parsing
      clauses[[length(clauses) + 1]] <- consume(left(cons))
      cons <- consume(right(cons))
      op_or <- op_to_s(cons)
    }
    if (op_or %in% c("&", "&&")){
      cons <- list(as_dnf(left(cons)), as_dnf(right(cons)))
    }
    clauses[[length(clauses) + 1]] <- cons
  }

  clauses <- unlist(lapply(clauses, function(clause){
    if (is.list(clause)){
      return(list(clause))
    }
    if (op_to_s(clause) == "|"){
      # the nasty case of negating equalities...
      as_dnf(clause)
    } else if (op_to_s(clause) == "!"){
      invert_or_negate(consume(left(clause)))
    } else {
      clause
    }
  }), recursive = FALSE)
  # unroll <- FALSE
  # for (i in seq_along(clauses)){
  #   clause <- clauses[[i]]
  #   if (op_to_s(clause) == "|") { # got-ya
  #     clauses[[i]] <- as_dnf(clause)
  #     unroll <- TRUE
  #   }
  # }
  # if (unroll){
  #   clauses <- unlist(clauses)
  # }
  # forget about it

  structure(clauses, class="dnf")
}

# allows for multiple dnfs / unrolls nested dnfs
as_dnfs <- function(d){
  nested <- sapply(d, is.list)
  e_pre <- d[!nested]

  n <- lapply(d[nested], function(l){
    ld <- unlist(lapply(l, as_dnfs), recursive = FALSE)
    ld <- lapply(ld, unclass)
    ld
  })

  if (any(nested)){
    l <- list(e_pre)
    for (i in n){
      l <- unlist(lapply(l, function(l1){
        list( c(l1, i[[1]])
            , c(l1, i[[2]])
            )
      }), recursive = FALSE)
    }
    l <- lapply(l, structure, class="dnf")
    l
  } else {
    list(structure(e_pre, class="dnf"))
  }
}

#as_clause <- as_dnf
deparse_all <- function(x, width.cutoff = 500L, ...){
  if (is.list(x)){ # nested dnf parsing
    text <- sapply(x, as.character)
    text <- paste0(text, collapse = " & ")
    text <- paste0("(", text, ")")
    return(text)
  }

  text <- deparse(x, width.cutoff = width.cutoff, ...)
  if (length(text) == 1){
    return(text)
  }

  text <- sub("^\\s+", "", text)
  paste0(text, collapse = "")
}

#' @export
as.character.dnf <- function(x, as_if = FALSE, ...){
  x <- x[] # removes NULL entries
  x_s <- sapply(x, deparse_all)
  if (as_if && length(x) > 1){
    #TODO fix this for nested dnfs
    x_i <- sapply(x, invert_or_negate)
    x_i_s <- sapply(x_i, deparse_all)
    s <- paste(utils::head(x_i_s, -1), collapse = " & ")
    paste0("if (",s,") ", utils::tail(x_s, 1))
  } else {
    paste(x_s, collapse = ' | ')
  }
}

#' @export
print.dnf <- function(x, as_if = FALSE, ...){
  cat(as.character(x, as_if = as_if, ...))
}

#' @export
as.expression.dnf <- function(x, as_if = FALSE, ...){
  parse(text=as.character(x, as_if = as_if, ...))
}

dnf_to_mip_rule <- function(d, name = "", ...){
  islin <- sapply(d, is_lin_)
  d_l <- d[islin]
  if (any(islin)){
    if (length(d) == 1){ # pure numerical
      return(list(lin_mip_rule_(d[[1]], name = name)))
    }
    names(d_l) <- paste0(name, "._lin", seq_along(d_l))

    # replace linear parts with a negated symbol.
    d[islin] <- sapply(names(d_l), function(n){
      substitute(!V, list(V=as.name(n)))
    })

    # turn into mip_rules
    d_l <- lapply(names(d_l), function(name){
      e <- d_l[[name]]
      mr <- lin_mip_rule_(e = e, name = name)
    })

    # replace "==" with two statements
    is_eq <- sapply(d_l, function(mr) mr$op == "==")

    d_l[is_eq] <- lapply(d_l[is_eq], function(mr){
      mr$op = "<="
      mr
    })

    d_l2 <- lapply(d_l[is_eq], function(mr){
      mr$op = ">="
      mr
    })
    ##

    # turn all linear subclauses into soft constraints.
    d_l <- lapply(c(d_l, d_l2), function(mr){
      mr <- rewrite_mip_rule(mr)
      mr <- soft_lin_rule(mr, prefix = "")
      mr
    })
    ##
  }
  c( list(cat_mip_rule_(as.expression(d)[[1]], name = name))
   , d_l # for pure categorical this is list()
   )
}

# translates the validator rules into mip rules
to_miprules <- function(x, ...){
  check_validator(x, check_infeasible = FALSE)
  exprs <- to_exprs(x)
  # browser()

  can_translate <- is_linear(exprs) | is_categorical(exprs) | is_conditional(exprs)
  if (!all(can_translate)){
    warning( "*******\n"
           , "Ignoring non linear rules: \n"
#           , paste(names(exprs)[!can_translate], collapse = ", ")
           , paste0( "  ", exprs[!can_translate]
                   , " [", names(exprs)[!can_translate],"]"
                   , collapse = "\n"
                   )
           , "\n******\n"
           , call. = FALSE
           )
  }
  exprs <- exprs[can_translate]
  mr <- lapply(names(exprs), function(name){
    e <- exprs[[name]]
    d <- as_dnf(e)

    l <- lapply(as_dnfs(d), function(d){
      lapply( dnf_to_mip_rule(d, name = name)
              , rewrite_mip_rule
      )
    })
    unlist(l, recursive = F)
  })

  unlist(mr, recursive = F)
}

get_translatable_vars <- function(x){
  exprs <- to_exprs(x)
  can_translate <- is_linear(exprs) | is_categorical(exprs) | is_conditional(exprs)
  all.vars(exprs[can_translate])
}

to_lp <- function(x, objective = NULL, eps = 0.001){
  check_validator(x, check_infeasible = FALSE)
  rules <- to_miprules(x)
  translate_mip_lp(rules = rules, objective = objective, eps = eps)
}

# as_dnf(quote(!(gender == "male") | x > 6))
# as_dnf(quote(if (y == 1) x > 6))
# as_dnf(quote( !(gender %in% "male" & y > 3) | x > 6))

# e <- quote( x == 1)
# invert_or_negate(e)

#' @export
print.mip_rule <- function(x, ...){
  s <- paste(x$a, "*", names(x$a), collapse = " + ")
  cat(paste0("[", x$rule, "]: ", s, " ", x$op, " ",x$b))
}

# e <- quote(if (A %in% "a" && x >= 0) y == 0)
# d <- as_dnf(e)
# dnf_to_mip_rule(d, name="rule1")
#
# e <- quote(if (A == "a") B == "b")
# d <- as_dnf(e)
# dnf_to_mip_rule(d, name="rule2")
#
# e <- quote(x + 2*y > 1 - x)
# d <- as_dnf(e)
# dnf_to_mip_rule(d, name="rule3")

# rules <- validator( rule1 = x + 2*y > 1, rule2 = A %in% c("a1", "a2"), rule3 = if(A == "a1") x > 2)
# rules
# lp <- to_lp(rules)
# solve(lp)
# lp
