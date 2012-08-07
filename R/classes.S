.onAttach =
function(...)
 library(methods)

         

setClass("MultiCURLHandle",
           representation(ref = "externalptr",
                          subhandles = "list"))

if(TRUE) {
  setClass("CURLHandle", representation(ref = "externalptr"))
} else
  setOldClass("CURLHandle")



setClass("CFILE", representation(ref = "externalptr"))
