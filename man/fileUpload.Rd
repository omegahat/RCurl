\name{fileUpload}
\alias{fileUpload}
\title{Specify information about a file to upload in an HTTP request}
\description{
  This function creates an object that describes all of the details
  needed to include the contents of a file in the submission of an
  HTTP request, typically a multi-part form submitted via
  \code{\link{postForm}}.
  The idea is that we want to transfer the contents of a file or a
  buffer of data within R that is not actually stored on the file
  system but is resident in the R session.  We want to be able to
  specify either the name of the file and have RCurl read the contents
  when they are needed, or alternatively specify the contents ourselves
  if it makes sense that we already have the contents in R, e.g. that
  they are dynamically generated. Additionally, we may need to specify
  the type of data in the file/buffer via the Content-Type field for
  this parameter in the request.
  This function allows us to specify either the file name or contents
  and optionally the content type.

  This is used as an element in of the \code{params} argument
  \code{\link{postForm}} and the native C code understands and processes
  objects returned from this function.
   
}
\usage{
fileUpload(filename = character(), contents = character(), contentType = character())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{the name of the file that RCurl is to pass in the form
    submission/HTTP request. If this is specified and no value for
    \code{contents} is given, this has to identify a valid/existing
    file.  If \code{contents} is specified, any value provided here
    is used simply to provide information about the provenance of the
    data in contents. The file need not exist.
    The path is expanded by the function, so \code{~} can be used.
   }
  \item{contents}{ either a character vector or a \code{raw} vector
    giving the contents or data to be submitted. If this is provided,
    \code{filename} is not needed and not read.
  }
  \item{contentType}{a character string (vector of length 1) giving the
    type of the content, e.g. text/plain, text/html, which helps the
    server receiving the data to interpret the contents.  If omitted,
    this is omitted from the form submission and the recipient left to guess.
  }
}
\value{
  An object of (S3) class \code{FileUploadInfo} with fields
  \code{filename}, \code{contents} and \code{contentType}.
}

\references{
 \url{http://curl.haxx.se}
}
\author{Duncan Temple Lang}
\seealso{
  \code{\link{postForm}}
}
\examples{

}
\keyword{IO}
