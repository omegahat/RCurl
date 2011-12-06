\name{basicTextGatherer}
\alias{basicTextGatherer}
\alias{multiTextGatherer}
\alias{debugGatherer}
\title{Cumulate text across callbacks (from an HTTP response)}
\description{
  These functions create callback functions that can be used
  to with the libcurl engine  when it passes information to us
  when it is available as part of the HTTP response.

  \code{basicTextGatherer} is a generator function that returns a closure which is
  used to cumulate text provided in callbacks from the libcurl
  engine when it reads the response from an HTTP request.

  \code{debugGatherer} can be used with the \code{debugfunction}
  libcurl option in a call and the associated \code{update}
  function is called whenever libcurl has information
  about the header, data and general messages about the
  request.

  These functions return a list of functions.
  Each time one calls \code{basicTextGatherer} or
  \code{debugGatherer}, one gets a new, separate
  collection of functions.  However, each
  collection of functions (or instance) shares
  the variables across the functions and across calls.
  This allows them to store data persistently across
  the calls without using a global variable.
  In this way, we can have multiple instances of the collection
  of functions, with each instance updating its own local state
  and not interfering with those of the others.
  
  We use an S3 class named \code{RCurlCallbackFunction} to indicate
  that the collection of funcions can be used as a callback.
  The \code{update} function is the one that is actually used
  as the callback function in the CURL option.
  The \code{value} function can be invoked to get the current
  state that has been accumulated by the
  \code{update} function.  This is typically used
  when the request is complete.
  One can reuse the same collection of functions across
  different requests. The information will be cumulated.
  Sometimes it is convenient to reuse the object but
  reset the state to its original empty value, as it had
  been created afresh. The \code{reset} function in the collection
  permits this.

  \code{multiTextGatherer} is used when we are downloading multiple
  URIs concurrently in a single libcurl operation.  This merely
  uses the tools of \code{basicTextGatherer} applied to each of
  several URIs. See \code{\link{getURIAsynchronous}}.
}
\usage{
basicTextGatherer(txt = character(), max = NA, value = NULL)
multiTextGatherer(uris)
debugGatherer()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{txt}{an initial character vector to start things.
    We allow this to be specified so that one can initialize
    the content. 
  }
  \item{max}{if specified as an integer this controls  the total number
    of characters that will be read.  If more are read, the function
    tells libcurl to stop!}
  \item{uris}{for \code{multiTextGatherer}, this is either the number
    or the names of the uris being downloaded and for which we
    need a separate writer function.
  }
  \item{value}{if specified, a function that is called when retrieving
    the text usually after the completion of the request and the
    processing of the response. This function can be used to convert the
    result into a different format, e.g. parse an XML document,
    read values from table in the text.}
}
\details{
  This is called when the libcurl engine finds sufficient
  data on the stream from which it is reading the response.
  It cumulates these bytes and hands them to a C routine in
  this package which calls the actual gathering function (or a suitable
  replacement) returned as the \code{update} component from this function.
  
}
\value{
  Both the \code{basicTextGatherer} and \code{debugGatherer}
  functions return an object of class
  \code{RCurlCallbackFunction}.
  \code{basicTextGatherer} extends this with the class
  \code{RCurlTextHandler}
  and 
  \code{debugGatherer} extends this with the class
  \code{RCurlDebugHandler}.
  Each of these has the same basic structure,
  being a list of 3 functions.
  \item{update}{the function that is called with the text from the
    callback routine and which processes this text by accumulating it
    into a vector}
  \item{value}{a function that returns the text cumulated across the
    callbacks. This takes an argument \code{collapse} (and additional ones)
    that are handed to \code{\link[base]{paste}}.
    If the value of  \code{collapse} is given as \code{NULL},
    the vector of elements containing the different text for each
    callback is returned. This is convenient when debugging or if one
    knows something about the nature of the callbacks, e.g. the regular
    size that causes iit to identify records in a natural way.
  }
  \item{reset}{a function that resets the internal state to its
    original, empty value. This can be used to reuse the same object
    across requests but to avoid cumulating new input with the material from previous requests.}


  \code{multiTextGatherer} returns a list with an element corresponding
  to each URI. Each element is an object obtained by calling
  \code{basicTextGatherer}, i.e. a collection of 3 functions with
  shared state.
   
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}


\seealso{
  \code{\link{getURL}}
  \code{\link{dynCurlReader}}  
}
\examples{
  txt = getURL("http://www.omegahat.org/RCurl/index.html", write = basicTextGatherer())

  h = basicTextGatherer()
  txt = getURL("http://www.omegahat.org/RCurl/index.html", write = h$update)
    # Cumulate across pages.
  txt = getURL("http://www.omegahat.org/index.html", write = h$update)


  headers = basicTextGatherer()
  txt = getURL("http://www.omegahat.org/RCurl/index.html", header = TRUE, headerfunction = headers$update)

     # Now read the headers.
  headers$value()
  headers$reset()


    # Debugging callback
  d = debugGatherer()
  x = getURL("http://www.omegahat.org/RCurl/index.html", debugfunction = d$update, verbose = TRUE)
  names(d$value())
  d$value()[["headerIn"]]


  uris = c("http://www.omegahat.org/RCurl/index.html", "http://www.omegahat.org/RCurl/philosophy.html")
  g = multiTextGatherer(uris)
  txt = getURIAsynchronous(uris,  write = g)
  names(txt)
  nchar(txt)

   # Now don't use names for the gatherer elements.
  g = multiTextGatherer(length(uris))
  txt = getURIAsynchronous(uris,  write = g)
  names(txt)
  nchar(txt)

\dontrun{
Sys.setlocale(,"en_US.latin1")
Sys.setlocale(,"en_US.UTF-8")
uris = c("http://www.omegahat.org/RCurl/index.html", "http://www.omegahat.org/RCurl/philosophy.html")
g = multiTextGatherer(uris)
txt = getURIAsynchronous(uris,  write = g)
}
}
\keyword{IO}


