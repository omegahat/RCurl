#include <curl/curl.h>
#include <Rdefines.h>
SEXP R_getAuthValues()
{
	SEXP ans = NEW_NUMERIC(10);
	int i = 0;
	REAL(ans)[i++] = CURLAUTH_ONLY;
	REAL(ans)[i++] = CURLAUTH_ANY;
	REAL(ans)[i++] = CURLAUTH_NTLM;
	REAL(ans)[i++] = CURLAUTH_ANYSAFE;
	REAL(ans)[i++] = CURLAUTH_NTLM_WB;
	REAL(ans)[i++] = CURLAUTH_DIGEST_IE;
	REAL(ans)[i++] = CURLAUTH_BASIC;
	REAL(ans)[i++] = CURLAUTH_DIGEST;
	REAL(ans)[i++] = CURLAUTH_GSSNEGOTIATE;
	REAL(ans)[i++] = CURLAUTH_NONE;
	return(ans);
}
