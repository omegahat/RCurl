\name{getBinaryURL}
\alias{getBinaryURL}
\title{Download binary content}
\description{
  This function allows one to download binary content.
  This is a convenience function that is a call to
  \code{\link{getURL}} with suitable values
  for the \code{write} and \code{file} options
  for the Curl handle. These take care of processing
  the body of the response to the Curl request into a
  vector of "raw" elements.

  Binary content from POST forms or other requests that are not simple
  URL requests can be implemented using the same approach as this
  function, i.e., specifying the same values as in the body of this function for
  \code{write} and \code{file} in the call to \code{\link{curlPerform}}.
  
}
\usage{
getBinaryURL(url, ..., .opts = list(), curl = getCurlHandle(), .buf = binaryBuffer(.len), .len = 5000)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{url}{the URL identifying the content to download.
    This can be a regular URL or a
    \code{application/x-www-form-urlencoded} URL,
    i.e. with name=value parameters appended to the location via a ?,
    and separated  from each other via a \&.}
  \item{\dots}{additional arguments that are passed to \code{\link{getURL}}.}
  \item{.opts}{a list of named values that are passed to
    \code{\link{getURL}} as the \code{.opts} argument.}
  \item{curl}{an optional curl handle used in \code{\link{curlPerform}}
    that has been created previously and is to be reused for this
    request.
    This allows the R user to reuse a curl handle that already has a
    connection to the server or has settings for options that have been
    set previously.} 
  \item{.buf}{a raw vector in which to insert the body of the response.
   This is a parameter to allow the caller to reuse an existing buffer.}
  \item{.len}{an non-negative integer which is used as the length for
    the buffer in which to store the binary data in the response.
    The buffer is extended if it is not big enough but this allows the
    caller to provide context specific knowledge about the length of the
    response, e.g. the size of the file being downloaded, and
    avoid expanding the buffer as the material is being processed.
  }
}
\value{
  A "raw" vector.
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{getURL}}
  \code{\link[base]{raw}}
  %\code{\link[Rcompression]{gunzip}}
  \code{gunzip} in the \code{Rcompression} package.
}
\examples{
  u = "http://www.omegahat.org/RCurl/data.gz"

if(url.exists(u)) {

  content = getBinaryURL(u)

  if(require(Rcompression)) {
    x = gunzip(content)
    read.csv(textConnection(x))
  } else {
     tmp = tempfile()
     write(content, file = tmp)
     read.csv(gzfile(tmp))
  }


   # Working from the Content-Type in the header of the HTTP response.
  h  = basicTextGatherer()
  content = getBinaryURL(u, .opts = list(headerfunction = h$update))
  header = parseHTTPHeader(h$value())
  type = strsplit(header["Content-Type"], "/")[[1]]

  if(type[2] \%in\% c("x-gzip", "gzip")) {
    if(require(Rcompression)) 
        x = gunzip(content)
  }

}
}
\keyword{IO}
\keyword{programming}
\concept{binary data}
