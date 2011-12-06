#include <R_ext/Rdynload.h>
#include "Rcurl.h"

#define RegCallFun(a, b) {#a, (DL_FUNC)&a, b}

static R_CallMethodDef CallEntries[] = {
	RegCallFun(R_curl_global_init, 1),
	RegCallFun(R_curl_global_cleanup, 0),
        RegCallFun(R_curl_version_info, 1),

	RegCallFun(R_curl_easy_init, 0),
	RegCallFun(R_curl_easy_duphandle, 1),
	RegCallFun(R_curl_easy_reset, 1),

	RegCallFun(R_curl_easy_perform, 4),
	RegCallFun(R_curl_easy_setopt, 5),
	RegCallFun(R_curl_easy_getinfo, 2),

	RegCallFun(R_curl_escape, 2),
	RegCallFun(R_post_form, 5),

	RegCallFun(R_getCURLErrorEnum, 0),
	RegCallFun(R_getCURLInfoEnum, 0),
	RegCallFun(R_getCURLOptionEnum, 0),

	{NULL, NULL, 0}
};


void
R_init_RCurl(DllInfo *dll)
{
    R_useDynamicSymbols(dll, TRUE);
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
}

