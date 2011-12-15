\name{curlError}
\alias{curlError}
\title{Raise a warning or error about a CURL problem}
\description{
  This function is called to raise an error or warning
  that arises from a curl operation when making a request.
  This is called from C code that encounters the error
  and this function is responsible for generating the error.
}
\usage{
curlError(type, msg, asError = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{type}{the type of the error or a status code identifying the
    type of the error. Typically this is an integer value that
    identifies the type of the Curl error. The value corresponds
    to one of the enumerated value of type \code{CURLcode}.}
  \item{msg}{the error message, as a character vector of length 1}
  \item{asError}{a logical value that indicates whether to raise an
    error or a warning}
}
\value{
 This calls \code{warning} or \code{stop} with the relevant condition
 object.
 The object is always of basic  (S3) class
 \code{GenericCurlError, error, condition}
 or
 \code{GenericCurlError, warning, condition}.
 When the \code{type} value corresponds to a
 \code{CURLCode} value, the condition has the primary class given by that
 \code{CURLCode}'s name, e.g. \code{COULDNT_RESOLVE_HOST},
  \code{TOO_MANY_REDIRECTS} (with the CURLE prefix removed).

}
\references{
libcurl documentation.
}
\author{
Duncan Temple Lang
}

\seealso{
\code{\link{curlPerform}}
}
\examples{
  # This illustrates generating and catching an error.
  # We intentionally give a mis-spelled URL.
 tryCatch(curlPerform(url = "ftp.wcc.nrcs.usda.govx"),
          COULDNT_RESOLVE_HOST = function(x) cat("resolve problem\n"),
          error = function(x) cat(class(x), "got it\n"))
}
\keyword{programming} 
\keyword{IO}
\concept{error handling}

