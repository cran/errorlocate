% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/replace-errors.R
\name{replace_errors}
\alias{replace_errors}
\alias{replace_errors,data.frame,validator-method}
\alias{replace_errors,data.frame,ErrorLocalizer-method}
\alias{replace_errors,data.frame,errorlocation-method}
\title{Replace erroneous fields with NA or a suggested value}
\usage{
replace_errors(
  data,
  x,
  ref = NULL,
  ...,
  cl = NULL,
  Ncpus = getOption("Ncpus", 1),
  value = c("NA", "suggestion")
)

\S4method{replace_errors}{data.frame,validator}(
  data,
  x,
  ref = NULL,
  ...,
  cl = NULL,
  Ncpus = getOption("Ncpus", 1),
  value = c("NA", "suggestion")
)

\S4method{replace_errors}{data.frame,ErrorLocalizer}(
  data,
  x,
  ref = NULL,
  ...,
  cl = NULL,
  Ncpus = getOption("Ncpus", 1),
  value = c("NA", "suggestion")
)

\S4method{replace_errors}{data.frame,errorlocation}(
  data,
  x,
  ref = NULL,
  ...,
  cl = NULL,
  Ncpus = 1,
  value = c("NA", "suggestion")
)
}
\arguments{
\item{data}{data to be checked}

\item{x}{\code{\link[validate:validator]{validate::validator()}} or \code{errorlocation} object.
If an \code{errorlocation} is already available (through \code{\link[=locate_errors]{locate_errors()}}) this
is more efficient.}

\item{ref}{optional reference data set}

\item{...}{these parameters are handed over to \code{\link[=locate_errors]{locate_errors()}}}

\item{cl}{optional cluster for parallel execution (see details)}

\item{Ncpus}{number of nodes to use. (see details)}

\item{value}{\code{NA}}
}
\value{
\code{data} with erroneous values removed.
}
\description{
Find erroneous fields using \code{\link[=locate_errors]{locate_errors()}} and replace these
fields automatically with NA or a suggestion that is provided by the error detection algorithm.
}
\details{
Note that you can also use the result of \code{\link[=locate_errors]{locate_errors()}} with \code{replace_errors}.
When the procedure takes a long time and \code{locate_errors} was called previously
this is the preferred way, because otherwise \code{locate_errors} will be executed again.
The errors that were removed from the \code{data.frame} can be retrieved with the function
\code{\link[=errors_removed]{errors_removed()}}. For more control over error localization see \code{\link[=locate_errors]{locate_errors()}}.

\code{replace_errors} has the same parallelization options as \code{\link[=locate_errors]{locate_errors()}} (see there).
}
\note{
In general it is better to replace the erroneous fields with \code{NA} and apply a proper
imputation method. Suggested values from the error localization method may introduce an undesired bias.
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
\code{\link[=errorlocation-class]{errorlocation-class()}}

Other error finding: 
\code{\link{errorlocation-class}},
\code{\link{errors_removed}()},
\code{\link{expand_weights}()},
\code{\link{locate_errors}()}
}
\concept{error finding}
