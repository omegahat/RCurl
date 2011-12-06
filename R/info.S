getCurlInfo =
function(curl, which = getCurlInfoConstants())
{
  rnames = character()

  if(is.character(which)) {
    const = getCurlInfoConstants()          
    i = pmatch(tolower(which), names(const))
    if(any(is.na(i)))
      stop("Invalid curl info name", names(which)[is.na(i)])

    which = getCurlInfoConstants()[i]
  }
  
  x = .Call("R_curl_easy_getinfo", curl, as.integer(which), PACKAGE = "RCurl")

# put the names back on.  
  names(x) = names(which)
  
  x
}


getCurlInfoConstants =
function()
{
  x = .Call("R_getCURLInfoEnum", PACKAGE = "RCurl")
  names(x) = tolower(gsub("_", ".", names(x)))

  x
}

