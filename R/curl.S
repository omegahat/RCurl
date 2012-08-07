
curlGlobalInit =
function(flags = c("ssl", "win32")) # This is the same as all.
{
  status = .Call("R_curl_global_init", setBitIndicators(flags, CurlGlobalBits), PACKAGE = "RCurl")

  asCurlErrorCode(status)
}

curlGlobalCleanup =
function()
{
.Call("R_curl_global_cleanup", PACKAGE = "RCurl")
}  

asCurlErrorCode =
function(val)
{
  defs =.Call("R_getCURLErrorEnum", PACKAGE = "RCurl")
  defs[defs == val]
}


debugGatherer =
function()
{
  els = NULL
  info = NULL
  
  update = function(msg, type, curl)  {
    els[[type + 1]] <<- c(els[[type + 1]], msg)
    info[[length(info) + 1]] <<- msg
    names(info)[length(info)] <<- names(type)
    0
  }

  reset = function() { els <<-
                         list(text=character(),
                              headerIn = character(),
                              headerOut = character(),
                              dataIn = character(),
                              dataOut = character(),
                              sslDataIn = character(),
                              sslDataOut = character())

                       info <<- list()
                     }

  ans = list(update = update,
             value = function(collapse = "", ordered = FALSE, ...) {
                         if(ordered)
                           return(info)
                         
                         if(is.null(collapse))
                           return(els)
                                 
                         sapply(els, function(x) paste(x, collapse = collapse, ...))
                       },
             reset = reset)


  class(ans) <- c("RCurlDebugHandler", "RCurlCallbackFunction")

  ans$reset()
  
  ans
}

  


basicTextGatherer =
  #
  # This is a function that is used to create a closure (i.e. a function with its own local variables
  # whose values persist across invocations).  This is called to provide an instance of a function that is
  # called when the libcurl engine has some text to be processed as it is reading the HTTP response from the
  # server.
  # The function that reads the text can do whatever it wants with it. This one simply
  # cumulates it and makes it available via a second function. 
  #
function(txt = character(), max = NA, value = NULL, .mapUnicode = TRUE)
{
  update = function(str) {
    txt <<- c(txt, str)
    if(!is.na(max) && nchar(txt) >= max)
      return(0)
    
    nchar(str, "bytes") # use bytes rather than chars as for UTF-8, etc. we may have fewer characters,
                        # but the C code for libcurl works in bytes. If we report chars and < bytes,
                        # libcurl terminates the download.
  }

  reset = function() {  txt <<- character() }

  val = if(missing(value))
            function(collapse = "", ...) {
                         if(!is.null(collapse))
   	                    txt = paste(txt, collapse = collapse)
                         if(.mapUnicode)
                            txt = mapUnicodeEscapes(txt)
                         return(txt)
            }
        else
          function(collapse = "") {
	     if(!is.null(collapse))
                txt = paste(txt, collapse = collapse)
	     if(.mapUnicode)
               txt = mapUnicodeEscapes(txt)
             value(txt)
          }
  

  ans = list(update = update,
             value = val,
             reset = reset)

  class(ans) <- c("RCurlTextHandler", "RCurlCallbackFunction")
  
  ans$reset()
  
  ans
}

basicHeaderGatherer =
function(txt = character(), max = NA)  
  basicTextGatherer(txt, max, parseHTTPHeader)



getURL = getURI = 
  #
  # initializes a curl handle, populates its settingsc
  #
function(url, ..., .opts = list(), write = basicTextGatherer(.mapUnicode = .mapUnicode), curl = getCurlHandle(),
          async = length(url) > 1, .encoding = integer(), .mapUnicode = TRUE)
{
#    write = getNativeSymbolInfo("R_curl_write_data", PACKAGE = "RCurl")$address

  url = as.character(url)
  
  if(async) {
     if(missing(write))
        write = multiTextGatherer(url)
     return(getURIAsynchronous(url, ..., .opts = .opts, write = write, curl = curl))
  }

  if(length(url) > 1) {
      # typically will go to async. But if async is explicitly set to FALSE
      # then the caller wants to use a serialized sequence of requests and collect
      # the results into a single string if write is specified and as a character vector
      # of strings otherwise.
    
       # If write wasn't specified, then
     dupWriter = FALSE
     if(missing(write))
       dupWriter = TRUE
     return(sapply(url, function(u) {
                           if(dupWriter)
                               write = basicTextGatherer()
                            getURI(u, ..., .opts = .opts, write = write, curl = curl, async = FALSE, .encoding = .encoding)
                         }))
  }
  
  returnWriter = FALSE
  if(missing(write) || inherits(write, "RCurlCallbackFunction")) {
      writeFun = write$update
  } else {
      writeFun = write
      returnWriter = TRUE
  }

    # Don't set them, just compute them.
  opts = curlOptions(URL = url, writefunction = writeFun, ..., .opts = .opts)

  status = curlPerform(curl = curl, .opts = opts, .encoding = .encoding)

  if(returnWriter)
    return(write)
  
  write$value()
}

curlPerform =
function(..., .opts = list(), curl = getCurlHandle(), .encoding = integer())
{
  isProtected = missing(curl)

  .encoding = getEncodingValue(.encoding)
  
  .opts = curlSetOpt(..., .opts = .opts, curl = NULL, .encoding = .encoding)

    # The 3rd argument - TRUE - is just so that we don't need to create it in the
    # C code to pass to R_curl_easy_setopt.

  status = .Call("R_curl_easy_perform", curl, .opts,  isProtected, .encoding, PACKAGE = "RCurl")

  asCurlErrorCode(status)
}  

CE_NATIVE = 0L
CE_UTF8 = 1L
CE_LATIN1 = 2L
CE_SYMBOL = 5L

