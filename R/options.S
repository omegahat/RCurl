if(FALSE) {
setClass("CurlOptions",
         representation(ids="integer",
                        values="list"))

curlOptions =
function(..., .opts = list())
{
    .args = rev(list(...))  # Why rev()?
   
    if(length(.args) == 0)
      return(NULL)

    dups = duplicated(names(.args))
    if(any(dups)) {
      warning("Duplicated curl options: ", paste(names(.args)[dups], collapse = ", "))
      .args = .args[!dup]
    }

    if(length(names(.args)) == 0)
      stop("curl options with no names")
    else if(any(names(.args) == ""))
        stop("unnamed curl option(s): ", .args[names(.args) == "" ])
    
    opts = mapCurlOptNames(names(.args))

    o = new("CurlOptions")
    o@ids = opts
    o@values = .args

    o
}  
} # FALSE



if(FALSE) {
  # Try to get these using GccTranslationUnit.
  # Yes. See CodeGeneration.
CurlConstants =
 c(file = 1,
   writedata = 1,
   url = 2,
   port = 3,
   proxy = 4,
   userpwd = 5,
   proxyuserpwd = 6,
   range = 7,
   infile = 9,
   errorbufffer = 10,
   writefunction = 11,
   readfunction = 12,
   timeout = 13,
   infilesize = 14,
   postfields = 15,
   referer = 16,
   ftpport = 17,
   useragent = 18,
   low.speed.limit = 19,
   low.speed.time = 20,
   resume.from =  21,
   cookie = 22,
   httpheader = 23,
   httppost = 24,
   sslcert =25,


   verbose = 26,
   followlocation=27,

   netrc = 28,
   httpauth=29,
   cookiefile=30,
   crlf=31,
   headerfunction=32,
   sslversion=33,   # long
   customerequest = 34, # string
   interface = 35,  # string
   krb4level = 36, # "string"
   ssl.verifypeer = 37, # long
   cainfo = 38, # string
   capath = 39, # string
   passwdfunction = 40, # function
   filetime=41, # long
  maxredirs = 42, # long
  maxconnects = 43, # long

fresh.connect = 44, #long
forbid.reuse = 45, # long
egdsocket = 46, # string
connecttimeout = 47, # long
httpget = 48, # long
ssl.verifyhost = 49, # long
cookiejar = 50, # string
ssl.cipher.list = 51, # string (colon separated)
http.version = 52, # enum (long)

dns.cache.timeout = 53, # long
dns.use.global.cache = 54 , # long
debugfunction = 55 # function
)

} # FALSE


CurlNetrc = c(ignored = 0, optional = 1, required = 2)
mode(CurlNetrc) = "integer"
class(CurlNetrc) = c("CurlNetrcEnum", "Enum")


setClass("Enum", contains = "integer")
setMethod("show", "Enum", function(object) show(paste(names(object), " (", object, ")", sep = "")))


setClass("NetrcEnum", contains = "Enum")
setMethod("coerce", c("numeric", "NetrcEnum"),
          function(from, to, strict = TRUE) {
             asEnum(from, CurlNetrc, "NetrcEnum")
          })


asEnum = 
function(val, def, className)
{
  idx = ifelse(is.character(val), pmatch(val, names(def)), match(val, def))

  if(is.na(idx)) 
        stop("no match for enumeration value ", val, " of type ", className)

  new(className, .Data = def[idx]) 
}


listCurlOptions =
function()
{
   sort(names(getCurlOptionsConstants()))
}

getCurlOptionsConstants =
function()
{
 x = .Call("R_getCURLOptionEnum", PACKAGE = "RCurl")
 names(x) = gsub("_", ".", tolower(names(x)))

 x
}  

getCurlOptionTypes = 
function(opts = getCurlOptionsConstants())
{
  typeName = c("integer/logical", "string/pointer", "function", "large number")
  type = floor(opts / 10000)
  structure(typeName[type + 1], names = names(opts))
}


mapCurlOptNames =
function(ids, asNames = FALSE, error = FALSE)
{
   const = getCurlOptionsConstants()
   ids = tolower(ids)
    # Could use charmatch and differentiate between multiple matches
    # e.g. head matching header and headerfunction.
   w = pmatch(ids, names(const))

   if(any(is.na(w))) {
     (if(error) stop else warning) ("Unrecognized CURL options: ", paste(ids[is.na(w)], collapse = ", "))
     # w = w[!is.na(w)]
   }

   if(asNames)
     return(names(const)[w])
   
   as.integer(const[w])
}  


curlOptions =
function(..., .opts = list())
{
  .els = rev(merge(list(...), .opts))

  dups = duplicated(names(.els))
  if(any(dups)) {
      warning("Duplicated curl options: ", paste(names(.els)[dups], collapse = ", "))
      .els = .els[!dups]
  }
  
  if(length(.els)) {
      if(any(names(.els) == ""))
         stop("unnamed curl option(s): ", .els[names(.els) == "" ])
      names(.els) <- mapCurlOptNames(names(.els), asNames = TRUE)

     .els = .els[!is.na(names(.els))]
  }
  else
    .els = list()

  
  class(.els) = "CURLOptions"

  .els
}

merge.list <-
function(x, y, ...)
{
  if(length(x) == 0)
    return(y)

  if(length(y) == 0)
    return(x)
  
  i = match(names(y), names(x))
  i = is.na(i)
  if(any(i))
    x[names(y)[which(i)]] = y[which(i)]

  x
}


"[<-.CURLOptions" <-
function(x, i, value)
{
 if(is.character(i)) 
   i = mapCurlOptNames(i, asNames = TRUE) 
 
  NextMethod("[<-")
}

"[[<-.CURLOptions" <-
function(x, i, value)
{
 if(is.character(i)) 
   i = mapCurlOptNames(i, asNames = TRUE) 
 
  NextMethod("[[<-")
}



if(FALSE) {

  setCurlHeaders =
  #
  # This can be done via the setCurlOpt
  #
  # Do we want a ...  To specialized a function for general interactive use.
  # 
 function(headers, curl)
 {
  headers = paste(names(headers), headers, sep = ": ")
  .Call("R_curl_set_header", curl, headers, FALSE, PACKAGE = "RCurl")
 }  

}
