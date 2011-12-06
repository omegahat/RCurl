\name{ftpUpload}
\alias{ftpUpload}
\title{Upload content via FTP}
\description{
 This function is a relatively simple wrapper for \code{\link{curlPerform}}
 which allows the caller to upload a file to an FTP server.
 One can upload the contents of a file from the local file system or 
 the contents already in memory. 
 One specifies the FTP server and the fully-qualified file name and path where the contents are 
 to be stored.
 One can specify the user login and password via the \code{userpwd} option
 for  \code{\link{curlPerform}} via the \dots parameter, or
 one can put this information directly in the target URL (i.e. \code{to})
 in the form \code{ftp://login:password@machine.name/path/to/file}.

 This function can handle binary or text content.
}
\usage{
ftpUpload(what, to, asText = inherits(what, "AsIs") || is.raw(what), ..., curl = getCurlHandle())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{what}{the name of a local file or the contents to be uploaded. This can 
    can be text or binary content. This can also be an open connection.
   If this value is \code{raw} or has class \code{AsIs} by being enclosed within \code{I()},
    it is treated as literal content.}
  \item{to}{the URL to which the content is to be uploaded. This should be the ftp server
    with the prefix \code{ftp://} and optionally the
     user login and password, and then the path to the file in which the 
     content is to be stored.}
  \item{asText}{a logical value indicating whether to treat the value of \code{what}
    as content, be it text or raw/binary vector.  Otherwise, \code{what} is 
    treated as the name of a file.}
  \item{\dots}{additional arguments passed on to \code{\link{curlPerform}}.}
  \item{curl}{the curl handle to use for the \code{\link{curlPerform}}}
}
\value{
 The result of the \code{\link{curlPerform}} call.
}
\references{FTP, libcurl}
\author{Duncan Temple Lang}
\note{
 One can also provide additional FTP commands that are executed
 before and after the upload as part of the request.
 Use the prequote, quote, and postquote options in \code{\link{curlPerform}} for these.
}
\seealso{
 \code{\link{curlPerform}}
 \code{\link{getCurlHandle}}
}
\examples{
 \dontrun{

  ftpUpload(I("Some text to be uploaded into a file\nwith several lines"),
            "ftp://login:password@laptop17/ftp/zoe",
            )

  ftpUpload(I("Some text to be uploaded into a file\nwith several lines"),
            "ftp://laptop17/ftp/zoe",
            userpwd = "login:password"
            )

  ftpUpload(system.file("examples", "system.png", package = "RCurl"), 
            "ftp://login:password@laptop17/ftp/Election.rda",
            postquote = c("CWD subdir", "RNFR Election.rda", "RNTO ElectionPolls.rda")
            )
 }
}
\keyword{IO}
\keyword{programming}
