curl = getCurlHandle()

txt = character()

f = function(str) {
  txt <<- c(txt, str)
  header = parseHTTPHeader(txt)
  if("Content-Type" %in% names(header)) {
    type = strsplit(header["Content-Type"], "/")[[1]]

    if(type[2] %in% c("x-gzip", "gzip")) {
      cat("Chaning reader\n")
      sym = getNativeSymbolInfo("R_curl_write_binary_data")$address
      curlSetOpt(writefunction = sym, curl = curl)
    }
  }
  nchar(str, "bytes")
}

u = "http://www.omegahat.org/RCurl/data.gz"

content = getURL(u,  headerfunction = f, curl = curl)


