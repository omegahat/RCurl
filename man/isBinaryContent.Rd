\name{isBinaryContent}
\alias{isBinaryContent}
\alias{isBinaryFile}
\title{Determines if content appears to be text or binary}
\description{
  These functions attempt to guess if the content is binary or text
  by consulting the MIME type or the extension of the file name.
  These are made available via the package to allow others to use them
  when processing low-level HTTP responses.
}
\usage{
isBinaryContent(header, type = getContentType(header)[1],
                textTypes = getOption("text.content.types", textContentTypes))
}
\arguments{
  \item{header}{the header from the HTTP response which delivered the content}
  \item{type}{the MIME type}
  \item{textTypes}{a character vector giving the MIME types that  identify text content}
}
\value{
A logical value
}
\references{
  \url{http://www.webmaster-toolkit.com/mime-types.shtml}
}
\author{
Duncan Temple Lang
}

\seealso{
 \code{\link{getURLContent}},  \code{\link{dynCurlReader}}
}
\examples{
  z = getURLContent("http://www.omegahat.org/RCurl/data.gz", header = TRUE)
  z$header["Content-Type"]
  isBinaryContent(  z$header["Content-Type"] )

  z = getURLContent("http://www.omegahat.org/RCurl/index.html", header = TRUE)
  z$header["Content-Type"]
  isBinaryContent(  z$header["Content-Type"] )
}
\keyword{programming}

