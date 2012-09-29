\name{getCurlErrorClassNames}
\alias{getCurlErrorClassNames}
\title{Retrieve names of all curl error classes}
\description{
  This function returns the names of all of the
  error classes that curl can raise as a result
  of a request. You can use these names
  in calls to \code{tryCatch}
  to identify the class of the error for which you
  want to provide an error handler.
}
\usage{
getCurlErrorClassNames()
}
\value{
 A character vector
}
\references{
 libcurl documentation
}
\author{
Duncan Temple Lang
}
\seealso{
  \code{\link[base]{tryCatch}}
  \code{\link{curlPerform}}   and higher-level functions
  for making requests.
}
%\examples{}
\keyword{programming}
