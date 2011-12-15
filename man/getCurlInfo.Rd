\name{getCurlInfo}
\alias{getCurlInfo}
\alias{getCurlInfoConstants}
\title{Access information about a CURL request}
\description{
  This function provides access to data about a previously
  executed CURL request that is accessible via a
  \code{CURLHandle} object.
  This means, of course, that one must have access to the \code{CURLHandle}
  object.
  The information one can get includes items such as the name of the
  file (potentially containing redirects), download time,

  See \code{\link{getCurlInfoConstants}} for the names of the possible fields.
}
\usage{
getCurlInfo(curl, which = getCurlInfoConstants())
getCurlInfoConstants()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{curl}{the \code{CURLHandle} object used to perform the request.
    This is a reference to an opaque internal C-level data structure that is
    provided and used by libcurl to make a request.}
  \item{which}{identifiers for the elements of interest.
    These can be specified by integer value or by name.
    The names are matched against those in the
    \code{\link{getCurlInfoConstants}}}.
}
\details{
  This is an interface to the \code{get_curl_info} routine in
  the libcurl package. 
}
\value{
  A named list whose elements correspond
  to the requested fields.
  The names are expanded to match the names of these
  fields and the values are either strings or integer values.
}

\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}



\seealso{
  \code{\link{curlPerform}}
  \code{\link{getURL}}  
  \code{\link{getCurlHandle}}
}
\examples{
 if(url.exists("http://www.omegahat.org/RCurl/index.html")) {
    curl = getCurlHandle()
    getURL("http://www.omegahat.org/RCurl/index.html", curl = curl)
    getCurlInfo(curl)
    rm(curl)  # release the curl!
 }
}
\keyword{IO}

