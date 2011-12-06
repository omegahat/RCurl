library(RCurl)

curl = getCurlHandle()
u = getURL("http://www.omegahat.org", curl = curl)
getCurlInfo(curl)


# From doc/examples in the curl distribution.

curl = getCurlHandle()
u = getURL("https://www.networking4all.com/", ssl.verifypeer = FALSE, certinfo = TRUE, curl = curl)
sapply(getCurlInfo(curl)$certinfo, paste, collapse = "\n")


curl = getCurlHandle()
u = getURL("https://svn.boost.org/", certinfo = TRUE, curl = curl, ssl.verifypeer = FALSE)
sapply(getCurlInfo(curl)$certinfo, paste, collapse = "\n")

