\name{getURIAsynchronous}
\alias{getURIAsynchronous}
\alias{getURLAsynchronous}
\title{Download multiple URIs concurrently, with inter-leaved downloads}
\description{
  This function allows the caller to specify multiple URIs to download
  at the same time. All the requests are submitted and then the replies
  are processed as data becomes available on each connection.
  In this way, the responses are processed in an inter-leaved fashion,
  with a chunk from one response from one request being processed and
  then followed by a chunk from a different request.


  Downloading documents asynchronously involves some trade-offs.
  The switching between different streams, detecting when input is
  available on any of them involves a little more processing
  and so increases the consumption of CPU cycles.
  On the other hand, there is a potentially large saving of
  time when one considers total time to download.
  See \url{http://www.omegahat.org/RCurl/concurrent.xml}
  for more details.  This is a common trade-off that arises in
  concurrent/parallel/asynchronous computing.
   

  \code{\link{getURI}} calls this function if more than one
  URI is specified and \code{async} is \code{TRUE}, the default in this case.
  One can also download the (contents of the) multiple URIs
  serially, i.e. one after the other using \code{\link{getURI}}
  with a value of \code{FALSE} for \code{async}.
}
\usage{
getURIAsynchronous(url, ..., .opts = list(), write = multiTextGatherer(url),
                   curl = getCurlHandle(),
                    multiHandle = getCurlMultiHandle(), perform = Inf,
                     .encoding = integer())
}
\arguments{
  \item{url}{a character vector identifying the URIs to download.}
  \item{\dots}{named arguments to be passed to \code{\link{curlSetOpt}}
    when creating each of the different \code{curlHandle} objects.}
  \item{.opts}{a named list or \code{CURLOptions} object identifying the
    curl options for the handle. This is merged with the values of \dots
    to create the actual options for the curl handle in the request.}  
  \item{write}{an object giving the functions or routines that are to be
    called when input is waiting  on the different HTTP response
    streams.
    By default, a separate callback function is associated with each
    input stream. This is necessary for the results to be meaningful
    as if we use a single reader, it will be called for all streams
    in a haphazard order and the content interleaved.
    One can do interesting things however using a single object.
  }
  \item{curl}{the prototypical curlHandle that is duplicated and used in
   in }
 \item{multiHandle}{
   this is a curl handle for performing asynchronous requests.
 }
 \item{perform}{a number which specifies the maximum number of calls to
   \code{\link{curlMultiPerform}} that are to be made in this
   function call. This is typically either 0 for no calls
   or \code{Inf} meaning process the requests until completion.
   One may find alternative values useful, such as 1 to ensure that
   the requests are dispatched.
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
  } 
}
\details{
  This uses \code{\link{curlMultiPerform}}
  and the multi/asynchronous interface for libcurl.
}
\value{
  The return value depends on the run-time characteristics
  of the call.
  If the call merely specifies the URIs to be downloaded, the result
  is a named character vector. The names identify the URIs
  and the elements of the vector are the contents of the corresponding
  URI.

  If the requests are not performed or completed
  (i.e. \code{perform} is zero  or too small a value to process all the chunks)
  a list with 2 elements is returned.
  These elements are:
  \item{multiHandle}{the curl multi-handle, of class
    \code{\link{MultiCURLHandle-class}}. This can be used
    in further calls to \code{\link{curlMultiPerform}}}
  \item{write}{the \code{write} argument (after it was potentially
    expanded to a list). This can then be used to fetch the results
    of the requests when the requests are completed in the future.
  }
  
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
  \code{\link{getURL}}
  \code{\link{getCurlMultiHandle}}
  \code{\link{curlMultiPerform}}  
}
\examples{
  uris = c("http://www.omegahat.org/RCurl/index.html", "http://www.omegahat.org/RCurl/philosophy.xml")
  txt = getURIAsynchronous(uris)
  names(txt)
  nchar(txt)
}
\keyword{IO}
\concept{Web}
\concept{URI}
\concept{Web services}


