\name{guessMIMEType}
\alias{guessMIMEType}
\title{Infer the MIME type from a file name}
\description{
  This function returns the MIME type, i.e. part of the value
  used in the Content-Type for an HTTP request/response
  or in email to identify the nature of the content.
  This is a string such as "text/plain" or "text/xml"
  or "image/png".

  The function consults an R object constructed
  by reading a Web site of known MIME types (not necessarily all)
  and matching the extension of the file name to the names of that table.
}
\usage{
guessMIMEType(name, default = NA)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{name}{character vector of file names}
  \item{default}{the value to use if no MIME type is found in the table
    for the given file name/extension.}
}
\value{
 A character vector giving the MIME types for each element of \code{name}.
}
\references{
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
\author{
Duncan Temple Lang
}


\seealso{
 Uploading file.
}
\examples{
 guessMIMEType(c("foo.txt", "foo.png", "foo.jpeg", "foo.Z", "foo.R"))

 guessMIMEType("foo.bob")
 guessMIMEType("foo.bob", "application/x-binary")
}
\keyword{IO}

