library(RCurl)
if(FALSE) {
f = CFILE("tests/amazon3.R")
curlPerform(url = "http://s3.amazonaws.com/RRupload/fromRUpload",
              upload = TRUE,
              readdata = f@ref,
              verbose = TRUE,
              infilesize = file.info("tests/amazon3.R")[1, "size"])
}
#              customrequest = "PUT",
#              httpheader = c('Content-Length' = file.info("tests/amazon3.R")[1, "size"])
