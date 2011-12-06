# Seems to be that we are losing the finalizer.
# If we set writefunction to R_internalWriteTest, and set no
# parameters. Things are okay
#
# The problem is in the dynCurlReader().
# Even if we change the update() function in dynCurlReader
# to just return, we still have this problem.
#
library(RCurl)
site <- "http://chr.tx0.org/arch/ml/r/cookie-20101114.cgi"
cookie_1= "cookie1"

# Should work!
h = getCurlHandle(cookiejar = "-", cookiefile = "")
a = postForm(site, par = "cookie1", curl = h, style = "POST")
rm(h); gc(); gc()


h = getCurlHandle(cookiejar = "-", cookiefile = "")
a = getURLContent(site, curl = h)
rm(h) ; gc()

# not okay. But it is if we just return from the update.
h = getCurlHandle(cookiejar = "-", cookiefile = "")
w = dynCurlReader(h)
a = getURLContent(site, curl = h, header = w) # writefunction = w$update)
rm(h, w) ; gc()

  # but if we let getURLContent() use the default value for header we don't get the freeing
h = getCurlHandle(cookiejar = "-", cookiefile = "")
a = getURLContent(site, curl = h)
rm(h) ; gc()


# Fine
h = getCurlHandle(cookiejar = "-", cookiefile = "")
w = dynCurlReader(h)
a = getURL(site, curl = h, write = w$update)
rm(h, w) ; gc()


# This works, but the getURLContent() doesn't.
h = getCurlHandle(cookiejar = "-", cookiefile = "")
a = getURL(site, curl = h)
rm(h) ; gc()

h = getCurlHandle(cookiejar = "/tmp/mycookies", cookiefile = "")
a = postForm(site, par = "cookie1", curl = h, style = "POST")
rm(h); gc(); gc()

# HTTPPOST style
h = getCurlHandle(cookiejar = "/tmp/mycookies", cookiefile = "")
a = postForm(site, par = "cookie1", curl = h)
rm(h); gc(); gc()

h = getCurlHandle(cookiejar = "/tmp/mycookies", cookiefile = "")
curlPerform(url = site, postfields = "", curl = curl)

# Change the write function to a C routine and send no parameters
h = getCurlHandle(cookiejar = "/tmp/mycookies", cookiefile = "")
a = postForm(site, curl = h, style = "POST",  .opts = list(writefunction = getNativeSymbolInfo("R_internalWriteTest")$address))
rm(h); gc(); gc()

# Adding the parameter still works. So it is the writefunction.
h = getCurlHandle(cookiejar = "/tmp/mycookies", cookiefile = "")
a = postForm(site, curl = h, par = "cookie1", style = "POST",  .opts = list(writefunction = getNativeSymbolInfo("R_internalWriteTest")$address))
rm(h); gc(); gc()

# So let's try a regular write function. And that still works. So it is our default writefunction for postForm
w = basicTextGatherer()
h = getCurlHandle(cookiejar = "/tmp/mycookies1", cookiefile = "")
a = postForm(site, curl = h, par = "cookie1", style = "POST",  .opts = list(writefunction = w$update))
rm(h); gc(); gc()


h = getCurlHandle(cookiejar = "/tmp/mycookies1", cookiefile = "")
w = dynCurlReader(h, verbose = TRUE)
a = postForm(site, curl = h, par = "cookie1", style = "POST",  .opts = list(writefunction = w$update))
rm(h); gc(); gc()


files = sprintf("/tmp/k%d", 1:100)
sapply(files,
        function(f) {
	   h = getCurlHandle(cookiejar = f, cookiefile = "")
           w = dynCurlReader(h, verbose = TRUE)
           a = postForm(site, curl = h, par = "cookie1", style = "POST",  .opts = list(writefunction = w$update))
           rm(h); gc()
        })


h = getCurlHandle(cookiejar = "-", cookiefile = "")
w = dynCurlReader(h, verbose = TRUE)
a = postForm(site, curl = h, par = "cookie1", style = "POST",  .opts = list(writefunction = w$update))
rm(h); invisible(gc())





h = getCurlHandle(cookiejar = "/tmp/mycookies1", cookiefile = "")
a = getURL(site, curl = h)
rm(h)
gc(); gc()

