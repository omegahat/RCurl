library(RCurl)
urls = sprintf("http://www.omegahat.org/RCurl/%s", c("index.html", "FAQ.html", "Changes.html"))
a = getURLAsynchronous(urls) # , .opts = list(verbose = TRUE))


mh = getCurlMultiHandle()
a = getURLAsynchronous(urls, multiHandle = mh) # , .opts = list(verbose = TRUE))

