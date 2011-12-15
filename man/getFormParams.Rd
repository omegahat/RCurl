\name{getFormParams}
\alias{getFormParams}
\title{Extract parameters from a form query string}
\description{
  This function facilitates getting the parameter names and values
  from a URL that is an parameterized HTML query.

  This is motivated by a function from Chris Davis and Delft University.
}
\usage{
getFormParams(query, isURL = grepl("^(http|\\\\?)", query))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{query}{the query string or full URL containing the query}
  \item{isURL}{a logical value. If \code{TRUE}, \code{query} is 
   the full URL and we need to extract the sub-string representing the
   parameters. If \code{isURL} is \code{FALSE}, then \code{query}
   is assumed to be just the string containing the parameters.
  }
}
\value{
  A named character vector
  giving the parameter values  The names are the parameter names.
}
\author{
Duncan Temple Lang
}

\examples{
if(url.exists("http://www.omegahat.org/foo/bob.R")) {

  getFormParams("http://www.omegahat.org/foo/bob.R?xyz=1&abc=verylong")

  getFormParams("xyz=1&abc=verylong")
  getFormParams("xyz=1&abc=&on=true")
  getFormParams("xyz=1&abc=")
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{programming}
\keyword{interface}

