
getURLAsynchronous = getURIAsynchronous =
  #
  # Getting the flexibility and semantics correct can be a little hard.
  # We want to allow people to pass in a different write function/routine
  # but also to handle the different streams separately.
  #
  #  A first cut is simply to no allow any customized write functions.
  #  Or to insist that they present the write functions as a list.
  #  We just replicate the object. If it is a closure using shared state,
  #  the text will be interleaved!

  #  If you call this function, you get to download the 
  #
function(url, ..., .opts = list(), write = multiTextGatherer(url), curl = getCurlHandle(),
          multiHandle = getCurlMultiHandle(), perform = Inf, .encoding = integer())
{
  if(!is.list(write)) 
     write = replicate(length(url), write)


  if(length(url) > 1) 
     curl =  lapply(url, function(id) dupCurlHandle(curl))
   else 
     curl = list(curl)

  if(length(.encoding))
    .encoding = rep(.encoding, length = length(url))
  
  for(i in seq(along = url)) {
    w = write[[i]]
    if(inherits(w, "RCurlCallbackFunction"))
         w = w$update
    opts = curlOptions(URL = url[i], writefunction = w, ..., .opts = .opts)
    curlSetOpt(.opts = opts, curl = curl[[i]], .encoding = if(length(.encoding)) .encoding[i] else integer())
  
    multiHandle = push(multiHandle, curl[[i]])
  }
  
  if(perform > 0) {
        ctr = 0
        while(TRUE) {
          status = curlMultiPerform(multiHandle)
          ctr <- ctr + 1
          if(status[2] == 0 || ctr > perform)
            break
        }
        if(status[2] == 0 && inherits(write, "MultiTextGatherer"))
           return(sapply(write, function(w) w$value()))
  }

     # Need to get the new write functions back if we didn't
 list(multiHandle = multiHandle, write = write)
}


setGeneric("complete", function(obj, ...) standardGeneric("complete"))
setMethod("complete", "MultiCURLHandle",
               function(obj, ...) {
                  while(TRUE) {
                     status = curlMultiPerform(obj)
                     if(status[2] == 0)
                       break
                  }
               })
  

multiTextGatherer =
function(uris)
{
  if(is.numeric(uris))
     ans = lapply(1:uris, basicTextGatherer)
  else {
     ans = lapply(uris, basicTextGatherer)
     names(ans) = uris
  }

  class(ans) <- "MultiTextGatherer"

  ans
}  

getCurlMultiHandle =
function()
{
  .Call("R_getCurlMultiHandle", PACKAGE = "RCurl")
}


setGeneric("push", function(obj, val, id = character()) standardGeneric("push"))
setGeneric("pop", function(obj, val) standardGeneric("pop"))



setMethod("push", c("MultiCURLHandle", "CURLHandle"),
               function(obj, val, id = character()) {
                 .Call("R_pushCurlMultiHandle", obj, val, PACKAGE = "RCurl")
                  # Should check id is not a number. That should not be allowed.
                 if(length(id) == 0)
                   id = length(obj@subhandles) + 1
                 else
                   id = as.character(id)

                 obj@subhandles[[id]] = val
                 obj
               })


setMethod("pop", c("MultiCURLHandle", "CURLHandle"),
               function(obj, val) {
                 .Call("R_popCurlMultiHandle", obj, val, PACKAGE = "RCurl")
                 obj
               })


setMethod("pop", c("MultiCURLHandle", "character"),
               function(obj, val) {
                 if(!length(names(obj@subhandles)) || !(val %in% names(obj@subhandles)))
                   stop("No such element in the collection of sub-handles")
                   
                 .Call("R_popCurlMultiHandle", obj, obj@subhandles[[val]], PACKAGE = "RCurl")
                 obj
               })



curlMultiPerform =
function(curl, multiple = TRUE)
{
  status = .Call("R_curlMultiPerform", curl, as.logical(multiple), PACKAGE = "RCurl")
  names(status) = c("status", "numHandlesRemaining")

  status
}

