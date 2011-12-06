\name{getBitIndicators}
\alias{getBitIndicators}
\alias{setBitIndicators}
\title{Operate on bit fields}
\description{
  The \code{getBitIndicators} function decompose a value into its respective
  bit components.
  The \code{setBitIndicators} combines individual components into a
  single number
  to "set" a bit field value.
}
\usage{
getBitIndicators(val, defs)
setBitIndicators(vals, defs)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{val}{the value to break up into the bit field components.}
  \item{defs}{the named integer vector that defines the bit field elements.}
  \item{vals}{the individual components that are to be combined into a
    single integer value representing the collection of components.
    These can be given as names or integer values that correspond to the
    elements in the defs, either by name or value.
  }
}
\value{
  \code{getBitIndicators} returns a named integer vector representing
  the components of the bit field in the value.
  The names of the vector give the symbolic elements that were set in
  the value.

  \code{setBitIndicators} returns a single integer value representing
  the value from combining the different components (e.g. ORing the bits
  of the different values).
}

\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}


\seealso{
 The features field in \code{\link{curlVersion}}.
}
\examples{
  getBitIndicators(7, c(A = 1, B = 2, C = 4))
  getBitIndicators(3, c(A = 1, B = 2, C = 4))
  getBitIndicators(5, c(A = 1, B = 2, C = 4))
}
\keyword{manip}


