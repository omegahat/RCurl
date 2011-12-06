#include <Rdefines.h>

extern size_t R_Curl_base64_encode(const char *inp, size_t insize, char **outptr);

SEXP
R_encode_int_array(SEXP rarray)
{
    char *ans;
    int len = 3 * Rf_length(rarray) * sizeof(int);
    ans = R_alloc(3 * Rf_length(rarray), sizeof(int));
    memset(ans, '\0', len);
    R_Curl_base64_encode((char *) INTEGER(rarray), sizeof(int) * Rf_length(rarray), &ans);
    return(ScalarString(mkChar(ans)));
}

SEXP
R_encode_intAsByte_array(SEXP rarray)
{
    char *ans;
    int len = 3 * Rf_length(rarray) * sizeof(int), i, n;
    char *tmp;

    n = Rf_length(rarray);
    tmp = R_alloc(n, sizeof(char));

    for(i = 0; i < n ; i++) {
	tmp[i] = (char) INTEGER(rarray)[i];
    }
    ans = R_alloc(3 * Rf_length(rarray), sizeof(int));
    memset(ans, '\0', len);
    R_Curl_base64_encode(tmp, n, &ans);
    return(ScalarString(mkChar(ans)));
}

