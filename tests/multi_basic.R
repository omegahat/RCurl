library(RCurl)

mh <- getCurlMultiHandle()
curl = getCurlHandle()
mh = push(mh, curl)
mh = pop(mh, curl)

mh = push(mh, curl, "bob")
mh = pop(mh, curl)

rm(curl)
gc()

mh@subhandles
rm(mh)
gc()



