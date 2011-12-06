\name{curlVersion}
\alias{curlVersion}
\title{Information describing the Curl library}
\description{
  This function queries the Curl library to provide information
  about its characteristics when it was compiled.
  This tells the user about its capabilities and can be used
  to determine strategies.
}
\usage{
curlVersion(id = 0)
}
\arguments{
  \item{id}{an integer value between 0 and 3 inclusive.
      The idea is that one specifies the identifier for the version of
      interest.
      In fact, all values seem to yield the same result.
     }
}
\value{
  A list
  \item{age}{integer giving the number of this libcurl, 0 is FIRST, 1 is
     SECOND, 2 is THIRD}
  \item{version}{the version identifier as a string, e.g. \code{"7.12.0"}}
  \item{version_num}{the value as an integer}
  \item{host}{the machine on which the libcurl was configured/built.}
  \item{features}{a named integer vector of bits indicating what
    features of libcurl were configured and built into this version.
    These are features such as
     ipv6, ssl, libz, largefile, ntlm (Microsoft "authorization").}
  \item{ssl_version}{the string identifying the SSL version.}
  \item{ssl_version_num}{the number identifying the SSL version}
  \item{libz_version}{the string identifying the version of libz.}
  \item{protocols}{a character vector of the supported HTTP protocols,
     e.g. http, https, ftp, ldap, gopher, telnet}
  \item{ares}{name of the asynchronous DNS (domain name service) lookup
    library. This is often simply the empty string indicating it is not there.
    }
  \item{ares_num}{the number for the ares library}
  \item{libidn}{the name of the IDN (internationalized domain names)
    library being used. This field only appears in version 3 of libcurl.
    If you are using version 2 (e.g. curl-7.11.2), this will be
    \code{NA}.
    An empty string indicates that the field is present, but has no value.
   }

  See the man page for \code{curl_version_info}
  for a description of these fields.
  \code{features} in R is a named integer vector
  detailing the different features.
}
\references{Curl homepage \url{http://curl.haxx.se}}
\author{Duncan Temple Lang <duncan@wald.ucdavis.edu>}

\seealso{
\code{curl_version_info} in the libcurl documentation.
}
\examples{
  curlVersion()
}
\keyword{IO}
\concept{reflectance}
