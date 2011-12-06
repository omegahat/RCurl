\name{curlEscape}
\alias{curlEscape}
\alias{curlUnescape}
\alias{curlPercentEncode}
\title{Handle characters in URL that need to be escaped}
\description{
  These functions convert between URLs that are
  human-readable and those that have special characters
  escaped.  For example, to send a URL with a space,
  we need to represent the space as \code{\%20}.

  \code{curlPercentEncode} uses a different format than the
  \code{curlEscape}
  function and this is needed for x-www-form-encoded POST submissions.
}
\usage{
curlEscape(urls)
curlUnescape(urls)
curlPercentEncode(x, amp = TRUE, codes = PercentCodes, post.amp = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{urls}{ a character vector giving the strings to be escaped or
    unescaped.}
  \item{x}{the strings to be encoded via the percent-encoding method}
  \item{amp}{a  logical value indicating whether to encode \&
    characters.}
  \item{codes}{the named character vector giving the encoding map. The
    names are the characters we encode, the values are what we encode them
    as.}
  \item{post.amp}{a logical value controlling whether the resulting
  string is further processed to escape the percent (\%) prefixes with
  the code for percent, i.e. \%25.}
}
\details{
  This calls \code{curl_escape} or \code{curl_unescape} in the libcurl library.
}
\value{
  A character vector that has corresponding elements
  to the input with the characters escaped or not.
}
\references{
  Curl homepage \url{http://curl.haxx.se}
  
  Percent encoding explained in \url{http://en.wikipedia.org/wiki/Percent-encoding}
}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\examples{
  curlEscape("http://www.abc.com?x=a is a sentence&a b=and another")

  # Reverse it should get back original
  curlUnescape(curlEscape("http://www.abc.com?x=a is a sentence&a b=and another"))
}
\keyword{IO}


