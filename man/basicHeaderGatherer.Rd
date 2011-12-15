\name{basicHeaderGatherer}
\alias{basicHeaderGatherer}
\alias{parseHTTPHeader}
\title{Functions for processing the response header of a libcurl request}
\description{
  These two functions are used to collect the contents of the header of
  an HTTP response via the \code{headerfunction} option of a curl handle
  and then processing that text into both the name: value pairs
  and also the initial line of the response that provides the
  status of the request.
  \code{basicHeaderGatherer} is a simple special case of
  \code{\link{basicTextGatherer}} with the built-in post-processing
  step done by \code{parseHTTPHeader}.
}
\usage{
basicHeaderGatherer(txt = character(), max = NA)
parseHTTPHeader(lines, multi = TRUE)
}
\arguments{
  \item{txt}{any initial text that we want included with the header.
      This is passed to \code{\link{basicTextGatherer}}. Generally it
      should not be specified unless there is a good reason.}
    \item{max}{This is passed directly to
      \code{\link{basicTextGatherer}}}
   \item{lines}{ the text as a character vector from the response header
     that
     \code{parseHTTPHeader} will convert to a status and name-value
     pairs.} 
   \item{multi}{a logical value controlling whether we check for
     multiple HTTP headers in the lines of text. This is caused
     by a Continue being concatenated with the actual response.
     When this is \code{TRUE}, we look for the lines
     that start an HTTP header, e.g. \code{HTTP 200 ...},
     and we use the content from the last of these.
    }
}
\value{
  The return value is the same as \code{\link{basicTextGatherer}},
  i.e. a list with
  \code{update}, \code{value} and \code{reset} function elements.
  The \code{value} element will invoke \code{parseHTTPHeader}
  on the contents read during the processing of the  libcurl request
  and return that value.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
  \code{\link{basicTextGatherer}}
  \code{\link{curlPerform}}    
  \code{\link{curlSetOpt}}  
}
\examples{
  if(url.exists("http://www.omegahat.org/RCurl/index.html")) {
     h = basicHeaderGatherer()
     getURI("http://www.omegahat.org/RCurl/index.html",
              headerfunction = h$update)
     names(h$value())
     h$value()
  }
}
\keyword{IO}
\concept{network client}

