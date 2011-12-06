httpGET =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, ..., curl = curl)
}

httpPOST =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, .opts = list(...), curl = curl, post = 1L)
}

PUT = httpPUT =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, ..., curl = curl, customrequest = "PUT")
}

DELETE = httpDELETE =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, customrequest = "DELETE", ..., curl = curl)
}

HEAD = httpHEAD =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, customrequest = "HEAD", ..., curl = curl)
}

httpOPTIONS =
function(url, ..., curl = getCurlHandle())
{
  getURLContent(url, customrequest = "OPTIONS", ..., curl = curl)
}


