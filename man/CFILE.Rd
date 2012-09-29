\name{CFILE}
\Rdversion{1.1}
\alias{CFILE}
\alias{CFILE-class}
\alias{close,CFILE-method}
\title{Create a C-level handle for a file}
\description{
This function and class allow us to work with C-level
\code{FILE} handles.
The intent is to be able to pass these to \code{libcurl}
as options so that it can read or write from or to the file.
We can also do this with R connections and specify callback functions
that manipulate these connections. But using
the C-level FILE handle is likely to be significantly faster for large
files.

 The \code{close} method allows us to explicitly flush and close the file
 from within R.
}
\usage{
CFILE(filename, mode = "r")
}
\arguments{
  \item{filename}{the name of the file on disk}
  \item{mode}{a string specifying how to open the file, read or write, text or binary.}
}
\details{
This is a simple interface to the C routine \code{fopen}.
}
\value{
An object of class \code{CFILE} which is 
has a single slot name \code{ref} which is an external pointer
holding the address of the FILE object in C.
}
\references{
Man page for \code{fopen}
}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{curlPerform}} and the \code{readdata} 
}
\examples{
\dontrun{
filename = system.file("tests", "amazon3.R", package = "RCurl")
f = CFILE(filename)

if(url.exists('http://s3.amazonaws.com/'))
  curlPerform(url = "http://s3.amazonaws.com/RRupload/duncan2",
              upload = TRUE,
              readdata = f@ref,
              infilesize = file.info(filename)[1, "size"])
}
}
\keyword{IO}
