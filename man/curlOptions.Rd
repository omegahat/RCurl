\name{curlOptions}
\alias{curlOptions}
\alias{getCurlOptionsConstants}
\alias{getCurlOptionTypes}
\alias{listCurlOptions}
\alias{mapCurlOptNames}
\alias{[<-.CURLOptions}
\alias{[[<-.CURLOptions}
\title{Constructor and accessors for CURLOptions objects}
\description{
  These functions provide a constructor
  and accessor methods 
  for the (currently S3) class \code{CURLOptions}.
  This class is a way to group and manage options settings
  for CURL.
  These functions manage a named list of options
  where the names are elements of a fixed.
  Not all elements need be set, but
  these functions take care of expanding names
  to match the fixed set, while allowing callers
  to use abbreviated/partial names.
  Names that do not match (via \code{\link[base]{pmatch}})
  will cause an error.

  The set of possible names is given by
  \code{names(getCurlOptionsConstants())}
   or more directly with \code{listCurlOptions()}.

  \code{mapCurlOptNames} handles the partial matching and
  expansion of the names of the options for all the functions
  that handle CURL options.
  Currently this uses \code{\link[base]{pmatch}} to
  perform the matching and so rejects words
  that are ambiguous, i.e. have multiple matches
  within the set of permissible option names.
  As a result, "head" will match both
  "header" and "headerfunction".
  We may change this behavior in the future, but
  we encourage using the full names for readability of code if nothing
  else.
  

}
\usage{
curlOptions(..., .opts = list())
getCurlOptionsConstants()
\method{[}{CURLOptions}(x, i) <- value
\method{[[}{CURLOptions}(x, i) <- value
listCurlOptions()
getCurlOptionTypes(opts = getCurlOptionsConstants())
}
%"[<-.CURLOptions"(x, i, value)
\arguments{
  \item{\dots}{name-value pairs identifying the settings for the options
  of interest.}
  \item{.opts}{a named list of options, typically a previously created
    \code{CURLOptions} object. These are merged with the options
    specified in \code{\dots}.}
  \item{x}{a \code{CURLOptions} object}
  \item{i}{the name(s) of the option elements being accessed.
    These can be partial names matching elements in the set
   of known options. Other names will cause an error.}
  \item{value}{the values to assign to the options identified via \code{i}.}
  \item{opts}{the options whose type description are of interest in the call.}
}
\details{
  These functions use \code{mapCurlOptNames}
  to match and hence expand the names the callers
  provide.
}
\value{
  \code{curlOptions} returns an object
  of class \code{CURLOptions} which is simply
  a named list.

  \code{getCurlConstants} returns a named vector identifying
  the names of the possible options and their associated
  values. These values are used in the C code and also each integer
  encodes the type of the argument expected by the C code
  for that option.

  \code{getCurlOptionTypes} returns human-readable,
  heuristic descriptions of the types expected for the different options.
  These are integer/logical  corresponding to "long" in the RCurl documentation;
  string/object pointer corresponding to "char *" or ;
  function corresponding to a function/routine pointer;
  large number corresponding to a \code{curl_off_t}.
}

\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

 \seealso{
   \code{\link{curlPerform}}
   \code{\link{curlSetOpt}}
 }
\examples{

 tt = basicTextGatherer()
 myOpts = curlOptions(verbose = TRUE, header = TRUE, writefunc = tt[[1]])

  # note that the names are expanded, e.g. writefunc is now writefunction.
 names(myOpts)

 myOpts[["header"]]

 myOpts[["header"]] <- FALSE

# Using the abbreviation "hea" is an error as it matches
# both 
#  myOpts[["hea"]] <- FALSE

 # Remove the option from the list
 myOpts[["header"]] <- NULL
}
\keyword{IO}

