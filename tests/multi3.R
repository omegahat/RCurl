library(RCurl)
urls = sprintf("http://www.omegahat.org/RCurl/%s", c("index.html", "FAQ.html", "Changes.html"))

multiHandle <- getCurlMultiHandle()
content <- list()
for(i in seq(along.with = urls)) {
  curl <- getCurlHandle()
  print(curl)
  content[[i]] <- basicTextGatherer()
#  opts <- curlOptions()
  curlSetOpt(url = urls[i], writefunction = content[[i]]$update, curl = curl)
  multiHandle <- push(multiHandle, curl)
}

rm(curl)
gc()

request <- list(multiHandle = multiHandle, content = content)
complete(request$multiHandle)
body <- lapply(request$content, function(x) x$value())
curlInfo <- lapply(request$multiHandle@subhandles, function(x) getCurlInfo(x))


rm(request, multiHandle)
gc()
gc()



