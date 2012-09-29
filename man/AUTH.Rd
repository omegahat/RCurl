\name{AUTH_ANY}
\alias{AUTH_ANY}
\alias{AUTH_ANYSAFE}
\alias{AUTH_BASIC}
\alias{AUTH_DIGEST}
\alias{AUTH_DIGEST_IE}
\alias{AUTH_GSSNEGOTIATE}
\alias{AUTH_NONE}
\alias{AUTH_NTLM}
\alias{AUTH_NTLM_WB}
\alias{AUTH_ONLY}
\title{Constants for identifying Authentication Schemes}
\description{
  These variables  are symbolic constants that allow
  use to specify different combinations of schemes
  for HTTP authentication in a request to a Web server.
  We can combine them via the \code{|} operator to
  indicate that libcurl should try them in order until one works.
}
\examples{
   AUTH_BASIC | AUTH_DIGEST
}
\keyword{programming}
