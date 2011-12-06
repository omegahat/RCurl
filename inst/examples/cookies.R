library(RCurl)

# This one expects the cookies to already exist in /tmp/cookies
getURL("http://www.nytimes.com",
       cookiefile = "/tmp/cookies",
       maxredirs = as.integer(20), followlocation = TRUE)


# will write the cookies to the file /tmp/myCookies when the
# curl handle is released.
x = getURL("http://www.nytimes.com", cookiejar= "/tmp/myCookies")
gc()


# Will write the cookies to the console (i.e. the equivalent of stdout)
h = getCurlHandle()
x = getURL("http://www.nytimes.com", cookiejar= "-", curl = h)

h = NULL
gc()


dbg = function(msg, type, curl)  { cat("<curl debug> ", msg, "\n")}
x = getURL("http://www.nytimes.com", cookiejar= "/usr/local/myCookies", debugfunction = dbg); gc()


h = getCurlHandle()
x = getURL("http://www.nytimes.com", cookiejar= "-", curl = h)
h = NULL
capture.output(gc())


# This doesn't work. Is dupCurlHandle() not copying the cookie.
h = getCurlHandle()
x = getURL("http://www.nytimes.com", cookiejar= "-", curl = h)
h2 = dupCurlHandle(h)
curlSetOpt(cookiejar = "/tmp/currentCookies", curl = h2)
rm(h2)
gc()



#
h = getCurlHandle()
x = getURL("http://www.nytimes.com", cookiejar= "-", curl = h)
# Not compiled at present
if(is.loaded("R_get_Cookies"))
  .Call("R_get_Cookies", h, "-")
