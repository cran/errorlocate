## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(errorlocate)

## -----------------------------------------------------------------------------
rules <- validator(example_1 = if (income > 0) age >= 16)
rules$exprs()

## -----------------------------------------------------------------------------
rules <- validator(example_2 = if (has_house == "yes") income >= 1000)
rules$exprs()

## ---- df_print = "kable"------------------------------------------------------
rules <- validator( r1 = age >= 18
                  , r2 = income >= 0
                  )
data <- data.frame(age = c(12, 35), income = c(2000, -1000))
data

## -----------------------------------------------------------------------------
summary(confront(data, rules))

## -----------------------------------------------------------------------------
locate_errors(data, rules)$errors

## -----------------------------------------------------------------------------
mip <- inspect_mip(data, rules)

## ----mip1, results='hide'-----------------------------------------------------
# inspect the lp problem (prior to solving it with lpsolveAPI)
lp <- mip$to_lp()
print(lp)

## ---- ref.label="mip1", comment= " ", echo=FALSE------------------------------
# inspect the lp problem (prior to solving it with lpsolveAPI)
lp <- mip$to_lp()
print(lp)

## ---- eval=FALSE--------------------------------------------------------------
#  mip$write_lp("my_problem.lp")

## -----------------------------------------------------------------------------
res <- mip$execute()

## -----------------------------------------------------------------------------
names(res)

## -----------------------------------------------------------------------------
res$solution

## -----------------------------------------------------------------------------
res$s

## -----------------------------------------------------------------------------
res$errors

## -----------------------------------------------------------------------------
res$values

## ----mip2, results="hide"-----------------------------------------------------
# lp problem after solving
res$lp

## ---- ref.label="mip2", comment=" ", echo=FALSE-------------------------------
# lp problem after solving
res$lp

## -----------------------------------------------------------------------------
rules <- validator( r1 = working %in% c("job","retired")                  )
data <- data.frame(working="?")

## ---- echo=FALSE--------------------------------------------------------------
knitr::kable(data)

## ----mip3, results="hide"-----------------------------------------------------
mip <- inspect_mip(data, rules)
mip$to_lp()

## ---- ref.label="mip3", comment=" ", echo=FALSE-------------------------------
mip <- inspect_mip(data, rules)
mip$to_lp()

## -----------------------------------------------------------------------------
mip$execute()$values

## -----------------------------------------------------------------------------
rules <- validator( r1 = if (voted == TRUE) adult == TRUE)
data <- data.frame(voted = TRUE, adult = FALSE)

## ---- echo=FALSE--------------------------------------------------------------
knitr::kable(data)

## ----mip4, results="hide"-----------------------------------------------------
mip <- inspect_mip(data, rules)
mip$to_lp()

## ---- ref.label="mip4", comment=" ", echo=FALSE-------------------------------
mip <- inspect_mip(data, rules)
mip$to_lp()

## -----------------------------------------------------------------------------
mip$execute()$values

## -----------------------------------------------------------------------------
rules <- validator( r1 = if (income > 0) age >= 16)
data <- data.frame(age = 12, income = 2000)

## ---- echo = FALSE------------------------------------------------------------
knitr::kable(data)

## -----------------------------------------------------------------------------
mip <- inspect_mip(data, rules)

## -----------------------------------------------------------------------------
mip$mip_rules()

## ----mip6, results="hide"-----------------------------------------------------
mip$to_lp()

## ---- ref.label="mip6", comment=" ", echo=FALSE-------------------------------
mip$to_lp()

## -----------------------------------------------------------------------------
mip$execute()$values

## -----------------------------------------------------------------------------
rules <- validator( r1 = working %in% c("no_job", "job","retired")
                  , r2 = if (age < 12) working == "no_job"
                  , r3 = if (working == "retired") age > 50
                  , r4 = age >=0
                  )

data <- data.frame(age = 12, working="retired")
mip <- inspect_mip(data, rules)
mip$execute()$errors

## -----------------------------------------------------------------------------
set.seed(42)
rules <- validator( r1 = if (voted == TRUE) adult == TRUE)
data <- data.frame(voted = TRUE, adult = FALSE)
mip <- inspect_mip(data, rules, weight = c(voted = 3, adult=1))

## -----------------------------------------------------------------------------
mip$objective

## ----mip7, results="hide"-----------------------------------------------------
mip$to_lp()

## ---- ref.label="mip7", comment=" ", echo=FALSE-------------------------------
mip$to_lp()

