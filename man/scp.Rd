\name{scp}
\Rdversion{1.1}
\alias{scp}
\title{Retrieve contents of a file from a remote host via SCP (Secure Copy)}
\description{
 This function allows us to retrieve the contents of a file from a
 remote host via SCP. This is done entirely within R, rather than
 a command line application and the contents of the file are never
 written to disc.  The function allows the 
}
\usage{
scp(host, path, keypasswd = NA, user = getUserName(), rsa = TRUE,
     key = sprintf(c("~/.ssh/id_\%s.pub", "~/.ssh/id_\%s"),
                   if (rsa) "rsa" else "dsa"),
     binary = NA, size = 5000, curl = getCurlHandle(), ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{host}{the name of the remote host or its IP address}
  \item{path}{the path of the file of interest on the remote host's file
  systems}
  \item{keypasswd}{a password for accessing the local SSH key. This is
    the passphrase for the key.}
  \item{user}{the name of the user on the remote machine}
  \item{rsa}{a logical value indicating whether to use the RSA or DSA key}
  \item{key}{the path giving the location of the SSH key. }
  \item{binary}{a logical value giving }
  \item{size}{an estimate of the size of the buffer needed to store the
    contents of the file. This is used to initialize the buffer and
    potentially avoid resizing it as needed.}
  \item{curl}{a curl handle (\code{\link{getCurlHandle}}) that is to be
    reused for this request and which potentially contains numerous
    options settings or an existing connection to the host.}
  \item{\dots}{additional parameters handed to \code{\link{curlPerform}}.}
}
\details{This uses libcurl's facilities for scp.
  Use \code{"scp" \%in\% curlVersion()$protocols} to
  see if SCP is supported.
}
\value{
 Either a raw or character vector giving the contents of the file.
}
\references{
 libcurl \url{http://curl.haxx.se}
}
\author{
Duncan Temple Lang
}


\seealso{
  \code{\link{curlPerform}}
  \code{\link{getCurlOptionsConstants}}
}
\examples{
\dontrun{
   x = scp("eeyore.ucdavis.edu", "/home/duncan/OmegaWeb/index.html",  "My.SCP.Passphrase", binary = FALSE)
   x = scp("eeyore.ucdavis.edu",  "/home/duncan/OmegaWeb/RCurl/xmlParse.bz2",  "My.SCP.Passphrase")
   library(Rcompression)
   o = bunzip2(x)
}
}
\keyword{IO}
\keyword{programming}
