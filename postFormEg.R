require(RCurl)
url <- "http://phylodiversity.net/phylomatic/pm/phylomatic.cgi"
string1 <- "asteraceae%2Fhelianthus%2Fhelianthus_annuus%0D%0Afagaceae%2Fquercus%2Fquercus_douglasii%0D%0Apinaceae%2Fpinus%2Fpinus_contorta"
string2 <- "annonaceae%2Fannona%2Fannona_cherimola%0D%0Aannonaceae%2Fannona%2Fannona_muricata"

 # THe following are all the same.
a = postForm(url, format = 'new', tree = string1, .opts = list(verbose = TRUE))
b = postForm(url, format = 'new', tree = string2, .opts = list(verbose = TRUE))
c = postForm(url, garbage = "")

a = postForm(url, format = 'new', tree = curlUnescape(string1))
b = postForm(url, format = 'new', tree = curlUnescape(string2))

urlplus <- paste(url, "?", "format=", "new", "&tree=", string1, sep="")
tt <- getURLContent(urlplus, curl=getCurlHandle())
tt[[1]]

urlplus <- paste(url, "?", "format=", "new", "&tree=", string2, sep="")
tt <- getURLContent(urlplus, curl=getCurlHandle())
tt[[1]]
