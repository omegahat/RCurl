dynCurlReader =
genHeader =
    #
    # [Done] txt = character()
    # [Test] max = NA
    # [Done] value = NULL
    # isHTTP = NA
    # [Done] encoding = NA
    # [Done] header = FALSE
    # Unused
    #    baseURL = NA
    #
    # Get rid of the trailing white space in the headerInfo
    # Should it be in the status message?
    #
    # Use encode():  use (and fix) RCurl:::multi...
    #
    #
    #  Fix handling of return value of 0 from the writefunction. Not working when we return 0 when
    #  number of bytes retrieved > max
    # Need encoding!!! Works now.
    #
    #
function(curl = getCurlHandle(), txt = character(), max = NA, value = NULL, verbose = FALSE,
          binary = NA, baseURL = NA, isHTTP = NA, encoding = NA, header = FALSE)     
{
    returnHeader = header
    header = character()
 
    headerInfo = character()
    followingLocation = FALSE
    numFollowingLines = 0L

    forceBinary = !missing(binary)

    content.type = character()

    buf = NULL
    usingBinary = FALSE
    
    setBinaryBuffer =
        function(b = binaryBuffer(len), len = 5000) {

             buf <<- b
             usingBinary <<- TRUE
             if(verbose)
                  cat("Reading binary data:\n")
             curlSetOpt(writefunction = getNativeSymbolInfo("R_curl_write_binary_data")$address,
                        file = buf@ref, curl = curl, .isProtected = c(TRUE, FALSE))
        }

    setTextBuffer =
        function() {
            if(verbose)
                  cat("Reading text data:\n")
            
             if(length(encoding) == 0 || is.na(encoding) || encoding == "") {
                 # Need to check content.type and content.type["charset"]
                 # are meaningful
                 encoding <<- content.type["charset"]
             }
                         
            curlSetOpt(writefunction = b, .encoding = encoding, curl = curl, .isProtected = TRUE)
            usingBinary <<- FALSE
        }


    body = txt
    b = function(str) {
      # cat("[body]", nchar(str), "\n")
      body <<- c(body, str)
      if(!is.na(max) && sum(nchar(body)) >= max)
          return(0L)
      
      nchar(str, "bytes")
    } 
 
    h = function(str) {
      if(verbose)
          cat("[header]",  gsub("[[:space:]]+$", "", str), "\n")

      if(followingLocation)
          numFollowingLines <<- numFollowingLines + 1L

      if(followingLocation && grepl("^HTTP", str)) {
         if(verbose)
            cat("start of second header. Should undo the body function!\n")
          
          # so receiving the next header
          headerInfo <<- character()
          numFollowingLines <<- NA
      }

#    if(followingLocation && !is.na(numFollowingLines) && numFollowingLines > 0L) {
#        # This doesn't get activated. The content goes to the body (writefunction)
#        # not to the header function.
#       if(verbose)
#          cat("Not actually following the location\n")
#    }
    

#      if(str == "\\r\\n") {
      if(grepl("^[[:space:]]+$", str)) {      
          if(verbose)
             cat("end of header\n")
          
          hdr = parseHTTPHeader(headerInfo)
          if(FALSE && hdr["status"] == 100) {
              headerInfo <<- character()
          } else {
              header <<- headerInfo
              headerInfo <<- hdr
          }
          if(as.integer(hdr["status"]) == 302) {
               if(verbose)
                  cat(" following location\n")
               followingLocation <<- TRUE
          }

          type = getContentType(hdr)
          content.type <<- type

          if(forceBinary && !is.na(binary) && binary) {
             setBinaryBuffer()
          } else if((length(type) && type != "") && as.integer(hdr["status"]) != 302) {
              if(verbose) {
                 cat("Content-Type =", type, "\n")              
                 cat("know content type, setting writefunction\n")
              }
              if(isBinaryContent(hdr, list(hdr["Content-Encoding"], type) ))
                 setBinaryBuffer()
              else
                 setTextBuffer()
          } else {
              if(verbose)
                 cat("Setting body handler\n")
              setBinaryBuffer()
          }
      } else
         headerInfo <<- c(headerInfo, str)
      
      nchar(str, "bytes")
 }

 getResult =
 function(fun = h)
 {
   ans = if(usingBinary)
            as(buf, "raw")
         else
            mapUnicodeEscapes(paste(body, collapse = ""))

   if(length(content.type))
       attr(ans, "Content-Type") = content.type

   if(!is.null(value))
       ans = value(tmp)

   if(returnHeader)
      list(header = headerInfo, body = ans)
   else
      ans
 }

  ans = list(update = h, getResult = getResult,
             reset = reset, 
             header = function() header,
             value = getResult,
             curl = function() curl)

  class(ans) <- c("DynamicRCurlTextHandler", "RCurlTextHandler", "RCurlCallbackFunction")
  ans
}

    




mapUnicodeEscapes =
  #
  #  processes the string, converting \u<hex>{4} sequences to bytes
  #  and returning a UTF-8 encoded string.
  #
  #
function(str, len = nchar(str) * 4L)
{
   str = as.character(str)
   len = rep(as.integer(len), length = length(str))
   
   if(any(grepl("\\\\u[0-9A-Fa-f]", str)))
     .Call("R_mapString", str, len, PACKAGE = "RCurl")
   else
     str
}
