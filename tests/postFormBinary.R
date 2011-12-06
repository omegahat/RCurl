if(FALSE) {
library(RCurl)

x = postForm("http://www.razorvine.net/test/utf8form/utf8formaccepter.sn",
              .params = list(text = "%E2%82%AC%C3%AB%C2%A9%E2%99%A1", outputencoding = "UTF-8"),
                style = 'POST', .opts = list(verbose = TRUE))

header = dynCurlReader()
x = postForm("http://www.razorvine.net/test/utf8form/utf8formaccepter.sn",
              .params = list(text = "%E2%82%AC%C3%AB%C2%A9%E2%99%A1", outputencoding = "UTF-8"),
                style = 'POST', .opts = list(verbose = TRUE, writefunction = header$update), curl = header$curl())
}


