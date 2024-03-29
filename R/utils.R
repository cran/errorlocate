# makes a copy of the validation object
check_validator <- function(x, copy = TRUE, check_infeasible = TRUE){
  if (!inherits(x, "validator")){
    stop("This method needs a 'validator' object, but was given a '", class(x), "'.",call. = FALSE)
  }
  if (isTRUE(check_infeasible) && is_infeasible(x)){
    stop("This rule set is infeasible. Please fix and repair the rule set with `make_feasible` before continuing.", call. = FALSE)
  }
  invisible(x)
}

to_exprs <- function(x, ..., ratios=TRUE){
  # make names unique
  names(x) <- names(x)

  exprs <-
    x$exprs( lin_eq_eps   = 0
           , lin_ineq_eps = 0
           , replace_in   = FALSE
           , vectorize    = FALSE
           , expand_assignments = TRUE
           , expand_groups = TRUE
           , ...
           )
  if (isTRUE(ratios)){
    exprs[] <- lapply(exprs, rewrite_ratio)
  }
  exprs[] <- lapply(exprs, rewrite_in_range)
  as.expression(exprs)
}

#
# get_variables_num <- function(x){
#   var_num <- sapply(to_miprules(x), function(mr){
#     names(mr$type)[mr$type == "double"]
#   })
#   unique(unlist(var_num))
# }
#
# get_variables_cat <- function(x){
#   var_cat <- sapply(to_miprules(x), function(mr){
#     nms <- names(mr$type)
#     nms[mr$type == "binary" & grepl(":", nms)]
#   })
#   var_cat <- unique(unlist(var_cat))
#   if (length(var_cat) == 0){
#     return(
#       data.frame( bin_variable = character(0)
#                 , variable     = character(0)
#                 , value        = character(0)
#                 , stringsAsFactors = FALSE
#       )
#     )
#   }
#
#   data.frame( bin_variable = var_cat
#             , variable     = sub(":.*$", "", var_cat)
#             , value        = sub("^.*:", "", var_cat)
#             , stringsAsFactors = FALSE
#             )
# }
