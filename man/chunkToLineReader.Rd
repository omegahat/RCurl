\name{chunkToLineReader}
\alias{chunkToLineReader}
\title{Utility that collects data from the HTTP reply into lines and
  calls user-provided function.
  }
\description{
  When one provides an R function to process the body of
  the R rep
}
\usage{
chunkToLineReader(f, verbose = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{f}{a function that is to be called each time
    the \code{read} function is invoked and there are complete
    lines in that input.}
  \item{verbose}{a logical value. If \code{TRUE},
    information is displayed when there is any text
    that does not form a complete line and is held
    for processing in the next chunk.
  }
}
\details{
  This constructs a closure and then processes each chunk as
  they are passed to the read function.
  It strips away any text that does not form a complete line
  at the end of the chunk and holds this to be added to the next chunk
  being processed.
}
\value{
  A list with two components
  \item{read}{the function that will do the actual reading from the
    HTTP response stream and call the function \code{f} on each
    step (assuming the chunk has a line marker.}
  \item{comp2 }{Description of 'comp2'}
  ...
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
  \code{\link{getURI}} and the \code{write} argument.
  \code{\link{getForm}}, \code{\link{postForm}}  
  \code{\link{curlPerform}}
}
\examples{
# Read a rectangular table of data into R from the URL
# and add up the values and the number of values read.

summer =
function()
{
  total = 0.0
  numValues = 0

  list(read = function(txt) {
                 con = textConnection(txt)
                 on.exit(close(con))
                 els = scan(con)
                 numValues <<- numValues + length(els)
                 total <<- total + sum(els)

                 ""
              },
       result = function() c(total = total, numValues = numValues))
}

s = summer()

if(url.exists("http://www.omegahat.org/RCurl/matrix.data"))
   getURL("http://www.omegahat.org/RCurl/matrix.data", write = chunkToLineReader(s$read)$read)
}
\keyword{IO}
\concept{Web}
\concept{HTTP}

