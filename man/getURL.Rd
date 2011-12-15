\name{getURL}
\alias{getURL}
\alias{getURI}
\alias{getURLContent}
\title{Download a URI}
\description{
  These functions download one or more URIs (a.k.a. URLs).
  It uses libcurl under the hood to perform the request
  and retrieve the response.
  There are a myriad of options that can be specified using
  the \dots mechanism to control the creation and submission
  of the request and the processing of the response.
  
  \code{getURLContent} has been added as a high-level function
  like \code{getURL} and \code{getBinaryURL} but which 
  determines the type of the content being downloaded
  by looking at the resulting HTTP header's Content-Type
  field. It uses this to determine whether the bytes
  are binary or "text".

  The request supports any of the facilities within the
  version of libcurl that was installed.
  One can examine these via \code{\link{curlVersion}}.

  \code{getURLContent} doesn't perform asynchronous or multiple
  concurrent requests at present.
}
\usage{
getURL(url, ..., .opts = list(), write = basicTextGatherer(),
         curl = getCurlHandle(), async = length(url) > 1, .encoding = integer())
getURI(url, ..., .opts = list(), write = basicTextGatherer(),
         curl = getCurlHandle(), async = length(url) > 1, .encoding = integer())
getURLContent(url, ..., curl = getCurlHandle(.opts = .opts), .encoding = NA,
               binary = NA, .opts = list(...),
               header = dynCurlReader(curl, binary = binary,
                                        baseURL = url, isHTTP = isHTTP,
                                         encoding = .encoding),
               isHTTP = length(grep('^[[:space:]]*http', url)) > 0)
}
\arguments{
  \item{url}{a string giving the URI}
  \item{\dots}{named values that are interpreted as CURL options
    governing the HTTP request.}
  \item{.opts}{a named list or \code{CURLOptions} object identifying the
    curl options for the handle. This is merged with the values of \dots
    to create the actual options for the curl handle in the request.}  
  \item{write}{if explicitly supplied, this is a function that is called
    with a single argument each time the the HTTP response handler has
    gathered sufficient text. The argument to the function is
    a single string.  The default argument provides
    both a  function for cumulating this text and is then used
    to retrieve it as the return value for this function.
  }
  \item{curl}{the previously initialized CURL context/handle which can
    be used for multiple requests.}
  \item{async}{a logical value that determines whether the download
    request should be done via asynchronous,concurrent downloading or a serial
    download. This really only arises when we are trying to download
    multiple URIs in a single call. There are trade-offs between
    concurrent and serial downloads, essentially trading CPU cycles
    for shorter elapsed times. Concurrent downloads reduce the overall
    time waiting for \code{getURI}/\code{getURL} to return.
  }
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
    The default value leaves the decision  to this default mechanism.
    This does however currently involve processing each line/chunk
    of the header (with a call to an R function). As a result,
    if one knows the encoding for the resulting response,
    specifying this avoids this slight overhead which is probably
    quite small relative to network latency and speed.
  }
  \item{binary}{a logical value indicating whether the caller  knows
    whether the resulting content is binary (\code{TRUE}) or not
    (\code{FALSE}) or unknown (\code{NA}).
  }
  \item{header}{this is made available as a parameter of the function
    to allow callers to construct different readers for processing
    the header and body of the (HTTP) response.
    Callers specifying this will typically only adjust the
    call to \code{dynCurlReader}, e.g. to specify a
    function for its \code{value} parameter to
    control how the body is post-processed.
  }
  \item{isHTTP}{a logical value that indicates whether the request an
  HTTP request. This is used when determining how to process the response.}
}
\details{

}
\value{
  If no value is supplied for \code{write},
  the result is the text that is the HTTP response.
  (HTTP header information is included if the header option for CURL is
  set to \code{TRUE} and no handler for headerfunction is supplied in
  the CURL options.)

  Alternatively, if a value is supplied for the \code{write} parameter,
  this is returned. This allows the caller to create a handler within
  the call and get it back. This avoids having to explicitly create
  and assign it and then call \code{getURL} and then access the result.
  Instead, the 3 steps can be inlined in a single call.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}


