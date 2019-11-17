url.exists =
function(url, ..., .opts = list(...), curl = getCurlHandle(.opts = .opts),
         .header = FALSE)
{
  if(length(url) > 1)
          # Really want to do this with a multi curl so asynchronous.
     return(sapply(url, url.exists, curl = curl, .header = .header))
    
  g = basicTextGatherer()
  failed = FALSE
  ans = tryCatch(curlPerform(url = url, followlocation = TRUE, headerfunction = g$update,
                             nobody = TRUE, writefunction = g$update, curl = curl),
                  COULDNT_RESOLVE_HOST = function(x) failed <<- TRUE,
                  error = function(x) failed <<- TRUE)

  if(failed)
      return(FALSE)
                   
  if(grepl("^s?ftp", url)) {
    return(TRUE)
  } else
     header = parseHTTPHeader(g$value())

  if(.header)
    header
  else
    as.integer(as.integer(header["status"])/100) == 2
}
