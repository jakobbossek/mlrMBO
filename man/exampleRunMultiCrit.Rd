% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exampleRunMultiCrit.R
\name{exampleRunMultiCrit}
\alias{exampleRunMultiCrit}
\title{Perform an MBO run on a multi-criteria test function and and visualize what happens.}
\usage{
exampleRunMultiCrit(fun, learner, control, points.per.dim = 50,
  show.info = NULL, nsga2.args = list(), ref.point = NULL, ...)
}
\arguments{
\item{fun}{[\code{function}]\cr
Target function. See \code{\link{mbo}} for details.}

\item{learner}{[\code{\link[mlr]{Learner}}]\cr
See \code{\link{mbo}}.
Default is mlr learner \dQuote{regr.km}, which is kriging from package
DiceKriging, if all parameters are numeric. \code{nugget.estim} is set
to \code{TRUE} depending on whether we have noisy observations or not.
If a least one parameter is discrete the mlr learner \dQuote{regr.randomForest}
from package RandomForest is used as the default.}

\item{control}{[\code{\link{MBOControl}}]\cr
See \code{\link{mbo}}.}

\item{points.per.dim}{[\code{integer}]\cr
Number of (regular spaced) locations at which to
sample the \code{fun} function per dimension.
Default is 50.}

\item{show.info}{[\code{logical(1)}]\cr
Verbose output on console?
Default is \code{TRUE}.}

\item{nsga2.args}{[\code{list}]\cr
Further arguments passed to the nsga2 call.
Default is \code{list()}.}

\item{ref.point}{[\code{numeric(2)}]\cr
Reference point to calculate the dominated hypervolume for the fronts of nsga2 and mbo.
Default is \code{NULL}, which means max(y_i) + 1 of the nsga2 front.}

\item{...}{[any]\cr
Further arguments passed to the learner.}
}
\value{
[\code{MBOExampleRunMultiCrit}]
}
\description{
Only available for 2D -> 2D examples,
useful for figuring out how stuff works and for teaching purposes.
Currently only parameter spaces with numerical parameters are supported.
For visualization, run \code{plotExampleRun} on the resulting object.
What is displayed is documented here: \code{\link{plotExampleRun}}.
}

