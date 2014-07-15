dynCurlReader = 
#
# Reads the header and then sets the appropriate writefunction
# to harvest the body of the HTTP response.
#
function(curl = getCurlHandle(), txt = character(), max = NA, value = NULL, verbose = FALSE,
          binary = NA, baseURL = NA, isHTTP = NA, encoding = NA, header = FALSE) 
{
    returnHeader = header
    
    header = character()    # for the header
    buf = NULL              # for a binary connection.
    content.type = character()
    requestCount = 0

    curHeaderStatus = -1
    inBody = FALSE          # whether we are collecting content for the body or still working on the header
    if(verbose)
       cat("New call to dynCurlReader:", baseURL, "binary?", binary, "\n")

    specifiedBinary = !missing(binary) 

    headerEnded = FALSE
    mayFollowLocation = FALSE

    usingBinary = FALSE
    
    update = function(str) {

      if(verbose)
         cat("inBody? ", inBody, ", num bytes", nchar(str, "bytes"), "\n", sep = "")

# Basically, if we are waiting for the follow location and the very next call to this function
# does not       
#
#if(mayFollowLocation) browser()
      
      if(mayFollowLocation && length(txt) == 0 && !grepl("^(HTTP|FTP)", str[1])) {
          inBody <<- TRUE
          mayFollowLocation <<- FALSE
          setCurlBuffers()
          #XXX!!! Need to push str into the binary buffer if usingBinary == TRUE
          
      }

      if(grepl("^HTTP/1.[012] [0-9]{3}", str)) {
          if(length(txt) && inBody && mayFollowLocation) {
             inBody <<- FALSE
         }
      }
        
#(length(header) == 0 || curHeaderStatus %in% c(-1, 100))
                                                           # do we want a \\\n at the end of the string to avoid
                                                           # matching lines with white space in the body.
      if((!inBody || mayFollowLocation) && (length(str) == 0 || length(grep("^[[:space:]]+$", str)))) {
browser()          
              # Found the end of the header so wrapup the text and put it into the header variable
          headerEnded <<- TRUE
          oldHeader = header
	  header <<- c(txt, "")
          txt <<- character()
          if(is.na(isHTTP)) 
             isHTTP <<- length(grep("HTTP", header)) > 0

          if(isHTTP) {
             http.header = parseHTTPHeader(c(header, str))

            if(http.header[["status"]] == 100) { # && length(http.header) == 2)
               curHeaderStatus <<- 100
                   # see if there are any attributes to keep other than status and statusMessage.
               val.ids = setdiff(names(http.header), c("status", "statusMessage", "message"))  # ?? should we add "message"

               if(length(val.ids))
                 header <<- http.header[val.ids]
               else
                 header <<- character()

               return(nchar(str, "bytes"))
            } else
              curHeaderStatus = http.header[["status"]]

            if(length(oldHeader)) {
               tmp = setdiff(names(oldHeader), names(header))
               if(length(tmp))
                  header[tmp] <<- oldHeader[tmp]
            }          

         
            content.type <<- getContentType(http.header, TRUE)

            if(as.integer(curHeaderStatus) == 302)
                mayFollowLocation <<- TRUE
             else
                mayFollowLocation <<- FALSE

            if(!mayFollowLocation && is.na(binary))
               binary = isBinaryContent(http.header, list(http.header["Content-Encoding"], content.type) )
          

             # This happens when we get a "HTTP/1.1 100 Continue\r\n" and then
             # a blank line.  
            if(is.na(http.header["status"])) {
             header <<- character()
             inBody <<- FALSE
             return( nchar(str, "bytes") )
            }
         } else {  # if(isHTTP)
         
         }
          
       if(verbose)
          cat("Setting option to read content-type", content.type[1], "character set", content.type["charset"], "\n")

       if(!mayFollowLocation) {
browser()           
          setCurlBuffers()
       } else
           setTextBuffer()


#        inBody <<- TRUE
        if(verbose)
           print(header)

     } else {
          txt <<- c(txt, str)
          if (!is.na(max) && nchar(txt) >= max) 
              return(0)
     }

        nchar(str, "bytes")
    }


    setBinaryBuffer =
        function() {
             len = 5000
             buf <<- binaryBuffer(len)
             usingBinary <<- TRUE
             if(verbose) cat("Reading binary data:", content.type, "\n")
             curlSetOpt(writefunction = getNativeSymbolInfo("R_curl_write_binary_data")$address,
                       file = buf@ref, curl = curl, .isProtected = c(TRUE, FALSE))
        }

    setTextBuffer =
        function() {
             if(length(encoding) == 0 || is.na(encoding) || encoding == "")
                 encoding <<- content.type["charset"]
             
             curlSetOpt(writefunction = update, .encoding = encoding, curl = curl,
                          .isProtected = TRUE)
        }
    
    setCurlBuffers =
    function() {
browser()
        # if the caller set
       if(specifiedBinary && !is.na(binary) && !binary)
           return(setTextBuffer())

       if((length(content.type) == 0  || (is.na(binary) || binary))) 
           setBinaryBuffer()
        else 
           setTextBuffer()
    }

    useBinary =
     function() {
           if(specifiedBinary && !is.na(binary) && !binary)
               FALSE
            else if((length(content.type) == 0  || (is.na(binary) || binary)))
               TRUE
            else
               FALSE
     }
       
    

    reset = function() {
        txt <<- character()
        header <<- character()
        buf <<- NULL
        content.type <<- character()
        curHeaderStatus <<- -1
        inBody <<- FALSE
        isHTTP <- NA
        requestCount <<- requestCount + 1
    }

    val = if(missing(value))
             function(collapse = "", ...) {
                if(!is.null(buf)) {
                   ans = as(buf, "raw")
                   if(length(content.type))
                      attr(ans, "Content-Type") = content.type
                   return(ans)
                }
                 
                if (is.null(collapse)) 
                    return(txt)
                ans = paste(txt, collapse = collapse, ...)
                ans = encode(ans)
                if(length(content.type))
                      attr(ans, "Content-Type") = content.type

                if(returnHeader)
                   list(header = header, body = ans)
                else
                   ans
             }
           else 
             function() {
               tmp = if(!is.null(buf))
                        as(buf, "raw") 
                      else
                        encode(txt)
               if(length(content.type))
                    attr(tmp, "Content-Type") = content.type               
               ans = value(tmp)

               if(returnHeader)
                   list(header = header, body = ans)
               else
                  ans
             }

    encode =
      function(str) {
       #     RCurlIconv(str, from = "C99", to = encoding)
           mapUnicodeEscapes(str)
                   
      }


    ans = list(update = update, 
               value = val, 
               reset = reset, 
               header = function() header, 
               curl = function() curl)

    class(ans) <- c("DynamicRCurlTextHandler", "RCurlTextHandler", "RCurlCallbackFunction")
    ans$reset()
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
