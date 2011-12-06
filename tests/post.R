library(RCurl)
h = basicHeaderGatherer()
postForm("http://www.omegahat.org/wewanttoget/a404status",
         .opts=curlOptions(headerfunction = h$update, writefunction = h$update, verbose=TRUE),
         foo="bar")
stopifnot(h$value()[["status"]] == "404")


h = basicHeaderGatherer()
b = basicHeaderGatherer()
postForm("http://www.omegahat.org/wewanttoget/a404status",
         .opts=curlOptions(headerfunction = h$update, writefunction = b$update, verbose=TRUE),
         foo="bar")
stopifnot(h$value()[["status"]] == "404")




curl = getCurlHandle()
h = dynCurlReader(curl)
postForm("http://www.omegahat.org/wewanttoget/a404status",
         .opts=curlOptions(headerfunction = h$update, verbose=TRUE),
         foo="bar")
stopifnot(parseHTTPHeader(h$header())[["status"]] == "404")
