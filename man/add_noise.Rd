% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addnoise.R
\name{add_noise}
\alias{add_noise}
\title{Add (a small amount of) noise}
\usage{
add_noise(x, max_delta = NULL, ...)
}
\arguments{
\item{x}{\code{numeric} vector or matrix. When \code{x} is a matrix, the function
will be applied to each row of the matrix.}

\item{max_delta}{when supplied noise will be drawn from \verb{[0,max_delta]}
otherwise see details}

\item{...}{currently not used}
}
\value{
\code{numeric} vector/matrix with noise applied.
}
\description{
Utility function to add some small positive noise to weights.
This is mainly done to randomly choose between solutions
of equal weight. Without adding noise to weights lp solvers may return
an identical solution over and over while there are multiple solutions of equal weight.
The generated noise is positive to prevent that weights will be zero or negative.
}
\details{
When no \code{max_delta} is supplied, add_noise will use the minimum difference
larger than zero divided by the \code{length(x)}.
}
