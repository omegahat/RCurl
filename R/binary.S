setClass("RCurlBinaryBuffer", representation(ref = "externalptr"))

binaryBuffer =
function(initialSize = 5000)
{
  a = .Call(R_curl_BinaryData_new, as.integer(initialSize))
  new("RCurlBinaryBuffer", ref = a)
}  


setAs("RCurlBinaryBuffer", "raw",
       function(from, to) {
         .Call(R_curl_BinaryData_to_raw, from@ref)
       })


getBinaryURL =
function(url, ..., .opts = list(), curl = getCurlHandle(), .buf = binaryBuffer(.len), .len = 5000)
{
   getURL(url, ...,
          write = getNativeSymbolInfo("R_curl_write_binary_data")$address,
          file = .buf@ref, curl = curl, .opts = .opts)

   as(.buf, "raw")   
}