\seealso{
  \code{\link{getBinaryURL}}
  \code{\link{curlPerform}}
  \code{\link{curlOptions}}
}
\examples{

  omegahatExists = url.exists("http://www.omegahat.org")

   # Regular HTTP
  if(omegahatExists) {
     txt = getURL("http://www.omegahat.org/RCurl/")
        # Then we could parse the result.
     if(require(XML))
         htmlTreeParse(txt, asText = TRUE)
  }


        # HTTPS. First check to see that we have support compiled into
        # libcurl for ssl.
  if("ssl" \%in\% names(curlVersion()$features)
         && url.exists("https://sourceforge.net/")) {
     txt = tryCatch(getURL("https://sourceforge.net/"),
                    error = function(e) {
                                  getURL("https://sourceforge.net/",
                                            ssl.verifypeer = FALSE)
                              })

  }


     # Create a CURL handle that we will reuse.
  if(omegahatExists) {
     curl = getCurlHandle()
     pages = list()
     for(u in c("http://www.omegahat.org/RCurl/index.html",
                "http://www.omegahat.org/RGtk/index.html")) {
         pages[[u]] = getURL(u, curl = curl)
     }
  }


    # Set additional fields in the header of the HTTP request.
    # verbose option allows us to see that they were included.
  if(omegahatExists)
     getURL("http://www.omegahat.org", httpheader=c(Accept = "text/html", MyField="Duncan"), verbose = TRUE)



    # Arrange to read the header of the response from the HTTP server as
    # a separate "stream". Then we can break it into name-value
    # pairs. (The first line is the HTTP/1.1 200 Ok or 301 Moved Permanently
    # status line)
  if(omegahatExists) {
     h = basicTextGatherer()
     txt = getURL("http://www.omegahat.org/RCurl/index.html", header= TRUE, headerfunction = h$update, 
                   httpheader = c(Accept="text/html", Test=1), verbose = TRUE) 
     print(paste(h$value(NULL)[-1], collapse=""))
     read.dcf(textConnection(paste(h$value(NULL)[-1], collapse="")))
  }



   # Test the passwords.
  if(omegahatExists) {
     x = getURL("http://www.omegahat.org/RCurl/testPassword/index.html",  userpwd = "bob:duncantl")

       # Catch an error because no authorization
       # We catch the generic HTTPError, but we could catch the more specific "Unauthorized" error
       # type.
      x = tryCatch(getURLContent("http://www.omegahat.org/RCurl/testPassword/index.html"),
                    HTTPError = function(e) {
                                   cat("HTTP error: ", e$message, "\n")
                                })
  }

\dontrun{
  #  Needs specific information from the cookie file on a per user basis
  #  with a registration to the NY times.
  x = getURL("http://www.nytimes.com",
                 header = TRUE, verbose = TRUE,
                 cookiefile = "/home/duncan/Rcookies",
                 netrc = TRUE,
                 maxredirs = as.integer(20),
                 netrc.file = "/home2/duncan/.netrc1",
                 followlocation = TRUE)
}

   if(omegahatExists) {
       d = debugGatherer()
       x = getURL("http://www.omegahat.org", debugfunction = d$update, verbose = TRUE)
       d$value()
   }

    #############################################
    #  Using an option set in R

   if(omegahatExists) {
      opts = curlOptions(header = TRUE, userpwd = "bob:duncantl", netrc = TRUE)
      getURL("http://www.omegahat.org/RCurl/testPassword/index.html", verbose = TRUE, .opts = opts)

         # Using options in the CURL handle.
      h = getCurlHandle(header = TRUE, userpwd = "bob:duncantl", netrc = TRUE)
      getURL("http://www.omegahat.org/RCurl/testPassword/index.html", verbose = TRUE, curl = h)
   }



   # Use a C routine as the reader. Currently gives a warning.
  if(omegahatExists) {
     routine = getNativeSymbolInfo("R_internalWriteTest", PACKAGE = "RCurl")$address
     getURL("http://www.omegahat.org/RCurl/index.html", writefunction = routine)
  }



  # Example
  if(omegahatExists) {
     uris = c("http://www.omegahat.org/RCurl/index.html", "http://www.omegahat.org/RCurl/philosophy.xml")
     txt = getURI(uris)
     names(txt)
     nchar(txt)

     txt = getURI(uris, async = FALSE)
     names(txt)
     nchar(txt)


     routine = getNativeSymbolInfo("R_internalWriteTest", PACKAGE = "RCurl")$address
     txt = getURI(uris, write = routine, async = FALSE)
     names(txt)
     nchar(txt)


         # getURLContent() for text and binary
     x = getURLContent("http://www.omegahat.org/RCurl/index.html")
     class(x)

     x = getURLContent("http://www.omegahat.org/RCurl/data.gz")
     class(x)
     attr(x, "Content-Type")

     x = getURLContent("http://www.omegahat.org/Rcartogram/demo.jpg")
     class(x)
     attr(x, "Content-Type")


     curl = getCurlHandle()
     dd = getURLContent("http://www.omegahat.org/RJSONIO/RJSONIO.pdf",
                        curl = curl,
                        header = dynCurlReader(curl, binary = TRUE,
                                           value = function(x) {
                                                    print(attributes(x)) 
                                                    x}))
   }



  # FTP
  # Download the files within a directory.
if(url.exists('ftp://ftp.wcc.nrcs.usda.gov')) {

   url = 'ftp://ftp.wcc.nrcs.usda.gov/data/snow/snow_course/table/history/idaho/'
   filenames = getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)

      # Deal with newlines as \n or \r\n. (BDR)
      # Or alternatively, instruct libcurl to change \n's to \r\n's for us with crlf = TRUE
      # filenames = getURL(url, ftp.use.epsv = FALSE, ftplistonly = TRUE, crlf = TRUE)
   filenames = paste(url, strsplit(filenames, "\r*\n")[[1]], sep = "")
   con = getCurlHandle( ftp.use.epsv = FALSE)

      # there is a slight possibility that some of the files that are
      # returned in the directory listing and in filenames will disappear
      # when we go back to get them. So we use a try() in the call getURL.
   contents = sapply(filenames[1:5], function(x) try(getURL(x, curl = con)))
   names(contents) = filenames[1:length(contents)]
}
   
}
\keyword{IO}
\concept{Web}
\concept{HTTP}
