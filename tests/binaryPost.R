library(RCurl)
buf = as.raw(1:10000)

dataProvider =
function(buffer) {
     pos = 1
     function(numEls) {
if(pos >= length(buffer))
  return(character())
        tmp = buffer[seq(pos, min(length(buffer) - pos + 1, numEls))]
        pos <<- pos + numEls
        tmp
     }
}

myFun = dataProvider(buf)

curlPerform(url = "http://www.omegahat.org/cgi_bin/formBody.pl",
            post = TRUE,
            readfunction = myFun,
            postfieldsize = length(buf),
            httpheader = c('Content-Type' = "application/x-binary"),
            verbose = TRUE)

# or no postfieldsize
# and add
#    'Transfer-Encoding' = "chunked"
# to httpheader


################

curlPerform(url = "http://www.omegahat.org/cgi_bin/formBody.pl",
            post = TRUE,
            readfunction = buf,
            postfieldsize = length(buf),
            httpheader = c('Content-Type' = "application/x-binary"),
            verbose = TRUE)


