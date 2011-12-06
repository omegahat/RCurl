\name{mimeTypeExtensions}
\alias{mimeTypeExtensions}
\docType{data}
\title{Mapping from extension to MIME type}
\description{
  This is a programmatically generated character vector
  whose names identify the  MIME type typically associated with
  the extension which are the values.
  This is used in \code{\link[RCurl]{guessMIMEType}}.
  We can match an extension and then find the corresponding
  MIME type.
  There are duplicates.
}
\usage{data(mimeTypeExtensions)}
\format{
  The format is a named character vector
  where the names are the MIME types
  and the values are the file
  extensions.
}
\source{
The table of MIME types and extensions was programmatically extracted
from \url{http://www.webmaster-toolkit.com/mime-types.shtml} or
\url{http://reference.sitepoint.com/html/mime-types-full} with
\code{
  tbls = readHTMLTable("http://www.webmaster-toolkit.com/mime-types.shtml")
  tmp = tbls[[1]][-1,]
  mimeTypeExtensions = structure(as.character(tmp[[2]]), names = gsub("^\\.", "", tmp[[1]]))
  save(mimeTypeExtensions, file = "data/mimeTypeExtensions.rda")
}
The IANA list is not as convenient to programmatically compile.
\url{http://www.ltsw.se/knbase/internet/mime.htp}  
}
%\references{}
\examples{
data(mimeTypeExtensions)
}
\keyword{datasets}
