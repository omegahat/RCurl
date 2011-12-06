\name{merge.list}
\alias{merge.list}
\title{Method for merging two lists by name}
\description{
  This is a method that merges the contents of one list
  with another by adding the named elements in the second
  that are not in the first.
  In other words, the first list is the target template,
  and the second one adds any extra elements that it has.
}
\usage{
merge.list(x, y, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{the list to which elements will be added}
  \item{y}{the list which will supply additional elements to \code{x}
    that are not already there by name. }
  \item{\dots}{not used.}
}
\value{
  A named list whose name set is the union of the elements
  in names of x and y and whose values are those taken
  from y and then with those in x, overwriting if necessary.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
\code{\link[base]{merge}}}
\examples{
\dontrun{
# Not exported.

 merge.list(list(a=1, b = "xyz", c = function(x, y) {x+y}),
             list(a = 2, z = "a string"))

  # No values in y
 merge.list(list(a=1, b = "xyz", c = function(x, y) {x+y}), list())

  # No values in x
 merge.list(list(), list(a=1, b = "xyz", c = function(x, y) {x+y}))
}
}
\keyword{manip}