getEncodingValue =
function(val)
{
 if(length(val) == 0)
   return(val)

 if(is.character(val))
   switch(val, "UTF-8" =, "utf-8" = CE_UTF8, "ISO-8859-1" =, "iso-8859-1" = CE_LATIN1, CE_NATIVE)
 else
   as.integer(val)
}
  

curlSetOpt =
  #
  # This is used when setting the values globally.
  #
  # No sense in generating a default CURL handle and then throwing
  # it way.  It is only here to allow people to create it in a call
  # when they set the options.
  # This could go as most people will call this having already created
  # the CURL object.
function(..., .opts = list(), curl = getCurlHandle(), .encoding = integer(), .forceHeaderNames = FALSE,
         .isProtected = FALSE)
{
 .opts = curlOptions(..., .opts = .opts)

  if("httpheader" %in% names(.opts)) {
    tmp  = .opts[["httpheader"]]

      # paste the name and value together if
      # a) we have names, and b) not all entries have a : at the start.
      # We have to be careful here. We got caught with a date having a :
      # and there being only one element in the header.
      # Also tripped up if a header entry is http:... or ftp:...  since the : gets caught, but only
      # if there is one.
    if(length(names(tmp)) && (.forceHeaderNames || (length( grep("^[^[:space:]]+:", gsub("(ftp|http):", "", tmp))) != length(tmp))))
       .opts[["httpheader"]] = paste(names(tmp), tmp, sep = ": ")
  }

  .encoding = getEncodingValue(.encoding)
 
  if(length(.opts) || length(.encoding)) {
     optIds = mapCurlOptNames(names(.opts))

          # Check the types and do coercion if necessary
     idx = match(names(.opts), names(optionConverters))

     if(!all(is.na(idx)))  {
        i = names(.opts)[!is.na(idx)]
        .opts[i] =  lapply(i, function(x)  
                                  optionConverters[[x]](.opts[[x]]))
     }

     if(!is.null(curl)) {
       .isProtected = rep(.isProtected, length(.opts))
       status = .Call("R_curl_easy_setopt", curl, .opts, optIds, .isProtected, as.integer(.encoding), PACKAGE = "RCurl")
       return(curl)
     }
  } else
     optIds = integer()

 
  tmp = list(ids = optIds, values = .opts)
  class(tmp) <- "ResolvedCURLOptions"
  tmp
}

optionConverters =
list("netrc" = function(x) asEnum(x, CurlNetrc, "NetrcEnum")
    )


getCurlHandle =
function(..., .opts = NULL, .encoding = integer(),
           .defaults = getOption("RCurlOptions"))
{
 h = .Call("R_curl_easy_init", PACKAGE = "RCurl")

 if(length(.defaults)) {
   i = match(names(.defaults), names(.opts))
   .opts[names(.defaults)[is.na(i)]] = .defaults[is.na(i)]
 }
 
 curlSetOpt(..., .opts = .opts, curl = h, .encoding = .encoding)
 
 h
}

dupCurlHandle =
function(curl, ..., .opts = NULL, .encoding = integer())
{
 h = .Call("R_curl_easy_duphandle", curl, PACKAGE = "RCurl")

 curlSetOpt(..., .opts = .opts, curl = h, .encoding = .encoding)

 h
}

setGeneric("reset",
            function(x, ...)
              standardGeneric("reset"))

setMethod("reset", "CURLHandle",
           function(x, ...) {
               .Call("R_curl_easy_reset", x, PACKAGE = "RCurl")
           })
  


curlEscape =
function(urls)
{
   .Call("R_curl_escape", as.character(urls), TRUE, PACKAGE = "RCurl")
}


curlUnescape =
function(urls)
{
   .Call("R_curl_escape", as.character(urls), FALSE, PACKAGE = "RCurl")
}   


if(FALSE) {
  tbls = readHTMLTable("http://en.wikipedia.org/wiki/Percent-encoding", stringsAsFactors = FALSE)
  tt = tbls[[5]]
  PercentCodes = structure(as.character(tt[2,]), names = as.character(tt[1,]))
  cat(paste(sQuote(names(PercentCodes)), dQuote(PercentCodes), sep = " = ", collapse = ",\n\t"))  
}
PercentCodes = c(
	'%' = "%25",  # this has to go first.  
        '!' = "%21",
	'*' = "%2A",
	'"' = "%22",
	'\'' = "%27",
	'(' = "%28",
	')' = "%29",
	';' = "%3B",
	':' = "%3A",
	'@' = "%40",
	'&' = "%26",
	'=' = "%3D",
	'+' = "%2B",
	'$' = "%24",
	',' = "%2C",
	'/' = "%2F",
	'?' = "%3F",
	'#' = "%23",
	'[' = "%5B",
	']' = "%5D",
	'{' = "%7B",
	'}' = "%7D",  
        ' ' = '%20',
        '\r' = '%0D',
        '\n' = '%OA')

curlPercentEncode =
function(x, amp = TRUE, codes = PercentCodes, post.amp = FALSE)
{
  if(!amp) {
     i = match("&", names(codes))
     if(!is.na(i))
       codes = codes[ - i ]
   }
  
  for(i in seq(along = codes)) {
     x = gsub(names(codes)[i], codes[i], x, fixed = TRUE)
  }

  if(post.amp)
     x = gsub("%", "%25", x, fixed = TRUE)
  x              
}

esc =
  #
  # An alternative approach.
  #
function(x, codes = RCurl:::PercentCodes)
{
  els = strsplit(x, "")[[1]]
  i =  match(els, names(codes), 0L)
  
  els[ i != 0 ] = codes[ i ]
  paste(els, collapse = "")
}
