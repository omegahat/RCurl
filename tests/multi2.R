library(RCurl)
urls = sprintf("http://www.omegahat.org/RCurl/%s", c("index.html", "FAQ.html", "Changes.html"))

h1 = getCurlHandle(url = urls[1])
h2 = getCurlHandle(url = urls[2])

mh = getCurlMultiHandle()
push(mh, h1)
push(mh, h2)

curlMultiPerform(mh)
gc()
rm(h1, h2)
gc()
rm(mh)
gc()

