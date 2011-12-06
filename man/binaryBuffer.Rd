\name{binaryBuffer}
\alias{binaryBuffer}
\alias{coerce,RCurlBinaryBuffer,raw-method}
\title{Create internal C-level data structure for collecting binary data}
\description{
  This is the constructor function for creating an internal data
  structure
  that is used when reading binary data from an HTTP request
  via RCurl.  It is used with the native routine
  \code{R_curl_write_binary_data} for collecting
  the response from the HTTP query into a buffer that stores
  the bytes. The contents can then be brought back into R
  as a \code{raw} vector and then used in different ways,
  e.g. uncompressed with the \code{Rcompression} package,
  or written to a file via \code{\link[base]{writeBin}}.
}
\usage{
binaryBuffer(initialSize = 5000)
}
\arguments{
  \item{initialSize}{a number giving the size (number of bytes) to
    allocate for the buffer. In most cases, the size won't make an
    enormous difference. If this is small, the
    \code{R_curl_write_binary_data} routine will expand it as necessary
    when more daat is received than would fit in it.  If it is very
    large, i.e. larger than the resulting response, the consequence is
    simply unused memory.   One can determine the appropriate size by
     performing the HTTP request with \code{nobody = TRUE} and looking
     at the resulting size indicated by the headers of the response,
     i.e.
     \code{getCurlInfo(handle)} and then using that size and repeating
     the request and receiving the body. This is a trade-off between
     network speed and memor consumption and processing speed when
     collecting the .
   }
}
\details{
}
\value{
  An object of class \code{RCurlBinaryBuffer} which is to be treated
  as an opaque data for the most part. When passing this as the value of
  the \code{file} option, one will have to pass the ref slot.

  After the contents have been read, one can convert this object to an R
  raw vector using \code{as(buf, "raw")}.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
 \code{R_curl_write_binary_data}
}
\examples{
  buf = binaryBuffer()

     # Now fetch the binary file.
  getURI("http://www.omegahat.org/RCurl/xmlParse.html.gz",
         write = getNativeSymbolInfo("R_curl_write_binary_data")$address,
         file = buf@ref)

   # Convert the internal data structure into an R raw vector
  b = as(buf, "raw")

 if(require(Rcompression)) 
   gunzip(b)

}
\keyword{IO}
\keyword{programming}
\concept{Web}
\concept{binary data}

