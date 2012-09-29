\name{postForm}
\alias{postForm}
\alias{.postForm}
\alias{getForm}
\title{Submit an HTML form}
\description{
  These functions provide facilities for submitting an HTML
  form using either the simple GET mechanism (appending the name-value
  pairs of parameters in the URL) or the POST method which puts
  the name-value pairs as separate sections  in the body of the 
  HTTP request. The choice of action is defined by the form,
  not the caller.
}
\usage{
postForm(uri, ..., .params = list(), .opts = curlOptions(url = uri),
         curl = getCurlHandle(), style = 'HTTPPOST',
          .encoding = integer(), binary = NA, .checkParams = TRUE,
          .contentEncodeFun = curlEscape)
.postForm(curl, .opts, .params, style = 'HTTPPOST')
getForm(uri, ..., .params = character(), .opts = list(), curl = getCurlHandle(),
         .encoding = integer(), binary = NA, .checkParams = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{uri}{the full URI to which the form is to be posted. This
    includes the host and the specific file or script which will process
    the form.}
  \item{\dots}{the name-value pairs of parameters.
    Note that these are not the CURL options.}
  \item{.params}{instead of specifying the name-value parameters in
    "free" form via the \dots argument, one can specify them
     as named list or character vector.
  }
  \item{.opts}{an object representing the CURL options for this call.}
  \item{curl}{the \code{CURLHandle} object created earlier if one is
    reusing these objects. Otherwise, a new one is generated and
    discarded.}
  \item{style}{this is typically a string
    and controls how the form data is posted, specifically
    the value for the Content-Type header and the particular
    representation.
    Use 'httppost' to use a \code{multipart/form-data}
    transmission
    and use 'post' for \code{application/x-www-form-urlencoded}
    content.
    This string is compared to the names
    of (the internal) \code{PostStyles} vector using partial
    matching.  In the future, we will use
    enum values within R.
    The default is \code{multipart/form-data} for reasons of backward compatability.
  }
  \item{.encoding}{the encoding of the result, if it is known a priori.
    This can be an integer between 0 and 4 or more appropriately a
    string identifying the encoding as one of  "utf-8",
    or "ISO-859-1".}
  \item{binary}{a logical value indicating whether the caller  knows
    whether the resulting content is binary (\code{TRUE}) or not
    (\code{FALSE}) or unknown (\code{NA}).
    }  
  \item{.checkParams}{a logical value that indicates whether we should perform a check/test
   to identify if any of the arguments passed to the form correspond to Curl options.
   This is useful to identify potential errors in specifying the Curl options in the
   wrong place (in the way we would for \code{\link{curlPerform}}).
   This check can lead to spurious warning messages if the form has parameters
   with names that do conflict with Curl options. 
   By specifying \code{FALSE} for this parameter, you can avoid this test
   and hence any warnings. But make certain you know what you are doing.
 }
  \item{.contentEncodeFun}{a function which encodes strings in a
    suitable manner.  For x-www-form-encoded submissions, this should 
    most likely should be \code{curlPercentEncode} which maps spaces to
  +, = to \%3D, etc.
    We are leaving the default as \code{curlEscape} for now until we test whether applications
    continue to work with the correct encoding.}
}
\details{
  Creating a new \code{CURLHandle} allows the C-level code
  to more efficiently map the R-level values to their
  C equivalents needed to make the call. However, reusing
  the handle across calls can be more efficient in that
  the connection to a server can be maintained and thus,
  the sometimes expensive task of establishing it is
  avoided in subsequent calls.
}
\value{
  By default, the text from the HTTP response is
  returned.  
}


\seealso{
  \code{\link{getURL}}
  \code{\link{curlOptions}}
  \code{\link{curlSetOpt}}
}
\examples{

if(url.exists("http://www.google.com")) {
   # Two ways to submit a query to google. Searching for RCurl
  getURL("http://www.google.com/search?hl=en&lr=&ie=ISO-8859-1&q=RCurl&btnG=Search")

   # Here we let getForm do the hard work of combining the names and values.
  getForm("http://www.google.com/search", hl="en", lr="", ie="ISO-8859-1",  q="RCurl", btnG="Search")

   # And here if we already have the parameters as a list/vector.
  getForm("http://www.google.com/search", .params = c(hl="en", lr="", ie="ISO-8859-1",  q="RCurl", btnG="Search"))
}


   # Now looking at POST method for forms.
if(url.exists("http://wwwx.cs.unc.edu/~jbs/aw-wwwp/docs/resources/perl/perl-cgi/programs/cgi_stdin.cgi")) 
 postForm("http://wwwx.cs.unc.edu/~jbs/aw-wwwp/docs/resources/perl/perl-cgi/programs/cgi_stdin.cgi",
           name = "Bob", "checkedbox" = "spinich",
           submitButton = "Now!",
           textarea = "Some text to send",
           selectitem = "The item",
           radiobutton = "a", style = "POST")


  # Genetic database via the Web.
if(url.exists('http://www.wormbase.org/db/searches/advanced/dumper')) {
 x = postForm('http://www.wormbase.org/db/searches/advanced/dumper',
         species="briggsae",
         list="",
         flank3="0",
         flank5="0",
         feature="Gene Models",
         dump = "Plain TEXT",
         orientation = "Relative to feature",
         relative = "Chromsome",
         DNA ="flanking sequences only",
         .cgifields = paste(c("feature", "orientation", "DNA", "dump","relative"), collapse=", "))


 # Note that we don't have to paste multiple values together ourselves,
 # e.g. the .cgifields can be specified as a character vector rather
 # than a string.
 x = postForm('http://www.wormbase.org/db/searches/advanced/dumper',
         species="briggsae",
         list="",
         flank3="0",
         flank5="0",
         feature="Gene Models",
         dump = "Plain TEXT",
         orientation = "Relative to feature",
         relative = "Chromsome",
         DNA ="flanking sequences only",
         .cgifields =c("feature", "orientation", "DNA", "dump", "relative"))
}
	  
}
\keyword{IO}


