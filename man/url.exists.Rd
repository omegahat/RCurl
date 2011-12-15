\name{url.exists}
\alias{url.exists}
\title{Check if URL exists}
\description{
  This functions is analogous to \code{\link[base]{file.exists}}
  and determines whether a request for a specific URL responds
  without error. We make the request but ask the server
  not to return the body. We just process the header.
}
\usage{
url.exists(url, ..., .opts = list(...),
            curl = getCurlHandle(.opts = .opts),
             .header = FALSE)
}
\arguments{
  \item{url}{the URL whose existence we are to test}
  \item{\dots}{name = value pairs of Curl options.}
  \item{.opts}{a list of name = value pairs of Curl options.}
  \item{curl}{a Curl handle that the caller can specify if she wants to
    reuse an existing handle, e.g. with different options already
    specified or that has previously established a connection to the Web
    server}
  \item{.header}{a logical value that if \code{TRUE} causes the header
    information to be returned.
  }
}
\details{
  This makes an HTTP request but with the nobody option set to
  \code{FALSE} so that we don't actually retrieve the contents of the URL.
}
\value{
  If \code{.header} is \code{FALSE}, this returns
  \code{TRUE} or \code{FALSE} indicating whether
  the request was successful (had a status with a value
  in the 200 range).

  If \code{.header} is \code{TRUE}
}
\references{
  HTTP specification
}
\author{
Duncan Temple Lang
}
\seealso{
 \code{\link{curlPerform}}
}
\examples{
 url.exists("http://www.omegahat.org/RCurl")
 try(url.exists("http://www.omegahat.org/RCurl-xxx"))
}

