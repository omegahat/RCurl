\name{CURLHandle-class}
\docType{class}
\alias{CURLHandle-class}

\title{Class "CURLHandle" for synchronous HTTP requests}
\description{
  This is the basic class used for  performing HTTP requests
  in the RCurl package.
  In R, this is a reference to a C-level data structure
  so we treat it as an opaque data type. However,
  essentially we can think of this as an with
  a set of options that persists across calls, i.e. HTTP requests.
  The numerous options that one can set can be see via
   \code{\link{getCurlOptionsConstants}}.
  The object can keep a connection to a Web server open for a period of time
  across calls.

  This class differs from \code{\link{MultiCURLHandle-class}} as it
  can handle only one request at a time and blocks until the request
  is completed (normally or abnormally).
  The other class can handle asynchronous, multiple connections.
}
\section{Objects from the Class}{A virtual Class: No objects may be created from it.}
\section{Extends}{
Class \code{"oldClass"}, directly.
}
\section{Methods}{
  \describe{
  }
}
\references{
 \url{http://curl.haxx.se}, the libcurl web site.
}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{getURL}},   \code{\link{getForm}},   \code{\link{postForm}}
  \code{\link{dupCurlHandle}},
  \code{\link{getCurlHandle}},
  \code{\link{MultiCURLHandle-class}}
}
\examples{
}
\keyword{classes}
