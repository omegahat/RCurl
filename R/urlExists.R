url.exists =
function(url, ..., .opts = list(...), curl = getCurlHandle(.opts = .opts),
         .header = FALSE)
{
  g = basicTextGatherer()
  ans = curlPerform(url = url, followlocation = TRUE, headerfunction = g$update,
                      nobody = TRUE, writefunction = g$update, curl = curl)
  header = parseHTTPHeader(g$value())

  if(.header)
    header
  else
    as.integer(as.integer(header["status"])/100) == 2
}
