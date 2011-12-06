library(RCurl)
u = "http://photos.prnewswire.com/prnh/20110713/NY34814-b"
system.time(getURL(u, followLocation = TRUE, .opts = list(timeout = 1, maxredirs = 4L)))

# Gets into recursion constantly trying to download the same URL
# because the server keeps giving us the same URL to follow.
#GET /medias/switch.do?prefix=/appnb&page=/getStoryRemapDetails.do&prnid=20110713%252fNY34814%252db&action=details HTTP/1.1
#GET /medias/switch.do?prefix=/appnb&page=/getStoryRemapDetails.do&prnid=20110713%252fNY34814%252db&action=details HTTP/1.1

getURL(u, followLocation = TRUE)
print("next line") # programme does not get this far
