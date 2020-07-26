library(RCurl)
downloadFile2 =
function(u, f, curl = getCurlHandle(...), ...)
{
    out = file(f, "wb")
    on.exit(close(out))
    curlPerform(url = u, writefunction = getNativeSymbolInfo("R_curl_write_binary_data_to_connection")$address, 
                file = out, curl = curl, .isProtected = c(TRUE, TRUE))
}

to = tempfile()
downloadFile2("https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/R_logo.svg/165px-R_logo.svg.png", to)
