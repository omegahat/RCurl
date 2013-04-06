library(RCurl)
u = "http://requestb.in/ug0yteug"
input = CFILE("rDrop/README.md")


curlPerform(url = u, customrequest = "PUT", upload = TRUE, readdata = input@ref, infilesize = 100, verbose = TRUE)

curlPerform(url = u, customrequest = "PUT", upload = TRUE, readdata = input@ref, infilesize = 211, verbose = TRUE)
