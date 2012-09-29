\name{MultiCURLHandle-class}
\docType{class}
\alias{MultiCURLHandle-class}
\alias{pop}
\alias{push}
\alias{pop,MultiCURLHandle,CURLHandle-method}
\alias{pop,MultiCURLHandle,character-method}
\alias{push,MultiCURLHandle,CURLHandle-method}

\title{Class "MultiCURLHandle" for asynchronous, concurrent HTTP requests}
\description{
  This is a class that represents a handle to an internal
  C-level data structure provided by libcurl to
  perform multiple HTTP requests in a single operation
  and process the responses in an inter-leaved fashion,
  i.e. a chunk from one, followed by a chunk from another.

  Objects of this class contain not only a reference to the
  internal C-level data structure, but also have a list
  of the \code{\link{CURLHandle-class}} objects
  that represent the individual HTTP requests that make up
  the collection of concurrent requests.
  These are maintained for garbage collection reasons.

  Essentially, the data in objects of this class are for internal use;
  this is an opaque class in R.
 } 
\section{Objects from the Class}{
  The constructor function  \code{\link{getCurlMultiHandle}}
  is the only way to create meaningful instances of this class.
}
\section{Slots}{
  \describe{
    \item{\code{ref}:}{Object of class \code{"externalptr"}. This is
      a reference to the instance of the libcurl data structure
      \code{CURLM} pointer.
      }
      \item{\code{subhandles}:}{Object of class \code{"list"}.
        This is a list of \code{\link{CURLHandle-class}}
	instances that have been \code{push()}ed onto the
	multi-handle stack.
      }
  }
}
\section{Methods}{
  \describe{
    \item{pop}{\code{signature(obj = "MultiCURLHandle", val = "CURLHandle")}: ... }
    \item{pop}{\code{signature(obj = "MultiCURLHandle", val = "character")}: ... }
    \item{push}{\code{signature(obj = "MultiCURLHandle", val = "CURLHandle")}: ... }
  }
}

\references{Curl homepage \url{http://curl.haxx.se}
  \url{http://www.omegahat.org/RCurl}
}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}
\seealso{
  \code{\link{getCurlMultiHandle}}
  \code{\link{curlMultiPerform}}
  \code{\link{multiTextGatherer}}    
}
%\examples{}
\keyword{classes}
