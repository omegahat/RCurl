\name{clone}
\alias{clone}
\alias{clone,ANY-method}
\alias{clone,CURLHandle-method}
\alias{clone,environment-method}
\alias{clone,CFILE-method}
\title{Clone/duplicate an object}
\description{
  This is a generic function and methods for making a copy of an
  object such as a curl handle, C-level pointer to a file, etc.
}
\usage{
clone(x, ...)
}
\arguments{
  \item{x}{the object to be cloned.}
  \item{\dots}{additional parameters for methods}
}
\value{
  Typically, an object of the same class and \dQuote{value}
  as the input - \code{x}.
}
\author{
Duncan Temple Lang
}

\seealso{
 \code{\link{dupCurlHandle}}
}
\examples{
 h = getCurlHandle(verbose = TRUE)
 other = dupCurlHandle(h)
 curlSetOpt(curl = h, verbose = FALSE)
}
\keyword{programming}
