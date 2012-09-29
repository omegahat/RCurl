\name{getCurlHandle}
\alias{getCurlHandle}
\alias{getCurlMultiHandle}
\alias{dupCurlHandle}
\title{Create libcurl handles}
\description{
  These functions create and duplicate curl handles
  for use in calls to the HTTP facilities provided by
  that low-level language and this R-level interface.
  A curl handle is an opaque data type that contains a
  reference to the internal C-level data structure
  of libcurl for performing HTTP requests.

  The \code{getCurlMutliHandle} returns an object
  that can be used for concurrent, multiple requests.
  It is quite different from the regular curl handle
  and again, should be treated as an opaque data type.
}
\usage{
getCurlHandle(..., .opts = NULL, .encoding = integer(), .defaults = getOption("RCurlOptions"))
dupCurlHandle(curl, ..., .opts = NULL, .encoding = integer())
getCurlMultiHandle(..., .handles = list(...))
}
\arguments{
  \item{curl}{the existing curl handle that is to be duplicated}
  \item{...}{a named list of curl options to set after the handle has
    been created. For \code{getCurlMultiHandle}, these values are
    invidivual curl handle objects, created via \code{getCurlHandle} or \code{dupCurlHandle}. }
  \item{.opts}{a named list or \code{CURLOptions} object identifying the
    curl options for the handle. These and the \code{...} arguments are
    used after the handle has been created.}
  \item{.encoding}{an integer or a string that explicitly identifies the
    encoding of the content that is returned by the HTTP server in its
    response to our query. The possible strings are
    \sQuote{UTF-8} or \sQuote{ISO-8859-1}
    and the integers should be specified symbolically
    as  \code{CE_UTF8} and \code{CE_LATIN1}.
    Note that, by default, the package attempts to process the header of
    the HTTP response to determine the encoding. This argument is used
    when such information is erroneous and the caller knows the correct
    encoding.
  }
  \item{.defaults}{a collection of default values taken from R's
    global/session options. This is a parameter so that one can override
    it if necessary.}
  \item{.handles}{a list of curl handle objects that are used as the
    individual request handles within the multi-asynchronous requests}
}
\details{
  These functions create C-level data structures.
}
\value{
  An object of class \code{CURLHandle}
  which is simply a pointer to the memory for the C
  structure.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}


\seealso{
  \code{\link{getURL}}
  \code{\link{curlPerform}}
}
\examples{

  options(RCurlOptions = list(verbose = TRUE,
                              followlocation = TRUE,
                              autoreferer = TRUE,
                              nosignal = TRUE))
  if(url.exists("http://www.omegahat.org/RCurl")) {
     x = getURL("http://www.omegahat.org/RCurl")
        # here we override one of these.
     x = getURL("http://www.omegahat.org/RCurl", verbose = FALSE)
  }
}
\keyword{IO}


