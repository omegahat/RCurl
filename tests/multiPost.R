# This illustrates how to simultaneously make multiple POST requests
# for HTTPPOST forms, i.e., in parallel rather than sequentially.
#
# This is similar to getURLAsynchronous(), but it handles POSTing a form
# where the style is HTTPPOST.
#

library(RCurl)

url = "http://requestb.in/1fv3hc61"

# Fake arguments
args = list(list(a = "1", b = "xyz"),
            list(animal = "giraffe"),
            list(part1 = "2", part2 = "abc", part3 = "TRUE"))

# Fake URLs
urls = rep(url, length(args))

# Create a multi handle
multiH = getCurlMultiHandle()
# Create a handle for each inividual request
# giving it its own result gatherer, setting
# the form arguments with the new buildPostForm() fn.
gatherers = mapply(function(u, arg) {
                     h = getCurlHandle()
                     r = dynCurlReader(h, baseURL = u)
                     curlSetOpt(url = u, headerfunction = r$update, curl = h, verbose = TRUE)
                     RCurl:::buildPostForm(arg, h)
                     push(multiH, h)
                     r
                   }, urls, args, SIMPLIFY = FALSE)

complete(multiH)

ans = lapply(gatherers, function(x) x$value())


