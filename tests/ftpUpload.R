#INFILESIZE_LARGE option.

if(exists("FTPTestPassword")) {
up = RCurl:::uploadFunctionHandler("Some text to be uploaded into a file", TRUE)
curlPerform(url = "ftp://duncan@laptop17/ftp/zoe",
            upload = TRUE,
            userpwd = FTPTestPassword,
            readfunction = up
            )
}

if(exists("FTPTestPassword")) {
d = debugGatherer()
curlPerform(url = "ftp://laptop17/ftp/Election.rda",
            upload = TRUE,
            readfunction = uploadFunction("/Users/duncan/Election08Polls.rda"),
            userpwd = FTPTestPassword,
            verbose = TRUE, debugfunction = d$update,
            postquote = c("CWD subdir", "RNFR Election.rda", "RNTO ElectionPolls.rda")
            )
}

if(exists("FTPTestPassword")) {
curlPerform(url = "ftp://laptop17/ftp/temp/Election.rda",
            upload = TRUE,
            userpwd = FTPTestPassword,
            readfunction = uploadFunction("/Users/duncan/Election08Polls.rda"),
            prequote = c("mkdir /ftp/temp")
           )
}
