library(RCurl)
urls = sprintf("http://www.omegahat.org/RCurl/%s", c("index.html", "FAQ.html", "Changes.html"))

multiHandle <- getCurlMultiHandle()
content <- list()
for(i in seq(along.with = urls)) {
  curl <- getCurlHandle()
  print(curl@ref)
  content[[i]] <- basicTextGatherer()
#  opts <- curlOptions()
  curlSetOpt(url = urls[i], writefunction = content[[i]]$update, curl = curl)
  multiHandle <- push(multiHandle, curl, as.character(i))
#  pop(multiHandle, as.character(i))
}

rm(multiHandle)
gc()
gc()
rm(curl)
gc()

