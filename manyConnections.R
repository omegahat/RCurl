urls = sprintf("http://eeyore.ucdavis.edu/EmptyFiles/f%d", 1:10000)

library(RCurl)
curl = getCurlHandle()

N = 2000
u = "http://localhost/~duncan"
ans = lapply(1:N, function(i) { if(i %% 100 == 0) { cat(i, ""); gc()} ;getURLContent(u, curl = curl)})

ans = lapply(1:N, function(i) { if(i %% 100 == 0) { cat(i, ""); gc()} ;getURLContent(u)})


ans = lapply(1:N, function(i) { if(i %% 100 == 0) { cat(i, ""); gc()} ;getURL(u)})



