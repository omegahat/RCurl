library(RCurl)
txt = paste(readLines("formUpload.R"), collapse = "\n")
z = postForm("http://www.cs.tut.fi/cgi-bin/run/~jkorpela/echo.cgi", datafile = txt, txt = "some text")


h = basicTextGatherer()
curlPerform(url = "http://www.cs.tut.fi/cgi-bin/run/~jkorpela/echo.cgi",
#            postfields = c(file = txt, output = "text"),
            postfields = c(datafile = txt, txt = "some text"),
            httpheader = c('Content-Type' = 'text/plain'),
            header = TRUE,
            verbose = TRUE, 
            writefunction = h$update)
            

