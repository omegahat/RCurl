\name{complete}
\alias{complete}
\alias{complete,MultiCURLHandle-method}
\title{Complete an asynchronous HTTP request}
\description{
  This is a generic function that is used within the
  RCurl package to force the completion of an
  HTTP request. If the request is asynchronous,
  this essentially blocks until the request is completed
  by repeatedly asking for more information to be
  retrieved from the HTTP connection.
}
\usage{
complete(obj, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{the object which is to be completed. This is typically a
   \code{\link{MultiCURLHandle-class}} instance.}
  \item{\dots}{additional arguments intended to be used by specific methods.}
}
\value{

}
\references{
 \url{http://curl.haxx.se}, specifically the multi interface of libcurl.
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{MultiCURLHandle-class}}
  \code{\link{push}}, \code{\link{pop}}  
}
\examples{
if(url.exists("http://eeyore.ucdavis.edu/cgi-bin/testForm1.pl")) {

  f = system.file("NAMESPACE", package = "RCurl")
   postForm("http://eeyore.ucdavis.edu/cgi-bin/testForm1.pl",
            "fileData" = fileUpload(f))


   postForm("http://eeyore.ucdavis.edu/cgi-bin/testForm1.pl",
            "fileData" = fileUpload("",
                                    paste(readLines(f), collapse = "\n"),
                                    "text/plain"))

   postForm("http://eeyore.ucdavis.edu/cgi-bin/testForm1.pl",
            "fileData" = fileUpload(f,
                                    paste(readLines(f), collapse = "\n")
                                    ),
            .opts = list(verbose = TRUE, header = TRUE))
}
}
\keyword{IO}

