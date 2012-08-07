
curlVersion <-
function(id = 0)
{
  x = .Call("R_curl_version_info", as.integer(id), PACKAGE = "RCurl")

   # Now break up the features.
  x$features = getBitIndicators(x$features, CurlFeatureBits)
  
  x
}  


CurlFeatureBits = as.integer(2^(0:15))
names(CurlFeatureBits) = c("ipv6", "kerberos4", "ssl", "libz", "ntlm", "gssnegotiate",
                           "debug", "asynchdns", "spnego", "largefile", "idn", "sspi",
                           "conv", "curldebug", "tlsauth_srp", "ntlm_wb")
class(CurlFeatureBits) = c("CurlFeatureBits", "BitIndicator")



CurlGlobalBits = as.integer(c(0, 1, 2, 3))
names(CurlGlobalBits) = c("none", "ssl", "win32", "all")
class(CurlGlobalBits) = c("CurlGlobalBits", "BitIndicator")


setBitIndicators =
  #
  # if the caller gives an integer, sum them
  # if the give a vector of strings, resolve them relative to the
  # names in defs and then sum those.
  #
  #
  # If we hand this a value that is a composition of flags,
  # we don't do the right thing.
  #
function(vals, defs)
{
  if(is.character(vals)) {
    i = match(vals, names(defs))
    if(any(is.na(i)))
      stop("Unmatched bit field names ", paste(vals[is.na(i)], collapse=", "))

     vals = defs[i]
  }

  as.integer(sum(vals))
}



getBitIndicators =
function(val, defs)
{
  n = length(defs)
  ans = .C("R_check_bits", as.integer(val), as.integer(defs), ans = logical(n), n, PACKAGE = "RCurl")$ans

  defs[ans]
}  
