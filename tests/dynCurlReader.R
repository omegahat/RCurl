library(RCurl)

fetchURL = getURLContent

u = "http://www.dice.com/job/result/90668400/647068?src=19&q=Data Science"
rr = fetchURL(u, followlocation = TRUE)
cat(class(rr), length(rr), if(is.character(rr)) nchar(rr), attr(rr, "Content-Type"), "\n")

img = "http://www.dice.com/jobsearch/content/ejv_mercury/esurance/images/banner.jpg"
rr = fetchURL(img, followlocation = TRUE)
cat(class(rr), length(rr), if(is.character(rr)) nchar(rr), attr(rr, "Content-Type"), "\n")


cat("Fetching PDF\n")
pdf = "http://eeyore.ucdavis.edu/DTL_UCReview/cv13.pdf"
  # We shouldn't need to specify binary here, but for some reason
  # we are not seeing the second header from the redirect.
  # If we do
  # curlPerform(url = "http://eeyore.ucdavis.edu/DTL_UCReview/cv13.pdf", nobody = TRUE, followlocation = TRUE, verbose = TRUE)
  # we do see it.
  # However, we are getting an error either before this or never seeing it.
  # We have the Content-Type as text/html from the first 
  #
  # Should we ignore the content-type in the 302 header? Implemented now.
  #
rr = fetchURL(pdf, followlocation = TRUE)
cat(class(rr), length(rr), if(is.character(rr)) nchar(rr), attr(rr, "Content-Type"), "\n")

cat("Fetching PDF as binary\n")
rr = fetchURL(pdf, binary = TRUE, followlocation = TRUE)
cat(class(rr), length(rr), if(is.character(rr)) nchar(rr), attr(rr, "Content-Type"), "\n")


rr = fetchURL('http://www.omegahat.org/RCurl/index.html')
cat(class(rr), length(rr), if(is.character(rr)) nchar(rr), attr(rr, "Content-Type"), "\n")


curl = getCurlHandle()
hh = dynCurlReader(curl, header = TRUE, max = 500)
rr = fetchURL(pdf, header = hh, curl = curl, binary = TRUE, followlocation = TRUE)
print(names(rr))
print(rr$header)


curl = getCurlHandle()
hh = dynCurlReader(curl, header = TRUE, max = 500)
try(fetchURL('http://www.omegahat.org/RCurl/index.html', header = hh, curl = curl, binary = TRUE, followlocation = TRUE))
rr = hh$getResult()
print(nchar(rr$body))
stopifnot(as.integer(rr$header["Content-Length"]) > nchar(rr$body))
