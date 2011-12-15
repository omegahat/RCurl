\name{dynCurlReader}
\alias{dynCurlReader}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Dynamically determine content-type of body from HTTP header and
  set body reader}
\description{
  This function is used for the \code{writefunction}
  option in a curl HTTP request.
  The idea is that we read the header of the HTTP response
  and when our code determines that the header is complete
  (the presence of a blank line), it examines the contents
  of the header and finds a Content-Type field.
  It uses the value of this to determine the nature of the
  body of the HTTP response and dynamically (re)sets the reader
  for the curl handle appropriately. If the content is binary,
  it collects the content into a \code{raw} vector;
  if it is text, it sets the appropriate character encoding
  and collects the content into a character vector.

  This function is like \code{\link{basicTextGatherer}}
  but behaves dynamically by determining how to read the content
  based on the header of the HTTP response.
  This function returns a list of functions that are used
  to update and query a shared state across calls.
  
}
\usage{
dynCurlReader(curl = getCurlHandle(), txt = character(), max = NA,
              value = NULL, verbose = FALSE, binary = NA, baseURL = NA,
              isHTTP = NA, encoding = NA)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{curl}{the curl handle to be used for the request. It is
    essential that this handle be used in the low-level call to
    \code{\link{curlPerform}} so that the update
    element sets the reader for the body on the appropriate
    curl handle that is used in the request.
   }
  \item{txt}{initial value of the text. This is almost always an empty
     character vector.}
  \item{max}{the maximum number of characters to read. This is almost
    always \code{NA}.}
  \item{value}{a function that can be specified which will be used to
    convert the body of the response from text or raw in a customized
    manner,
    e.g. uncompress a gzip body. This can als be done explicitly
    with a call \code{fun(reader$value())} after the body has been read.
    The advantage of specifying the function in the constructor of the
    reader  is that the end-user doesn't have to know which function to
    use to do the conversion.
   }
  \item{verbose}{a logical value indicating whether messages about
    progress and operations are written on the console as the
    header and body are processed.
  }
  \item{binary}{a logical value indicating whether the caller  knows
    whether the resulting content is binary (\code{TRUE}) or not
    (\code{FALSE}) or unknown (\code{NA}).
  }
  \item{baseURL}{the URL of the request which can be used to follow
    links to other URLs that are described relative to this.
  }
  \item{isHTTP}{a logical value indicating whether the request/download uses
   HTTP or not. If this is \code{NA}, we determine this when the header
   is received.  If the caller knows this is an FTP or other request,
   they can specify this when creating the reader.}
 \item{encoding}{a string that allows the caller to specify and override
  the encoding of the result. This is used to convert text returned
  from the server.}
}
\value{
  A list with 5 elements all of which are functions. These are
  \item{update}{the function that does the actual reading/processing of
    the content that libcurl passes to it from the header and the
    body. This is the work-horse of the reader.}
  \item{value}{a function to get the body of the response}
  \item{header}{a function to get the content of the HTPP header}  
  \item{reset}{a function to reset the internal contents which allows
    the same reader to be re-used in subsequent HTTP requests}
  \item{curl}{accessor function for the curl handle specified in the
    call to create this dynamic reader object.}
  
  This list has the S3 class vector
  \code{c("DynamicRCurlTextHandler", "RCurlTextHandler", "RCurlCallbackFunction")}
}
\references{libcurl \url{http://curl.haxx.se}}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{basicTextGatherer}}
  \code{\link{curlPerform}}
  \code{\link{getURLContent}}  
}
\examples{

   # Each of these examples can be done with getURLContent().
   # These are here just to illustrate the dynamic reader.
if(url.exists("http://www.omegahat.org/Rcartogram/demo.jpg")) {
  header = dynCurlReader()
  curlPerform(url = "http://www.omegahat.org/Rcartogram/demo.jpg", headerfunction = header$update, curl = header$curl())
  class( header$value() )
  length( header$value() )
}

if(url.exists("http://www.omegahat.org/dd.gz")) {
     # gzip example.
  header = dynCurlReader()
  curlPerform(url = "http://www.omegahat.org/dd.gz", headerfunction = header$update, curl = header$curl())
  class( header$value() )
  length( header$value() )

  if(require(Rcompression))
     gunzip(header$value())
}


   # Character encoding example
\dontrun{
  header = dynCurlReader()
  curlPerform(url = "http://www.razorvine.net/test/utf8form/formaccepter.sn",
               postfields = c(text = "ABC", outputencoding =  "UTF-8"),
               verbose = TRUE,
               writefunction = header$update, curl = header$curl())
  class( header$value() )
  Encoding( header$value() )
}
}
\keyword{IO}
\concept{binary}
