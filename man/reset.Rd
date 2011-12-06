\name{reset}
\alias{reset}
\alias{reset,CURLHandle-method}
\title{Generic function for resetting an object}
\description{
  This generic and the associated method for a CURLHandle
  allows one to reset the state of the Curl object
  to its default state.  This is convenient if we want
  to reuse the same connection, but want to ensure
  that it is in a particular state.

  Unfortunately, we cannot query the state of different
  fields in an existing Curl handle and so we need
  to be able to reset the state and then update it with
  any particular settings we would have liked to keep.
}
\usage{
reset(x, ...)
}
\arguments{
  \item{x}{the object to be reset. For our method, this is an object of
    class  \code{CURLHandle}.}
  \item{\dots}{additional arguments for methods}
}
\details{
 This calls the C routine \code{curl_easy_reset} in libcurl.
}
\value{
  Methods typically return the updated version of the
  object passed to it. This allows the caller to assign
  the new result to the same variable rather than
  relying on mutating the content of the object in place.
  In other words, the object should not be treated as a reference
  but a new object with the updated contents should be returned.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{getCurlHandle}}
  \code{\link{dupCurlHandle}}  
}
\examples{
 h = getCurlHandle()
 curlSetOpt(customrequest = "DELETE")
 reset(h)
}
\keyword{programming}

