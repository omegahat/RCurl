\name{curlGlobalInit}
\alias{curlGlobalInit}
\alias{curlGlobalCleanup}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Start and stop the Curl library}
\description{
  These functions provide a way to both start/initialize
  and stop/uninitialize the libcurl engine.
  There is no need to call
  \code{curlGlobalInit} as it is done implicitly the
  first time one uses the libcurl facilities.
  However, this function does permit one to explicitly
  control how it is initialized.
  Specifically, on Windows one might want to
  avoid re-initializing the Win32 socket facilities
  if the  host application (e.g. R) has already done this.

  \code{curlGlobalInit} should only be called once per R session.
  Subsequent calls will have no effect, or may confuse the libcurl engine.

  One can reclaim the resources the libcurl engine is
  consuming via the \code{curlGlobalCleanup} function
  when one no longer needs the libcurl facilities in
  an R session.
}
\usage{
curlGlobalInit(flags = c("ssl", "win32"))
curlGlobalCleanup()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{flags}{flags indicating which features to activate.
    These come from the \code{\link{CurlGlobalBits}}
    bit-field.  The default is to activate both SSL and Win32 sockets
    (if on Windows).  One can specify either the names of the features
    that are matched (via \code{\link{setBitIndicators}}) or
    the integer value.
  }
}
\value{
  \code{curlGobalInit} returns a status code which should be 0.
  \code{curlGlobalCleanup} returns \code{NULL} in  all cases.
}


\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
 \code{\link{getCurlHandle}}  
 \code{\link{curlPerform}}
}
\examples{
    # Activate only the SSL.
 curlGlobalInit("ssl")

\dontrun{
# Don't run these automatically as we should only call this function
# once per R session

    # Everything, the default.
 curlGlobalInit()

   # Nothing.
 curlGlobalInit("none")
 curlGlobalInit(0)
}

}
\keyword{IO}
