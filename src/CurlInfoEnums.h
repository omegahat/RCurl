#include <curl/curl.h>

#define CURLINFO(a) {#a, CURLINFO_##a}

NameValue CurlInfoNames[] = 
{
#include "CURLINFOTable.h"
};

