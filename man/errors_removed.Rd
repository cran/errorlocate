% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/errorlocation.R
\name{errors_removed}
\alias{errors_removed}
\title{Get location of removed errors from a 'cleaned' data set}
\usage{
errors_removed(x, ...)
}
\arguments{
\item{x}{\code{data.frame} that was checked for errors}

\item{...}{not used}
}
\value{
\code{\link[=errorlocation-class]{errorlocation-class()}} object
}
\description{
\code{errors_removed} retrieves the errors detected by \code{\link[=replace_errors]{replace_errors()}}
}
\examples{
rules <- validator( profit + cost == turnover
              , cost - 0.6*turnover >= 0
              , cost>= 0
              , turnover >= 0
)
data <- data.frame(profit=755, cost=125, turnover=200)

data_no_error <- replace_errors(data,rules)

# faulty data was replaced with NA
data_no_error

errors_removed(data_no_error)

# a bit more control, you can supply the result of locate_errors
# to replace_errors, which is a good thing, otherwise replace_errors will call
# locate_errors internally.
error_locations <- locate_errors(data, rules)
replace_errors(data, error_locations)
}
\seealso{
Other error finding: 
\code{\link{errorlocation-class}},
\code{\link{expand_weights}()},
\code{\link{locate_errors}()},
\code{\link{replace_errors}()}
}
\concept{error finding}
