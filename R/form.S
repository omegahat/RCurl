
getForm =
  #
  # The ... here are for the arguments to the form, not the curl options.
  #
  #
function(uri, ..., .params = character(), .opts = list(), curl = getCurlHandle(),
         .encoding = integer(), binary = NA, .checkParams = TRUE)  
{
    # should we merge params with ....
    # for now just one or the other.  
  if(missing(.params)) {
    .params = list(...)
  }

  if(length(.params) == 0) 
       warning("No inputs passed to form")
  else if(missing(.opts) && .checkParams)
    testCurlOptionsInFormParameters(.params)
  
    # Convert the arguments into a URL string.
  els = mapply(function(id, val) {
                              # turn name=c("a", "b") into
                              #  name=a&name=b
                                paste(id, curlEscape(val), sep="=", collapse="&")
               }, names(.params), .params)

   args = paste(els, collapse = "&")

   uri = paste(uri, args, sep = if(grepl("\\?", uri)) "&" else "?")

   getURLContent(uri, .opts = .opts, .encoding = .encoding, binary = binary, curl = curl)
}

testCurlOptionsInFormParameters =
function(.params)
{
  if(any( w <- names(.params) %in% listCurlOptions())) {
    warning("Found possible curl options in form parameters: ", paste(names(.params)[w], collapse = ", "))
    TRUE
  } else
    FALSE
}


PostStyles = c('HTTPPOST' = NA,
               'POST' = as.integer(47))

matchPostStyle =
function(style)
{
  if(is.na(style))
    return(style)
  
      # The style of the post, i.e. HTTPPOST or regular POST,
      # i.e. www-form-encoded or
  if(is.character(style)) {
        i = pmatch(tolower(style), tolower(names(PostStyles)))
        if(is.na(i))
          stop("POST style is not recognized: must be one of ", paste(names(PostStyles), collapse = ", "))
        as.integer(PostStyles[i])
    } else {
        if(!(style %in% PostStyles))
          warning("Unrecognized style value ", style)
        as.integer(style)
      }
}


.postForm =
function(curl, .opts, .params, style = 'HTTPPOST')
{
  .Call("R_post_form", curl, .opts, .params, TRUE, matchPostStyle(style), PACKAGE = "RCurl")
}

postForm =
  #
  # The ... here are for the arguments to the form, not the curl options.
  #
  #
function(uri, ...,
         .params = list(), .opts = curlOptions(url = uri),
         curl = getCurlHandle(), style = 'HTTPPOST',
         .encoding = integer(), binary = NA, .checkParams = TRUE,
         .contentEncodeFun = curlEscape) # Should probably be curlPercentEncode !
{
  isProtected = missing(curl)
  write = NULL
  noCurlOptions = missing(.opts)

  style = matchPostStyle(style)
  
   # merge the two sources of inputs
  .params = merge(list(...), .params)


   # Need to organize the types here into a structure.

 hasOwnWrite = any(c("writefunction", "headerfunction") %in% names(.opts))

 buf = NULL
 header = basicTextGatherer()
 if(!hasOwnWrite) {
     write = dynCurlReader(curl, verbose = FALSE, binary = binary, baseURL = uri, encoding = .encoding)
          # Defer the setting of the writefunction until we need to set it
          # When we finish with the header, we'll set the writefunction.
          # .opts[["writefunction"]] = write$update
     .opts[["headerfunction"]] = write$update

   on.exit(cleanupDynReader(NULL, curl))   
   isProtected = rep(isProtected, length(.opts))
   isProtected[length(isProtected)] = TRUE   

#   .opts[["writefunction"]] = write$update
   }

  # Force the curlOptions to be resolved at this point, but not set. So pass curl = NULL
  optionNames = names(.opts)
  .opts = curlSetOpt(url = uri, .opts = .opts, curl = NULL, .encoding = .encoding)

#  curlOptions[["httpost"]] <- .params
#  curlPerform(curl, .opts = curlOptions)

   if(!is.na(style) && style == PostStyles['POST']) {
     tmp = as.list(.params)
     .params = paste(
                     unlist(mapply(function(id, val)
                             paste(id, if(is(val, "AsIs")) val else .contentEncodeFun(val), sep = "="),
                          names(tmp), tmp)),
                  collapse = "&")
            
   } else
     .params = lapply(.params,
                       function(x)
                         if(is.atomic(x))
                              as.character(x)
                         else
                            x)
  

  if(length(.params) == 0) {
    postfields = getCurlOptionsConstants()["postfields"]
    if(!(postfields  %in% .opts$ids))
       warning("No inputs passed to form")
  } else if(noCurlOptions && .checkParams)
    testCurlOptionsInFormParameters(.params)
  
#  status = .Call("R_post_form", curl, .opts, .params, TRUE, as.integer(style),  PACKAGE = "RCurl")
  status = .postForm(curl, .opts, .params, style)

  if(any(!isProtected)) {
     # Reset the httppost field to NULL so we can release the values.
     # curlSetOpt(httppost = FALSE, curl = curl)
     curlSetOpt(httpget = TRUE, curl = curl)
  }

  if(!is.null(write)) {
     http.header = parseHTTPHeader(write$header())
     stop.if.HTTP.error(http.header)
  }
  
  if(!is.null(buf)) {
    processContent( as(buf, "raw"), header, .encoding)
  } else  if(!is.null(write)) 
    write$value()

  #XXX what if write is NULL - what do we return?
}  


cleanupDynReader =
function(fun, curl)
{
   curlSetOpt(writefunction = NULL, curl = curl)
   if(!is.null(fun))
      .Call("R_global_releaseObject", fun)
   TRUE
}


fileUpload =
function(filename = character(), contents = character(), contentType = character())
{
  if(length(contents) == 0 && !file.exists(filename))
     stop("specified file does not exist: ", filename, ".  You must specify a valid file name or provide the contents to send.")

  filename = path.expand(filename)

  if(!typeof(contents) == "raw")
     contents = as.character(contents)
  
  structure(list(filename = as.character(filename),
                 contents = contents,
                 contentType = as.character(contentType)),
            class = "FileUploadInfo")
}  
