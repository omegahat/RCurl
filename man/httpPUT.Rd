\name{httpPUT}
\alias{httpPUT}
\alias{httpPOST}
\alias{httpGET}
\alias{httpDELETE}
\title{Simple high-level functions for HTTP PUT and DELETE}
\description{
  These two functions are simple, high-level functions
  that implement the HTTP request methods PUT and DELETE.
  These can also be done by specifying the method
  type using the curl option \code{customrequest}.
  These functions merely provide a convenience
  wrapper for \code{\link{getURLContent}}
  with the HTTP method specified.
}
\usage{
httpPUT(url, content,  ..., curl = getCurlHandle())
httpPOST(url, ..., curl = getCurlHandle())
httpDELETE(url, ..., curl = getCurlHandle())
httpGET(url, ..., curl = getCurlHandle())
}
\arguments{
  \item{url}{the URL of the server to which the HTTP request is to be
    made}
  \item{content}{the value that is to be used as the content of the
    \code{PUT} request. This can be a character or a \code{raw} object.}
  \item{\dots}{additional arguments passed to \code{\link{getURLContent}}}
  \item{curl}{the curl handle to be used to make the request}
}
\value{
 The content returned by the server as a result of the request.
}
\author{
Duncan Temple Lang
}

\seealso{
\code{\link{getURLContent}}
}
\examples{
\dontrun{
   # create a database in a CouchDB server
 httpPUT("http://127.0.0.1:5984/temp_db")

   # Insert an entry into an ElasticSearch dabtabase.
 httpPUT("http://localhost:9200/a/b/axyz", '{"abc" : 123}')

   # Then delete the database
 httpDELETE("http://127.0.0.1:5984/temp_db")
}
}
\keyword{programming}
\concept{HTTP}
