\name{curlSetOpt}
\alias{curlSetOpt}
\title{Set values for the CURL options}
\description{
  This function allows us to set values for the
  possible options in the CURL data structure
  that defines the HTTP request.
  These options persist across calls in the
  \code{CURLHandle} object.
}
\usage{
curlSetOpt(..., .opts = list(), curl = getCurlHandle(),
            .encoding = integer(), .forceHeaderNames = FALSE,
             .isProtected = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{...}{a named list of curl options to set after the handle has
    been created.}
  \item{.opts}{a named list or \code{CURLOptions} object identifying the
    curl options for the handle.}  
  \item{curl}{the \code{CURLHandle} object created earlier via
    a call to \code{\link{getCurlHandle}} or
    \code{\link{dupCurlHandle}}}
  \item{.encoding}{an integer or a string that explicitly identifies the
    encoding of the content that is returned by the HTTP server in its
    response to our query. The possible strings are
    \sQuote{UTF-8} or \sQuote{ISO-8859-1}
    and the integers should be specified symbolically
    as  \code{CE_UTF8} and \code{CE_LATIN1}.
    Note that, by default, the package attempts to process the header of
    the HTTP response to determine the encoding. This argument is used
    when such information is erroneous and the caller knows the correct
    encoding.
  }
  \item{.forceHeaderNames}{a logical value which if \code{TRUE}
    allows the caller to explicitly indicate that the HTTPHEADER
    option needs to have the names prefixed to the strings.
    This removes any ambiguity caused by the presence of ':' in the
    values  appearing to be the separator between the name and the value
    of the \code{name: value} pairs of the HTTP header.}
  \item{.isProtected}{
   a logical vector (or value that is repeated) specifying which 
   of the values in \dots and \code{.opts} need to be explicitly
   protected from garbage collection or not.
   The basic idea is that we specify \code{FALSE} if
   the value being set for the curl option may be garbage collected
   before the \code{curl} handle is garbage collected.  This would leave 
   the \code{curl} object in an inconsistent state, referring to an R
   object (i.e. an R function), which may be used after the R object has been garbage collected. 
  }
}
\value{
  An integer value giving the status of the return.
  This should be 0 as if there was an error in the libcurl
  mechiansim,   we will throw it there.
}

\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
  \code{\link{getCurlHandle}}
  \code{\link{dupCurlHandle}}  
}
\examples{
if(url.exists("http://www.omegahat.org")) {

  curl = getCurlHandle()
     # Note the header that extends across two lines with the second line
     # prefixed with white space.
   curlSetOpt( .opts = list(httpheader = c(Date = "Wed, 1/2/2000 10:01:01",
                            foo="abc\n    extra line"), verbose = TRUE),
               curl = curl)
   ans = getURL("http://www.omegahat.org", curl = curl)
}
}
\keyword{IO}


