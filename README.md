# Error localization

Find errors in data given a set of validation rules.
The `errorlocate` helps to identify obvious errors in raw datasets.

It works in tandem with the package `validate`.
With `validate` you formulate data validation rules to which the data must comply.

For example:

  "age cannot be negative": `age >= 0`

While `validate` can identify if a record is valid or not, it does not identify
which of the variables are responsible for the invalidation. This may seem a simple task,
but is actually quite tricky:  a set of validation rules form a web
of dependent variables: changing the value of an invalid record to repair for rule 1, may invalidate
the record for rule 2.

`errorlocate` provides a small framework for record based error detection and implements the Felligi Holt
algorithm. This algorithm assumes there is no other information available then the values of a record
and a set of validation rules. The algorithm minimizes the (weighted) number of values that need
to be adjusted to remove the invalidation.

# Installation

Beta versions can be install with `drat`:

```R
drat::addRepo("data-cleaning")
install.packages("errorlocate")
```

The latest development version of `errorlocate` can be installed from github with `devtools`:

```R
devtools::install_github("data-cleaning/errorlocate")
```

# Usage

```R
library(magrittr)

rules <- validator( profit + cost == turnover
              , cost - 0.6*turnover >= 0
              , cost>= 0
              , profit >= 0
)
data <- data.frame(profit=755, cost=125, turnover=200)

data_no_error <-
  data %>%
  replace_errors(rules)

# faulty data was replaced with NA
data_no_error

errors_removed(data_no_error)
```
