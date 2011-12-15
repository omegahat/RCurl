\name{curlPerform}
\alias{curlPerform}
\alias{curlMultiPerform}
\title{Perform the HTTP query}
\description{
  These function causes the HTTP query, that has been specified
  via the different options in this and other calls, to be sent and processed.
  Unlike in curl itself,
  for \code{curlPerform} one can specify all the options
  in this call as an atomic invocation.
  This avoids having to set the options and then perform
  the action. Instead, this is all done in one call.

  For \code{curlMultiPerform}, one must add the relevant
  \code{\link{CURLHandle-class}} objects to the
  \code{\link{MultiCURLHandle-class}} objects
  before issuing the call to \code{curlMultiPerform}.
}
\usage{
curlPerform(..., .opts = list(), curl = getCurlHandle(), .encoding = integer())
curlMultiPerform(curl, multiple = TRUE)
}
\arguments{
  \item{curl}{for \code{curlPerform}, this is the \code{CURLHandle}
    object giving the structure for the
    options  and that will process the command.
    For \code{curlMultiPerform}, this is an object of class
    code \code{\link{MultiCURLHandle-class}}.}
  \item{...}{a named list of curl options to set after the handle has
    been created.}
  \item{.opts}{a named list or \code{CURLOptions} object identifying the
    curl options for the handle. This is merged with the values of \dots
    to create the actual options for the curl handle in the request.}
  \item{multiple}{a logical value. If \code{TRUE} and the internal call
    to \code{curl_multi_perform} returns a value that indicates there is
    still data available from one of the HTTP responses, we call
    \code{curl_multi_perform} repeatedly until there is no more data
    available  at that time. If this is \code{FALSE}, we call
    \code{curl_multi_perform} once and return, regardless of whether
    there is more data available. This is convenient if we want to limit
    the time spent in the call to \code{curlMultiPerform}.
  }
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

    Note that the encoding argument is not a regular libcurl option and
    is handled specially by RCurl. But as a result, it is not unset
    in subsequent uses of the curl handle (\code{curl}).
  }
}
\details{
}
\value{
  A integer value indicating the status of the request.
  This should be 0 as other errors will generate
  errors.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
 \code{\link{getURL}}
 \code{\link{postForm}}
 \code{\link{getForm}}
 \code{\link{curlSetOpt}}
}
\examples{
if(url.exists("http://www.omegahat.org/RCurl")) {
  h = basicTextGatherer()
  curlPerform(url = "http://www.omegahat.org/RCurl", writefunction = h$update)
   # Now read the text that was cumulated during the query response.
  h$value()
}


if(url.exists("http://services.soaplite.com/hibye.cgi")) {
     # SOAP request
  body = '<?xml version="1.0" encoding="UTF-8"?>\
<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" \
                   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" \
                   xmlns:xsd="http://www.w3.org/1999/XMLSchema" \
                   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" \
                   xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">\
  <SOAP-ENV:Body>\
       <namesp1:hi xmlns:namesp1="http://www.soaplite.com/Demo"/>\
  </SOAP-ENV:Body>\
</SOAP-ENV:Envelope>\n'


  h$reset()
  curlPerform(url = "http://services.soaplite.com/hibye.cgi",
              httpheader=c(Accept="text/xml", Accept="multipart/*", SOAPAction='"http://www.soaplite.com/Demo#hi"',
                           'Content-Type' = "text/xml; charset=utf-8"),
              postfields=body,
              writefunction = h$update,
              verbose = TRUE
             )

  body = h$value()

}


   # Using a C routine as the reader of the body of the response.
if(url.exists("http://www.omegahat.org/RCurl/index.html")) {
  routine = getNativeSymbolInfo("R_internalWriteTest", PACKAGE = "RCurl")$address
  curlPerform(URL = "http://www.omegahat.org/RCurl/index.html",
              writefunction = routine)
}
}
\keyword{IO}


