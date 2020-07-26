#include "Rcurl.h"

#include "Rversion.h"

/* Not thread-safe, but okay for now. */
static char RCurlErrorBuffer[1000] = "<error message in RCurl which has not been set>";

#define R_CURL_CHECK_ERROR(status, handle) 	if(status != CURLE_OK) getCurlError(handle, 1, status);

#define MIN(a,b) ((a) < (b) ? (a)  : (b))


/* Callback routines that can be used to call R functions as handlers.  */
size_t R_curl_write_binary_data(void *buffer, size_t size, size_t nmemb, void *userData);

size_t R_curl_write_data(void *buffer, size_t size, size_t nmemb, RWriteDataInfo *);
size_t R_curl_write_header_data(void *buffer, size_t size, size_t nmemb, RWriteDataInfo *data);

int R_curl_getpasswd(SEXP fun, char *prompt, char* buffer, int  buflen  );
int R_curl_debug_callback (CURL *curl, curl_infotype type, char  *msg,  size_t len,  SEXP fun);
int R_curl_progress_callback (SEXP fun, double total, double now, double uploadTotal, double uploadNow);
CURLcode R_curl_ssl_ctx_callback(CURL *curl, void *sslctx, void *parm);
size_t R_curl_read_callback(void *ptr, size_t size, size_t nmemb, void *stream);
size_t R_curl_read_file_callback(void *ptr, size_t size, size_t nmemb, void *stream);
size_t R_curl_read_buffer_callback(void *ptr, size_t size, size_t nmemb, void *stream);
typedef struct BufInfo {
    size_t length;
    size_t pos;
    void *buf;
    void *cur;
} BufInfo;

void * getCurlPointerForData(SEXP el, CURLoption option, Rboolean isProtected, CURL *handle);
SEXP makeCURLcodeRObject(CURLcode val);
CURL *getCURLPointerRObject(SEXP obj);
CURLM *getCURLMPointerRObject(SEXP obj);
SEXP makeCURLPointerRObject(CURL *obj, int addFinalizer);
char *getCurlError(CURL *h, int throw, CURLcode status);
SEXP RCreateNamesVec(const char * const *vals,  int n);

void addFormElement(SEXP el, SEXP name, struct curl_httppost **post, struct curl_httppost **last, int which);
void buildForm(SEXP params, struct curl_httppost **post, struct curl_httppost **last);

SEXP getRStringsFromNullArray(const char * const *d);
SEXP RCurlVersionInfoToR(const curl_version_info_data *d);

struct curl_slist* Rcurl_set_header(CURL *obj, SEXP headers, Rboolean isProtected);

SEXP getCurlInfoElement(CURL *obj, CURLINFO id);

SEXP makeUTF8String(void *buffer, size_t len, cetype_t encoding);


SEXP
R_curl_easy_init(void)
{
	CURL *obj;
	CURLcode status;
	obj = curl_easy_init();
	if(obj) {
/*XX Debugging options */
 	    curl_easy_setopt(obj, CURLOPT_HTTPAUTH, CURLAUTH_ANY); /* or CURLAUTH_BASIC*/

	    if( (status = curl_easy_setopt(obj, CURLOPT_ERRORBUFFER, RCurlErrorBuffer)))
		getCurlError(obj, 1, status);

	}
	return(makeCURLPointerRObject(obj, TRUE));
}



SEXP
R_curl_easy_duphandle(SEXP handle)
{
	CURL *obj;
	obj = getCURLPointerRObject(handle);

	obj = curl_easy_duphandle(obj);

	return(makeCURLPointerRObject(obj, TRUE));
}


SEXP
R_curl_easy_perform(SEXP handle, SEXP opts, SEXP isProtected, SEXP encoding)
{
	CURL *obj;
	CURLcode status;

	if(GET_LENGTH(opts)) {
	    R_curl_easy_setopt(handle, VECTOR_ELT(opts, 1), VECTOR_ELT(opts, 0), isProtected, encoding);
	}

	obj = getCURLPointerRObject(handle);
	status =  curl_easy_perform(obj);

	R_CURL_CHECK_ERROR(status, obj);


	return(makeCURLcodeRObject(status));
}

SEXP
R_curl_global_cleanup()
{
	curl_global_cleanup();
	return(R_NilValue);
}

SEXP
R_curl_global_init(SEXP flag)
{
	CURLcode status;
	status = curl_global_init(INTEGER(flag)[0]);
	return(makeCURLcodeRObject(status));
}


#include <stdlib.h>

SEXP
R_curl_easy_reset(SEXP handle)
{
	CURL *obj;
   	obj = getCURLPointerRObject(handle);
	if(obj) {
	    curl_easy_reset(obj);
	    curl_easy_setopt(obj, CURLOPT_ERRORBUFFER, RCurlErrorBuffer);
	}

	return(ScalarLogical( obj ? TRUE : FALSE));
}

SEXP
R_curl_easy_setopt(SEXP handle, SEXP values, SEXP opts, SEXP isProtected, SEXP encoding)
{
	CURL *obj;
	CURLcode status = 0;
	CURLoption opt;

	int i, n, isProtectedLength;
	void *val;
	SEXP el;
	RWriteDataInfo *data;
	int useData = 0;

        /* get the CURL * handler */
	obj = getCURLPointerRObject(handle);

        /* Find out how many options we are setting. */
	n = GET_LENGTH(values);
	isProtectedLength = GET_LENGTH(isProtected);

	data = (RWriteDataInfo *) calloc(1, sizeof(RWriteDataInfo));
	data->encoding = CE_LATIN1;
	if(Rf_length(encoding) && INTEGER(encoding)[0] != NA_INTEGER ) {
 	    data->encoding =  INTEGER(encoding)[0];
	    data->encodingSetByUser = 1;
	} 
	

	/* Loop over all the options we are setting. */
	for(i = 0; i < n; i++) {
		opt = INTEGER(opts)[i];
		el = VECTOR_ELT(values, i);
  		   /* Turn the R value into something we can use in libcurl. */
		val = getCurlPointerForData(el, opt, LOGICAL(isProtected)[ i % isProtectedLength ], obj);

                if(opt == CURLOPT_WRITEFUNCTION && TYPEOF(el) == CLOSXP) {
			data->fun = val; useData++;
			status =  curl_easy_setopt(obj, CURLOPT_WRITEFUNCTION, &R_curl_write_data);
			status =  curl_easy_setopt(obj, CURLOPT_FILE, data);
			status =  curl_easy_setopt(obj, CURLOPT_HEADERFUNCTION, &R_curl_write_header_data);
			status =  curl_easy_setopt(obj, CURLOPT_WRITEHEADER, data);

		} else if(opt == CURLOPT_WRITEFUNCTION && TYPEOF(el) == EXTPTRSXP) {
                        curl_write_callback f;
			f = (curl_write_callback) val;
			status =  curl_easy_setopt(obj, CURLOPT_WRITEFUNCTION, f);
		} else  if(opt == CURLOPT_DEBUGFUNCTION && TYPEOF(el) == CLOSXP) {
			status =  curl_easy_setopt(obj, opt, &R_curl_debug_callback);
			status =  curl_easy_setopt(obj, CURLOPT_DEBUGDATA, val);

		} else  if(opt == CURLOPT_DEBUGFUNCTION && TYPEOF(el) == EXTPTRSXP) {
			status =  curl_easy_setopt(obj, opt, val);

		} else  if(opt == CURLOPT_HEADERFUNCTION && TYPEOF(el) == CLOSXP) {
			data->headerFun = val; useData++;
			status =  curl_easy_setopt(obj, opt, &R_curl_write_header_data);
			status =  curl_easy_setopt(obj, CURLOPT_WRITEHEADER, data);

		} else  if(opt == CURLOPT_HEADERFUNCTION && TYPEOF(el) == EXTPTRSXP) {
			status =  curl_easy_setopt(obj, opt, val);

		} else  if(opt == CURLOPT_PROGRESSFUNCTION && TYPEOF(el) == CLOSXP) {
			status =  curl_easy_setopt(obj, opt, &R_curl_progress_callback);
			status =  curl_easy_setopt(obj, CURLOPT_PROGRESSDATA, val);

		} else  if(opt == CURLOPT_PROGRESSFUNCTION && TYPEOF(el) == EXTPTRSXP) {
			status =  curl_easy_setopt(obj, opt, val);

		} else  if(opt == CURLOPT_SSL_CTX_FUNCTION && TYPEOF(el) == CLOSXP) {
			status =  curl_easy_setopt(obj, opt, &R_curl_ssl_ctx_callback);
			status =  curl_easy_setopt(obj, CURLOPT_SSL_CTX_DATA, val);

		} else  if(opt == CURLOPT_SSL_CTX_FUNCTION && TYPEOF(el) == EXTPTRSXP) {
			status =  curl_easy_setopt(obj, opt, val);

		} else  if(opt == CURLOPT_WRITEDATA && (TYPEOF(el) == EXTPTRSXP || inherits(el, "connection"))) {
			status =  curl_easy_setopt(obj, opt, val);

		} else  if(opt == CURLOPT_POSTFIELDS && TYPEOF(el) == RAWSXP) {
			status =  curl_easy_setopt(obj, opt, val);
			status =  curl_easy_setopt(obj, CURLOPT_POSTFIELDSIZE, Rf_length(el));

		} else if(opt == CURLOPT_READFUNCTION && TYPEOF(el) == CLOSXP) {
			status =  curl_easy_setopt(obj, opt, &R_curl_read_callback);
			status =  curl_easy_setopt(obj, CURLOPT_READDATA, val);
		} else if(opt == CURLOPT_READFUNCTION && TYPEOF(el) == RAWSXP) {
		        BufInfo *buf = (BufInfo *) malloc(sizeof(BufInfo));
			status =  curl_easy_setopt(obj, opt, &R_curl_read_buffer_callback);
			buf->length = Rf_length(el);
			buf->pos = 0;
			buf->buf = RAW(el);
			buf->cur = buf->buf;
			status =  curl_easy_setopt(obj, CURLOPT_READDATA, buf);
		} else if(opt == CURLOPT_READDATA) {
		    /* status = curl_easy_setopt(obj, CURLOPT_READFUNCTION, &R_curl_read_file_callback); */
			status = curl_easy_setopt(obj, CURLOPT_READDATA, val);
		} else {
#if 0
		    if(!val) {
			PROBLEM "invalid value for curl option %d", (int) opt
			    ERROR;
		    }
#endif
		    switch(TYPEOF(el)) {
		    case REALSXP:
		    case INTSXP:
		    case LGLSXP:
 		       {
			   long l = *(long *)val;
			   status = curl_easy_setopt(obj, opt, l);
		       }
		       break;
 		    default:
			status = curl_easy_setopt(obj, opt, val);
		    }
		}

		if(opt == CURLOPT_NOBODY && TYPEOF(el) == LGLSXP && LOGICAL(el)[0])
		    data->nobody = 1;

		if(status) {
			PROBLEM "Error setting the option for # %d (status = %d) (enum = %d) (value = %p): %s %s", 
			          i+1, status, opt, val, curl_easy_strerror(status), getCurlError(obj, 0, -1)
			WARN;
		}

	}

	if(!useData) free(data);

	return(makeCURLcodeRObject(status));
}

void
R_closeFILE(SEXP r_file)
{
    FILE *f = (FILE *) R_ExternalPtrAddr(r_file);
    if(f)  {
        fflush(f);
	fclose(f);
	R_SetExternalPtrAddr(r_file, NULL); // R_NilValue);
    }
}

SEXP
R_closeCFILE(SEXP r_file)
{
    R_closeFILE(r_file);
    return(r_file);
}

SEXP
R_openFile(SEXP r_filename, SEXP r_mode)
{
    const char *filename = CHAR(STRING_ELT(r_filename, 0));
    const char *mode = CHAR(STRING_ELT(r_mode, 0));
    FILE *ans;
    SEXP r_ans, klass, tmp;

    ans = fopen(filename, mode);
    if(!ans) {
	PROBLEM "Cannot open file %s", filename
	    ERROR;
    }
    PROTECT(klass = MAKE_CLASS("CFILE"));
    PROTECT(r_ans = NEW(klass));
    SET_SLOT(r_ans, Rf_install("ref"), tmp = R_MakeExternalPtr(ans, Rf_install("FILE"), R_NilValue));
    R_RegisterCFinalizer(tmp, R_closeFILE);
    UNPROTECT(2);
    return(r_ans);
}

size_t 
R_curl_read_buffer_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    BufInfo *buf = (BufInfo *) stream;
    size_t numBytes;

    if(buf->pos >= buf->length)
	return(0);

    numBytes = MIN(size * nmemb, buf->length - buf->pos); /* used to have +1 */
    memcpy(ptr, buf->cur, numBytes);
    buf->cur += numBytes;
    buf->pos += numBytes;

    return(numBytes);
}

size_t 
R_curl_read_file_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    FILE *f = (FILE *) stream;
    size_t num;
    num = fread(ptr, size, nmemb, f);
    return(num);
}

size_t 
R_curl_read_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    SEXP e, ans;
    size_t len = 0;

    PROTECT(e = allocVector(LANGSXP, 2));
    SETCAR(e, (SEXP) stream);
    SETCAR(CDR(e), ScalarReal( size * nmemb));
    ans = Rf_eval(e, R_GlobalEnv) ;  /*, &errorOccurred); */

    PROTECT(ans);
    if(Rf_length(ans) != 0)  {

	if(TYPEOF(ans) == RAWSXP) {
	    len = Rf_length(ans);
	    if(len > size * nmemb) {
		PROBLEM  "the read function returned too much data (%lf > %lf)", (double) len, (double) (size * nmemb)
		    ERROR;
	    }

	    memcpy(ptr, RAW(ans), len);
	} else if(TYPEOF(ans) == STRSXP) {
	    /* Deal with Encoding. */
	    const char * str;
	    str = CHAR(STRING_ELT(ans, 0));
	    len = strlen(str);
	    memcpy(ptr, str, len);
	}
    } 

    UNPROTECT(2);
    return(len);
}

#include <R_ext/Arith.h>

SEXP
R_post_form(SEXP handle, SEXP opts, SEXP params, SEXP isProtected, SEXP r_style)
{
	CURLcode status;
	CURL *obj;
        struct curl_httppost* post = NULL;
        struct curl_httppost* last = NULL;

	int style = CURLOPT_HTTPPOST;
	if(LENGTH(r_style)) {
	    style = asInteger(r_style);
	    if(style == NA_INTEGER)
		style = CURLOPT_HTTPPOST;

	    if(style != CURLOPT_HTTPPOST && style != CURLOPT_POST) {
		PROBLEM  "using form post style that is not HTTPPOST or POST"
		    WARN
	    }
	}

        /* get the CURL * handler */
	obj = getCURLPointerRObject(handle);

	if(style == CURLOPT_HTTPPOST) {
	    buildForm(params, &post, &last);
	    /* Arrange to have this struct curl_httppost object cleaned. */
	    RCurl_addMemoryAllocation(style, post, obj);
	    curl_easy_setopt(obj, style, post);
	} else {
	    const char *body;
	    body = CHAR(STRING_ELT(params, 0));
	    if(body && body[0])
		curl_easy_setopt(obj, CURLOPT_POSTFIELDS, body);
	}

	if(GET_LENGTH(opts)) 
	   R_curl_easy_setopt(handle, VECTOR_ELT(opts, 1), VECTOR_ELT(opts, 0), isProtected, R_NilValue);

	status = curl_easy_perform(obj);
	
	if(style != CURLOPT_HTTPPOST) {
	    curl_easy_setopt(obj, CURLOPT_POSTFIELDS, NULL);
	}


/*      Not supposed to call free here until we do the cleanup on the CURL object.
        We do it with the memory management for the CURL that we have for general
        allocations for that structure.
        Alternatively, we could duplicate the CURL object and then cleanup and free the form.
	curl_formfree(post) but this wouldn't be ideal.
 */

	R_CURL_CHECK_ERROR(status, obj);

	return(makeCURLcodeRObject(status));
}

void
buildForm(SEXP params, struct curl_httppost **post, struct curl_httppost **last)
{
	int i, n;
	SEXP names;

	n = GET_LENGTH(params);
	names = GET_NAMES(params);

	for(i = 0; i < n ; i++) 
	    addFormElement(VECTOR_ELT(params, i), STRING_ELT(names, i), post, last, i);
}


SEXP
R_buildForm(SEXP params, SEXP r_curl, SEXP r_set)
{
    CURL *curl = getCURLPointerRObject(r_curl);
    struct curl_httppost *post = NULL, *last = NULL;
    buildForm(params, &post, &last);
    RCurl_addMemoryAllocation(CURLOPT_HTTPPOST, post, curl);

    if(LOGICAL(r_set)[0])
	curl_easy_setopt(curl, CURLOPT_HTTPPOST, post);

    SEXP ans;
    PROTECT(ans = NEW_LIST(2));
    SET_VECTOR_ELT(ans, 0, R_MakeExternalPtr(post, Rf_install("curl_httppost"), R_NilValue));
    SET_VECTOR_ELT(ans, 1, R_MakeExternalPtr(last, Rf_install("curl_httppost"), R_NilValue));
    UNPROTECT(1);

    return(ans);
}


void
addFormElement(SEXP el, SEXP name, struct curl_httppost **post, struct curl_httppost **last, int which)
{
    int i, n ;
    
    /* If the value is an UploadInfo object, then deal with that.*/
    SEXP className = GET_CLASS(el);
    if(GET_LENGTH(className) && strcmp(CHAR(STRING_ELT(className, 0)), "FileUploadInfo") == 0) {
        const char *filename = NULL;
	const char *type = NULL;
	if(GET_LENGTH(VECTOR_ELT(el, 0))) 
           filename = CHAR(STRING_ELT(VECTOR_ELT(el, 0), 0));

	if(GET_LENGTH(VECTOR_ELT(el, 2)))
	   type = CHAR(STRING_ELT(VECTOR_ELT(el, 2), 0));


        if(GET_LENGTH(VECTOR_ELT(el, 1))) {  /* the contents field */
		const char *buf = CHAR(STRING_ELT(VECTOR_ELT(el, 1), 0));
		if(type) 
  		   curl_formadd(post, last, 
			     CURLFORM_PTRNAME, CHAR(name),
			     CURLFORM_BUFFER, filename,
			     CURLFORM_BUFFERPTR, buf,
			     CURLFORM_BUFFERLENGTH, strlen(buf),
			     CURLFORM_CONTENTTYPE, type,
			     CURLFORM_END);
		else
  		   curl_formadd(post, last, 
			     CURLFORM_PTRNAME, CHAR(name),
			     CURLFORM_BUFFER, filename,
			     CURLFORM_BUFFERPTR, buf,
			     CURLFORM_BUFFERLENGTH, strlen(buf),
			     CURLFORM_END);
	} else if(filename) {
		if(type) 
   		   curl_formadd(post, last, 
			     CURLFORM_PTRNAME, CHAR(name),
			     CURLFORM_FILE, filename,
			     CURLFORM_CONTENTTYPE, type,
			     CURLFORM_END);
		else
   		   curl_formadd(post, last, 
			     CURLFORM_PTRNAME, CHAR(name),
			     CURLFORM_FILE, filename,
			     CURLFORM_END);

	} else {
		PROBLEM "need to specify either the contents or a file name when uploading the contents of a file"
		ERROR;
	}
	
#if 0
        if(GET_LENGTH(VECTOR_ELT(el, 2))) {
		char *type = CHAR(STRING_ELT(VECTOR_ELT(el, 2), 0));
		curl_formadd(post, last, 
			     CURLFORM_PTRNAME, CHAR(name),
			     CURLFORM_CONTENTTYPE, type,
			     CURLFORM_END);
	}
#endif

        return;
    }
    

    n = GET_LENGTH(el);
    for(i = 0; i < n ; i++) {
	curl_formadd(post, last, 
		     CURLFORM_PTRNAME, CHAR(name),
		     CURLFORM_NAMELENGTH, strlen(CHAR(name)), 
		     CURLFORM_PTRCONTENTS, CHAR(STRING_ELT(el, i)),
		     CURLFORM_END);
    }
}



/* Use R_curl_version_info instead from R and extract the piece you want. 
   Not currently exported via the registration mechanism.
*/
SEXP
R_curl_version()
{
	return(mkString(curl_version()));
}

SEXP
R_curl_version_info(SEXP flag)
{
	curl_version_info_data *data;
	data = curl_version_info(INTEGER(flag)[0]);
	return(RCurlVersionInfoToR(data));
}


#if 0
SEXP
R_curl_set_header(SEXP handle, SEXP headers, SEXP isProtected)
{
	CURL *obj;
	struct curl_slist *headerList;
	obj = getCURLPointerRObject(handle);
	headerList = Rcurl_set_header(obj, headers, LOGICAL(isProtected)[0]);

/*XXX Do something with the list here. */
	return(R_NilValue);
}
#endif



struct curl_slist*
Rcurl_set_header(CURL *obj, SEXP headers, Rboolean isProtected)
{
	const char *val;
	int n, i;
	struct curl_slist *headerList = NULL;

	n = GET_LENGTH(headers);

	for(i = 0; i < n; i++) {
		val = CHAR(STRING_ELT(headers, i));
		if(!val || !val[0]) {
			PROBLEM "No value for HTTP header entry %d, ignoring it", i+i
			WARN;
			continue;
		}
		val = isProtected ? val : strdup(val);
		headerList = curl_slist_append(headerList, val);
		if(!isProtected) 
			RCurl_addMemoryAllocation(CURLOPT_LASTENTRY, val, obj);			
	}

#if 0
	if(obj)
   	   curl_easy_setopt(obj, CURLOPT_HTTPHEADER, headerList);
#endif

	return(headerList);
}


SEXP
R_curl_easy_getinfo(SEXP handle, SEXP which)
{
	CURL *obj;
	int i, n;
	SEXP ans;

	obj = getCURLPointerRObject(handle);

	n = GET_LENGTH(which);
	PROTECT(ans = allocVector(VECSXP, n));
	for(i = 0; i < n; i++) {
	  SET_VECTOR_ELT(ans, i, getCurlInfoElement(obj, INTEGER(which)[i]));
	}
	UNPROTECT(1);
	return(ans);
}


SEXP
R_curl_escape(SEXP vals, SEXP escape)
{
	int i, n;
	SEXP ans = R_NilValue;
	n = GET_LENGTH(vals);
	PROTECT(ans = allocVector(STRSXP, n));
	for(i = 0; i < n ; i++) {
	    char *tmp;
	    const char *ptr;
		ptr = CHAR(STRING_ELT(vals, i));
		if(ptr) {
			tmp = LOGICAL(escape)[0] ? curl_escape(ptr, 0) : curl_unescape(ptr, 0);
			if(tmp) {
				SET_STRING_ELT(ans, i, COPY_TO_USER_STRING(tmp ? tmp : ""));
				curl_free(tmp);
			}
		}
	}
	UNPROTECT(1);
	return(ans);
}


/****************************************************************/

SEXP
curlSListToR(struct curl_slist *l)
{
    int len = 0, i;
    struct curl_slist *p = l;
    SEXP ans;

    while(p) {
        if(p->data)
   	   len ++;
	p = p->next;
    }
    p = l;
    PROTECT(ans = NEW_CHARACTER(len));
    for(i = 0; i < len; i++, p = p->next) {
        if(p->data)
   	  SET_STRING_ELT(ans, i, mkChar(p->data));
    }
    UNPROTECT(1);
    return(ans);
}

SEXP 
curlCertInfoToR(struct curl_certinfo *certs)
{
#ifdef HAVE_CURLINFO_CERTINFO
    SEXP ans;
    int i;
    PROTECT(ans = NEW_LIST(certs->num_of_certs));
    for(i = 0; i < certs->num_of_certs; i++) {
	SET_VECTOR_ELT(ans, i, curlSListToR(certs->certinfo[i]));
    }
    UNPROTECT(1);
    return(ans);
#else
    PROBLEM "no suport for curl_certinfo in this version of libcurl. (Consider upgrading.)"
	WARN;
    return(R_NilValue);
#endif
}

SEXP
getCurlInfoElement(CURL *obj, CURLINFO id)
{
	double d;
	long l;
	char *s;
	SEXP ans = R_NilValue;

	switch( id & CURLINFO_TYPEMASK) {
  	    case CURLINFO_STRING:
		    curl_easy_getinfo(obj, id, &s);
		    if(s)
			ans = mkString(s);
	      break;
  	    case CURLINFO_DOUBLE:
		    curl_easy_getinfo(obj, id, &d);
		    ans = ScalarReal(d);
	      break;
  	    case CURLINFO_LONG:
		    curl_easy_getinfo(obj, id, &l);
		    ans = ScalarReal((double) l);
	      break;
  	    case CURLINFO_SLIST:
  	       {
 		    struct curl_slist *list = NULL;
#ifdef HAVE_CURLINFO_CERTINFO
		    if(id == CURLINFO_CERTINFO) {
                        struct curl_certinfo *certs = NULL;
       	 	        curl_easy_getinfo(obj, id, &certs);
			ans = curlCertInfoToR(certs);
		    } else 
#endif
                    {
       	 	       curl_easy_getinfo(obj, id, &list);
   		       ans = curlSListToR(list);
		    }
	       }
	      break;
  	    default:
		    PROBLEM "invalid getinfo option identifier"
		    ERROR;
	}

	return(ans);
}


int
R_curl_getpasswd(SEXP fun, char *prompt, char* buffer, int  buflen  )
{
	SEXP e, ans;
	int errorOccurred, status = 0;

	PROTECT(e = allocVector(LANGSXP, 3));
	SETCAR(e, fun);
	SETCAR(CDR(e), mkString(prompt));
	SETCAR(CDR(CDR(e)), ScalarInteger(buflen));

	ans = R_tryEval(e, R_GlobalEnv, &errorOccurred);
	if(GET_LENGTH(ans) > 0 && TYPEOF(ans) == STRSXP) {
	   strncpy(buffer, CHAR(STRING_ELT(ans, 0)), buflen);
	} else
 	    status = 1;

	UNPROTECT(1);

	return(status);
}


char *
getCurlError(CURL *h, int throw, CURLcode status)
{
#if 0
   if(throw) {
	   PROBLEM "%s", RCurlErrorBuffer
	   ERROR;
   }
#else

   if(throw) {
       SEXP e, ptr, fun;

       fun = Rf_findVarInFrame(R_FindNamespace(ScalarString(mkChar("RCurl"))), Rf_install("curlError"));

       PROTECT(e = Rf_allocVector(LANGSXP, 4));
       SETCAR(e, fun); ptr = CDR(e);
       SETCAR(ptr, ScalarInteger(status));  ptr = CDR(ptr);
       SETCAR(ptr, ScalarString(mkChar(RCurlErrorBuffer)));  ptr = CDR(ptr);
       SETCAR(ptr, ScalarLogical(throw));  ptr = CDR(ptr);

       Rf_eval(e, R_GlobalEnv);
       UNPROTECT(1);
   }

#endif
   return(RCurlErrorBuffer);
}


#include <stdlib.h>

void *
getCurlPointerForData(SEXP el, CURLoption option, Rboolean isProtected, CURL *curl)
{
	void *ptr = NULL;
	int i, n;

	int type = option/CURLOPTTYPE_OBJECTPOINT;

	if(el == R_NilValue)
	    return(ptr);

	if(type == 1 && (TYPEOF(el) == LGLSXP)) {
	    PROBLEM "trying to use a logical value for a curl option that requires a different type"
		ERROR;
	}

	// Do we want this or not? Added when adding write_binary_data_to_connection, but then
	// leverage inherits() directly in R_curl_easy_setopt
	if (inherits(el, "connection")) 
	    return(el);

	
	switch(TYPEOF(el)) {
	    case STRSXP:
		    if(option == CURLOPT_HTTPHEADER ||
                       option == CURLOPT_QUOTE || 
                       option == CURLOPT_PREQUOTE ||
                       option == CURLOPT_POSTQUOTE) {

                                   /* struct curl_slist */
			 ptr = (void *) Rcurl_set_header(curl, el, isProtected);
			 isProtected = FALSE;
		    } else {
/*XX Memory management */
			    if(GET_LENGTH(el) == 1) {
				    ptr = (void *) (isProtected ? CHAR(STRING_ELT(el, 0)) : strdup(CHAR(STRING_ELT(el, 0))));
			    } else {
				    const char **els;
				    n = GET_LENGTH(el);
                                    /* '(void *) els' broke RCurl under gcc4 */
				    ptr = els = (const char **) malloc(sizeof(char *) * n);
				    for(i = 0; i < n; i++) {
					    els[i] = (isProtected ? CHAR(STRING_ELT(el, i)) : strdup(CHAR(STRING_ELT(el, i))));
				    }
			    }
		    }
  	      break;
  	    case CLOSXP:
  		    if(!isProtected) {
			R_PreserveObject(el);
		    }
		    ptr = (void *) el;
  	      break;

	    case LGLSXP:
		    ptr = (void *) malloc(sizeof(long));
		    *( (long*) ptr) = (long) LOGICAL(el)[0];
	      break;
	    case REALSXP:
		    ptr = (void *) malloc(sizeof(long));
		    *( (long*) ptr) = (long) REAL(el)[0];
	      break;
	    case INTSXP:
		    ptr = (void *) malloc(sizeof(long));
		    *( (long*) ptr) = (long) INTEGER(el)[0];
  		        /* Don't allow TRUE or 1 for SSL_VERIFYHOST */
		    if(option == CURLOPT_SSL_VERIFYHOST && INTEGER(el)[0] == 1)
			*( (long*) ptr) = 2;
	      break;
	    case EXTPTRSXP:
		    ptr = (void *) R_ExternalPtrAddr(el);
		    isProtected = 1;
	      break;
	    case RAWSXP:
		    ptr = (void *) RAW(el);
		    isProtected = 1;
	      break;
   	    default:
		PROBLEM "Unhandled case for the value of curl_easy_setopt (R type = %d, option %d)", TYPEOF(el), option
		    ERROR;
  	      break;
	}

	if(ptr && !isProtected) {
		RCurlMemory *mem;
		mem = RCurl_addMemoryAllocation(option, ptr, curl);
		if(TYPEOF(el) == CLOSXP) 
  		    mem->type = R_OBJECT;
	}

	return(ptr);
}


/*
  Create an RCurl_BinaryData object and give it a hint at how big we want the 
  initial buffer, but don't allocate it. Leave that until we are in the actual 
  call to R and the we can use R_alloc() and have R clean up. Alternatively,
  we can just register a finalizer on this and clean up directly. 
*/


typedef struct {
  unsigned char *data;   /* the start of the data */
  unsigned char *cursor; /* where to put next insertion */ 
  unsigned int len;      /* how many bytes we have already. */
  unsigned int alloc_len; /* how much space we have allocated already. */
} RCurl_BinaryData;

RCurl_BinaryData *
getBinaryDataFromR(SEXP r_ref)
{
  RCurl_BinaryData *data;
  if(TYPEOF(r_ref) != EXTPTRSXP) {
     PROBLEM "BinaryData_to_raw expects and external pointer to access the C-level data structure"
     ERROR;
  }

  if(R_ExternalPtrTag(r_ref) != Rf_install("RCurl_BinaryData")) {
     PROBLEM "external pointer passed to BinaryData_to_raw is not an RCurl_BinaryData"
     ERROR;
  }
  data = (RCurl_BinaryData *) R_ExternalPtrAddr(r_ref);
  if(!data) {
     PROBLEM "nil value passed for RCurl_BinaryData object"
     ERROR;
  }
  return(data);
}

void
R_curl_BinaryData_free(SEXP r_ref)
{
  RCurl_BinaryData *data = getBinaryDataFromR(r_ref);
  if(data->data)
      free(data->data);
  free(data);
}

SEXP
R_curl_BinaryData_new(SEXP r_size)
{
  int size = INTEGER(r_size)[0];
  SEXP r_ans;
  RCurl_BinaryData *data;

  data = (RCurl_BinaryData *) malloc(sizeof(RCurl_BinaryData));

  if(!data) {
     PROBLEM "cannot allocate space for RCurl_BinaryData: %d bytes", (int) sizeof(RCurl_BinaryData)
     ERROR;
  }  

  size = size > 0 ? size : 1;
  data->alloc_len = size;
  data->data = (unsigned char *) malloc( size * sizeof(unsigned char ));
  data->cursor = data->data;
  data->len = 0;

  if(!data->data) {
     PROBLEM "cannot allocate more space: %d bytes", data->alloc_len
     ERROR;
  }  


  PROTECT(r_ans = R_MakeExternalPtr(data, Rf_install("RCurl_BinaryData"), R_NilValue));
  R_RegisterCFinalizer(r_ans, R_curl_BinaryData_free);
  UNPROTECT(1);
  return(r_ans);
}

SEXP
R_curl_BinaryData_insert(SEXP r_buf, SEXP r_data)
{
    RCurl_BinaryData *buf;
    buf = (RCurl_BinaryData *) R_ExternalPtrAddr(r_buf);
    if(!buf) {
	PROBLEM "NULL buffer passed to R_curl_BinaryData_insert"
	    ERROR;
    }
    R_curl_write_binary_data(RAW(r_data), 1, Rf_length(r_data), buf);
    return(R_NilValue);
}


SEXP
R_curl_BinaryData_to_raw(SEXP r_ref)
{
  RCurl_BinaryData *data;
  SEXP r_ans;
 
  data = getBinaryDataFromR(r_ref);

  r_ans = allocVector(RAWSXP, data->len * sizeof(unsigned char ));
  memcpy(RAW(r_ans), data->data, data->len * sizeof(unsigned char ));

  return(r_ans);
}

#define MAX(a, b)  ((a) < (b) ? (b) : (a))

size_t 
R_curl_write_binary_data(void *buffer, size_t size, size_t nmemb, void *userData)
{
  RCurl_BinaryData *data;
  int total = size*nmemb;
  data = (  RCurl_BinaryData *) userData;
  if(!data->data || (data->cursor +  total >= data->data + data->alloc_len )) {
       data->alloc_len = MAX( 2 * data->alloc_len, data->alloc_len + total);
       data->data = (unsigned char *) realloc(data->data, sizeof(unsigned char ) * data->alloc_len);
       if(!data->data) {
         PROBLEM "cannot allocate more space: %d bytes", data->alloc_len
         ERROR;
       }
       data->cursor = data->data + data->len;
  }

  memcpy(data->cursor, buffer, total);
  data->len += total;
  data->cursor += total;

  return(total);
}



#include "R_ext/Connections.h"
#if 0
SEXP
R_test_write_con(SEXP con)
{
    char buf[4] = "abc";
    R_WriteConnection( R_GetConnection(con), buf, 3);
    return(R_NilValue);
}
#endif


size_t 
R_curl_write_binary_data_to_connection(void *buffer, size_t size, size_t nmemb, void *userData)
{
//    Rprintf(" incoming address %p\n", userData);
//    Rf_PrintValue((SEXP) userData);
    R_WriteConnection( R_GetConnection( (SEXP) userData), buffer, size*nmemb);
    return(size*nmemb);
}

size_t
R_call_R_write_function(SEXP fun, void *buffer, size_t size, size_t nmemb, RWriteDataInfo *data, cetype_t encoding)
{
	SEXP str, e, ans;
	int errorOccurred = 0;
	size_t numRead = 0;

	PROTECT(e = allocVector(LANGSXP, 2));
	SETCAR(e, fun);

	/* Use Latin-1 encoding for now. Look into more intelligent, dynamic and adaptive schemes
           such as allowing the user to specify the encoding or read it from the HTTP response 
           header but I am not certain we can believe that, so potentially read the contents a little
           e.g. use IsASCII. */
#if defined(R_VERSION) && R_VERSION >= R_Version(2, 8, 0)
#if 0
	if(FALSE && encoding != CE_NATIVE)
	    PROTECT(str = makeUTF8String(buffer, size * nmemb, encoding));
	else
#endif
//    if(((char *) buffer)[0] == '\377' && ((char *) buffer)[1] == '\376') {
//	buffer = buffer + 2;
//      nmemb =- 2;
//    }
	    // probably don't need the encoding at this point!
#if 0
        const char *tmp;
	int len = size * nmemb;
	tmp = Rf_reEnc(buffer, CE_NATIVE, CE_UTF8, 0);
	len = strlen(tmp);
	PROTECT(str = mkCharLenCE(tmp, len, encoding));
#else

	PROTECT(str = mkCharLenCE(buffer, size * nmemb, encoding));

#endif

#else
	/* PROTECT(str = mkCharLen(buffer, size * nmemb)); */
//        PROTECT(str = mkCharLen(buffer, size *nmemb));  /* Problems with the upload example in complete.Rd */
	{
		/* Can't use mkCharLen because we need the encoding to be latin1 for at least some of our examples 
                   e.g. the HTML files from the RCurl website that were generated from XML via xsltproc.
                 */
  	  char *tmp = (char *) R_alloc(size * nmemb + 1, sizeof(char));
	  memcpy(tmp, buffer, size*nmemb);
	  tmp[size*nmemb] = '\0';
  	  PROTECT(str = mkCharCE(tmp, encoding));
	}
	/*   This would avoid the copy, but doesn't allow us to specify the latin encoding.
  	  PROTECT(str = mkChar(translateChar(mkCharLen(buffer, size * nmemb))));
         */
#endif

	SETCAR(CDR(e), TYPEOF(str) == CHARSXP ? ScalarString(str) : str);


	PROTECT(ans = Rf_eval(e, R_GlobalEnv)); /* , &errorOccurred); */
	if(TYPEOF(ans) == LGLSXP) {
	    if(LOGICAL(ans)[0])
		numRead = size*nmemb;
	    else
		numRead = 0;
/*
             if(LOGICAL(ans)[0] == 1)
		errorOccurred = 1;
*/
	} else if(TYPEOF(ans) == INTSXP) {
		numRead = INTEGER(ans)[0];
	} else 
	    numRead = asInteger(ans);

	UNPROTECT(3);

	if(numRead < size*nmemb  && encoding != CE_NATIVE) {
	    PROBLEM  "only read %d of the %d input bytes/characters", 
                     (int) numRead, (int) (size*nmemb)
   	    WARN;
	}

#ifndef WITH_CE
	/* When we use PROTECT(str = mkCharCE(buffer, CE_LATIN1)); , the R string can 
           appear to have more characters via nchar() than nmemb * size tells us.  */

	if(errorOccurred)
	    return(0);
	if(encoding != CE_NATIVE)
	    return(size * nmemb);
	else
	    return(numRead);

//	return(errorOccurred ? 0 :  (numRead >= size * nmemb ? size *nmemb : numRead)) ;
#else
//	return(errorOccurred ? 0 :  size *nmemb);
	return(errorOccurred ? 0 :  (numRead >= size * nmemb ? size *nmemb : numRead)) ;
#endif
}

void
checkEncoding(char *buffer, size_t len, RWriteDataInfo *data)
{
	SEXP e, ns_env, ns_name;
	int ans;
	PROTECT(e = allocVector(LANGSXP, 2));
#if 0
	SETCAR(e, Rf_install("findHTTPHeaderEncoding"));
#else
	PROTECT(ns_name = mkString("RCurl"));
	ns_env = R_FindNamespace(ns_name);
	SETCAR(e, findVarInFrame(ns_env, Rf_install("findHTTPHeaderEncoding")));
	UNPROTECT(1);
#endif
	SETCAR(CDR(e), ScalarString(mkCharLen(buffer, len)));
	ans = INTEGER(Rf_eval(e, R_GlobalEnv))[0];

	UNPROTECT(1);
	
	if(ans != -1) {
	    data->encoding = ans;
	}
}


size_t
R_curl_write_header_data(void *buffer, size_t size, size_t nmemb, RWriteDataInfo *data)
{
    if(data->nobody == 0 && data->encodingSetByUser == 0) 
        checkEncoding(buffer, nmemb*size, data);

    if(data->headerFun) {
        return(R_call_R_write_function(data->headerFun, buffer, size, nmemb, data, CE_NATIVE));
    }
    return(nmemb*size);
}


size_t
R_curl_write_data(void *buffer, size_t size, size_t nmemb, RWriteDataInfo *data)
{
     return(R_call_R_write_function(data->fun, buffer, size, nmemb, data, data->encoding));
}



#include <Rversion.h>

const char  * const CurlInfoTypeNames[] =  {
    "TEXT", "HEADER_IN", "HEADER_OUT",
    "DATA_IN", "DATA_OUT", "SSL_DATA_IN", "SSL_DATA_OUT", 
    "END"
};

int
R_curl_debug_callback (CURL *curl, curl_infotype type, char  *msg,  size_t len,  SEXP fun)
{
        SEXP str, e, tmp;
	int errorOccurred;

	PROTECT(e = allocVector(LANGSXP, 4));
	SETCAR(e, fun);

#if defined(R_VERSION) && R_VERSION >= R_Version(2, 6, 0)
	{
	  char * buf = (char *) malloc((len + 1)* sizeof(char));
	  if(!buf) {
	      PROBLEM "cannot allocate memory for string (%d bytes)", (int) len
 	      ERROR;
	  }
	  memcpy(buf, msg, len);	  
          buf[len] = '\0';
	  PROTECT(str = mkChar(buf));
	  free(buf);
	}
#else
#if 0
	PROTECT(str = allocString(len * sizeof(char) + 1));
	memcpy(CHAR(str), msg, len);
	CHAR(str)[len] = '\0';
#else
//	PROTECT(str = mkCharLen(msg, len * nmemb));
	PROTECT(str = mkCharLenCE(msg, len * nmemb, CE_LATIN1));
#endif
#endif
	SETCAR(CDR(e), ScalarString(str));

	SETCAR(CDR(CDR(e)), tmp = ScalarInteger(type));
	SET_NAMES(tmp, mkString( CurlInfoTypeNames[type] ));

	SETCAR(CDR(CDR(CDR(e))), makeCURLPointerRObject(curl, FALSE));

	R_tryEval(e, R_GlobalEnv, &errorOccurred);

	UNPROTECT(2);
	return(0);
}



int
R_curl_progress_callback (SEXP fun, double total, double now, double uploadTotal, double uploadNow)
{
	SEXP down, up, e, ans;
	int errorOccurred, status = 0;
	static const char * const names[] = {"downloadTotal", "downloadNow",
				"uplodateTotal", "uploadNow"};


	PROTECT(e = allocVector(LANGSXP, 3));
	SETCAR(e, fun);

	PROTECT(down = allocVector(REALSXP, 2));
	REAL(down)[0] = total;
	REAL(down)[1] = now;
	SET_NAMES(down, RCreateNamesVec(names, 2));
	SETCAR(CDR(e), down);

	PROTECT(up = allocVector(REALSXP, 2));
	REAL(up)[0] = uploadTotal;
	REAL(up)[1] = uploadNow;
	SET_NAMES(up, RCreateNamesVec(names+2, 2));
	SETCAR(CDR(CDR(e)), up);

	ans = R_tryEval(e, R_GlobalEnv, &errorOccurred);

	if(GET_LENGTH(ans) && (TYPEOF(ans) == INTSXP || TYPEOF(ans) == REALSXP || TYPEOF(ans) == LGLSXP)) {
	    switch(TYPEOF(ans)) {
	    case REALSXP:
		status = (int) REAL(ans)[0];
		break;
	    case INTSXP:
		status = (int) INTEGER(ans)[0];
		break;
	    case LGLSXP:
		status = (int) LOGICAL(ans)[0];
	    }
//	    status = INTEGER(ans)[0];
	}
	else
	    status = errorOccurred;

	UNPROTECT(3);
	return(status);
}


SEXP
makeCURLcodeRObject(CURLcode val)
{
	SEXP ans;
	ans = allocVector(INTSXP, 1);
/*XXX Put a name on this to get the symbolic value. */
	INTEGER(ans)[0] = val;
	return(ans);
}

CURL *
getCURLPointerRObject(SEXP obj)
{
	CURL *handle;
	SEXP ref;
	if(TYPEOF(obj) != EXTPTRSXP)
   	   ref = GET_SLOT(obj, Rf_install("ref"));
	else
    	   ref = obj;

	handle = (CURL *) R_ExternalPtrAddr(ref);
	if(!handle) {
		PROBLEM "Stale CURL handle being passed to libcurl"
		ERROR;
	}

	if(R_ExternalPtrTag(ref) != Rf_install("CURLHandle")) {
		PROBLEM "External pointer with wrong tag passed to libcurl. Was %s",
                        CHAR(PRINTNAME(R_ExternalPtrTag(ref)))
		ERROR;
	}

	return(handle);
}

CURLM *
getCURLMPointerRObject(SEXP obj)
{
	CURLM *handle;
	SEXP ref;
	if(TYPEOF(obj) != EXTPTRSXP)
   	   ref = GET_SLOT(obj, Rf_install("ref"));
	else
    	   ref = obj;

	handle = (CURLM *) R_ExternalPtrAddr(ref);
	if(!handle) {
		PROBLEM "Stale CURLM handle being passed to libcurl"
		ERROR;
	}

	if(R_ExternalPtrTag(ref) != Rf_install("MultiCURLHandle")) {
		PROBLEM "External pointer with wrong tag passed to libcurl. Was %s",
                        CHAR(PRINTNAME(R_ExternalPtrTag(ref)))
		ERROR;
	}

	return(handle);
}

static void
R_finalizeCurlHandle(SEXP h)
{
   CURL *curl = getCURLPointerRObject(h);

   if(curl) {
#ifdef RCURL_DEBUG_MEMORY
     REprintf("Clearing curl handle %p\n", (void *)curl);fflush(stderr);  
#endif
     CURLOptionMemoryManager *mgr = RCurl_getMemoryManager(curl);
     curl_easy_cleanup(curl);
     RCurl_releaseManagerMemoryTickets(mgr); 
   }
}

static void
R_finalizeMultiCurlHandle(SEXP h)
{
   CURLM *multi_handle = getCURLMPointerRObject(h);

   if(multi_handle) {
#ifdef RCURL_DEBUG_MEMORY
     REprintf("Clearing multi-handle %p\n", (void *)multi_handle);fflush(stderr);  
#endif

     CURLMsg *msg;
     int numMsgs = 1;

     while( (msg = curl_multi_info_read(multi_handle, &numMsgs)) ) {
       curl_multi_remove_handle(multi_handle, msg->easy_handle);
#if 0
/* This is problematic. These CURL handles may still be in use in R, i.e. reachable. So we cannot clean them.*/
       CURLOptionMemoryManager *mgr = RCurl_getMemoryManager(msg->easy_handle);
       curl_easy_cleanup(msg->easy_handle);
       RCurl_releaseManagerMemoryTickets(mgr); 
#endif
     }
	 
   curl_multi_cleanup(multi_handle);
   }
}

SEXP
R_test_finalizeCurlHandle(SEXP h)
{
    R_finalizeCurlHandle(h);
    return(ScalarLogical(TRUE));
}


SEXP
makeCURLPointerRObject(CURL *obj, int addFinalizer)
{
	SEXP ans, klass, ref;

	if(!obj) {
		PROBLEM "NULL CURL handle being returned"
		ERROR;
	}

#if 0
	PROTECT(ans = R_MakeExternalPtr((void *) obj, Rf_install("CURLHandle"), R_NilValue));
	SET_CLASS(ans, mkString("CURLHandle"));
	if(addFinalizer)
   	   R_RegisterCFinalizer(ans, R_finalizeCurlHandle);
	UNPROTECT(1);
#else
	PROTECT(klass = MAKE_CLASS("CURLHandle"));
	PROTECT(ans = NEW(klass));
	PROTECT(ref = R_MakeExternalPtr((void *) obj, Rf_install("CURLHandle"), R_NilValue));

	if(addFinalizer) {
#ifdef RCURL_DEBUG_MEMORY
	    Rprintf("adding finalizer to curl object %p\n", obj);fflush(stderr);
#endif
	    R_RegisterCFinalizer(ref, R_finalizeCurlHandle);
	}
	ans = SET_SLOT(ans, Rf_install("ref"), ref);

	UNPROTECT(3);

#endif

	return(ans);
} 


#if 0
SEXP
R_getCURLOptionEnum()
{
 
	SEXP ans;
	int i = 0;
	ans = allocVector(INTSXP, 31);
	INTEGER(ans)[i++] = CURLOPT_FILE;
	INTEGER(ans)[i++] = CURLOPT_URL;
	INTEGER(ans)[i++] = CURLOPT_PORT;
	INTEGER(ans)[i++] = CURLOPT_PROXY;
	INTEGER(ans)[i++] = CURLOPT_USERPWD;
	INTEGER(ans)[i++] = CURLOPT_PROXYUSERPWD;
	INTEGER(ans)[i++] = CURLOPT_RANGE;
	INTEGER(ans)[i++] = CURLOPT_INFILE;
	INTEGER(ans)[i++] = CURLOPT_ERRORBUFFER;
	INTEGER(ans)[i++] = CURLOPT_WRITEFUNCTION;
	INTEGER(ans)[i++] = CURLOPT_READFUNCTION;
	INTEGER(ans)[i++] = CURLOPT_TIMEOUT;
	INTEGER(ans)[i++] = CURLOPT_INFILESIZE;
	INTEGER(ans)[i++] = CURLOPT_POSTFIELDS;
	INTEGER(ans)[i++] = CURLOPT_REFERER;
	INTEGER(ans)[i++] = CURLOPT_FTPPORT;
	INTEGER(ans)[i++] = CURLOPT_USERAGENT;
	INTEGER(ans)[i++] = CURLOPT_LOW_SPEED_LIMIT;
	INTEGER(ans)[i++] = CURLOPT_LOW_SPEED_TIME;
	INTEGER(ans)[i++] = CURLOPT_RESUME_FROM;
	INTEGER(ans)[i++] = CURLOPT_COOKIE;
	INTEGER(ans)[i++] = CURLOPT_COOKIE;
	INTEGER(ans)[i++] = CURLOPT_HTTPHEADER;
	INTEGER(ans)[i++] = CURLOPT_HTTPPOST;
	INTEGER(ans)[i++] = CURLOPT_SSLCERT;
		     
	INTEGER(ans)[i++] = CURLOPT_VERBOSE;
	INTEGER(ans)[i++] = CURLOPT_FOLLOWLOCATION;
		     
	INTEGER(ans)[i++] = CURLOPT_NETRC;
	INTEGER(ans)[i++] = CURLOPT_HTTPAUTH;
	INTEGER(ans)[i++] = CURLOPT_COOKIEFILE;

	INTEGER(ans)[i++] = CURLOPT_PASSWDFUNCTION;

	return(ans);
}
#endif

static const char *const VersionInfoFieldNames[] = 
  {"age", "version", "vesion_num", "host", "features", "ssl_version",
   "ssl_version_num", "libz_version", "protocols", "ares", "ares_num","libidn"
  };

SEXP
RCurlVersionInfoToR(const curl_version_info_data *d)
{
   SEXP ans, tmp;
   int n;
   n = sizeof(VersionInfoFieldNames)/sizeof(VersionInfoFieldNames[0]);

   PROTECT(ans = allocVector(VECSXP, n));
   SET_VECTOR_ELT(ans, 0, ScalarInteger(d->age));
   SET_VECTOR_ELT(ans, 1, mkString(d->version));
   SET_VECTOR_ELT(ans, 2, ScalarInteger(d->version_num));
   SET_VECTOR_ELT(ans, 3, mkString(d->host));
   SET_VECTOR_ELT(ans, 4, ScalarInteger(d->features)); 
   SET_VECTOR_ELT(ans, 5, mkString(d->ssl_version ? d->ssl_version : ""));
   SET_VECTOR_ELT(ans, 6, ScalarInteger(d->ssl_version_num));
   SET_VECTOR_ELT(ans, 7, mkString(d->libz_version));

   SET_VECTOR_ELT(ans, 8, getRStringsFromNullArray(d->protocols));

   SET_VECTOR_ELT(ans, 9, mkString(d->ares ? d->ares : ""));
   SET_VECTOR_ELT(ans, 10, ScalarInteger(d->ares_num));



#ifdef HAVE_LIBIDN_FIELD
   PROTECT(tmp = mkString(d->libidn ? d->libidn : ""));
#else
   PROTECT(tmp = allocVector(STRSXP, 1));
   SET_STRING_ELT(tmp, 0, R_NaString);
#endif

   SET_VECTOR_ELT(ans, 11, tmp);
   UNPROTECT(1);


   SET_NAMES(ans, RCreateNamesVec(VersionInfoFieldNames, n));

   UNPROTECT(1);
   return(ans);
}

SEXP
RCreateNamesVec(const char * const *vals,  int n)
{
	SEXP ans;
	int i;

	PROTECT(ans = allocVector(STRSXP, n));
	for(i = 0; i < n ; i++) {
	    SET_STRING_ELT(ans, i, mkChar(vals[i]));
	}

	UNPROTECT(1);
	return(ans);
}

SEXP
getRStringsFromNullArray(const char * const *d)  
{
  int i, n;
  const char  * const *p;
  SEXP ans;

  for(p = d, n = 0; *p; p++, n++) ;

  PROTECT(ans = allocVector(STRSXP, n));
  for(p = d, i = 0; i < n; i++, p++) {
	  SET_STRING_ELT(ans, i, mkChar(*p));
  }

  UNPROTECT(1);
  return(ans);
}






#if 0
char *DefaultURL = "http://www.omegahat.org/index.html";
void
R_test_curl(void)
{
	CURL *h;
	char **url = &DefaultURL;
	CURLcode status;


	h = curl_easy_init();
	status = curl_easy_setopt(h, CURLOPT_URL, NULL);
	if(status) {
		fprintf(stderr, "Expected error %d", status);fflush(stderr);
	}
	curl_easy_setopt(h, CURLOPT_URL, *url);
	curl_easy_perform(h);
}
#endif




void
R_check_bits(int *val, int *bits, int *ans, int *n)
{
	int i;
	for(i = 0; i < *n; i++) {
		ans[i] = *val & bits[i];
	}
}





SEXP
makeMultiCURLPointerRObject(CURLM *obj)
{
    SEXP ans, klass, ref;

	if(!obj) {
		PROBLEM "NULL CURL handle being returned"
		ERROR;
	}

	
	PROTECT(klass = MAKE_CLASS("MultiCURLHandle"));
	PROTECT(ans = NEW(klass));
	PROTECT(ref = R_MakeExternalPtr((void *) obj, Rf_install("MultiCURLHandle"), R_NilValue));
	
//Rprintf("registered finalizer for multi %p\n", obj);
	R_RegisterCFinalizer(ref, R_finalizeMultiCurlHandle);
	ans = SET_SLOT(ans, Rf_install("ref"), ref);
	
	UNPROTECT(3);

	return(ans);
} 


CURLM *
getMultiCURLPointerRObject(SEXP obj)
{
	CURLM *handle;
	SEXP ref;

	handle = (CURLM *) R_ExternalPtrAddr(ref = GET_SLOT(obj, Rf_install("ref")));
	if(!handle) {
		PROBLEM "Stale MultiCURL handle being passed to libcurl"
		ERROR;
	}

	if(R_ExternalPtrTag(ref) != Rf_install("MultiCURLHandle")) {
		PROBLEM "External pointer with wrong tag passed to libcurl (not MultiCURLHandle), but %s", 
                        CHAR(PRINTNAME(R_ExternalPtrTag(ref)))
		ERROR;
	}

	return(handle);
}


SEXP
R_getCurlMultiHandle()
{
    CURLM *h;
    h =  curl_multi_init();
    return(makeMultiCURLPointerRObject(h));
}


SEXP
R_pushCurlMultiHandle(SEXP m, SEXP curl)
{
    CURL *c;
    CURLM *h;
    CURLMcode status;
    c = getCURLPointerRObject(curl);
    h = getMultiCURLPointerRObject(m);

    status = curl_multi_add_handle(h, c);

    return(makeCURLcodeRObject(status));
}

SEXP
R_popCurlMultiHandle(SEXP m, SEXP curl)
{
    CURL *c;
    CURLM *h;
    CURLMcode status;
    c = getCURLPointerRObject(curl);
    h = getMultiCURLPointerRObject(m);

    status = curl_multi_remove_handle(h, c);

    return(makeCURLcodeRObject(status));    
}

SEXP
R_curlMultiPerform(SEXP m, SEXP repeat)
{
    CURLM *h;
    CURLMcode status;
    int n;
    SEXP ans;

    fd_set read_fd_set,  write_fd_set, exc_fd_set;
    int max_fd = 0;
    int ctr = 0;

    h = getMultiCURLPointerRObject(m);

    do {
      int state;
      if(ctr > 0)  {

	FD_ZERO(&read_fd_set);
	FD_ZERO(&write_fd_set);
	FD_ZERO(&exc_fd_set);
	max_fd = 0;

	state = curl_multi_fdset(h, 
                                 &read_fd_set,
				 &write_fd_set,
				 &exc_fd_set,
				 &max_fd);

        if(state != CURLM_OK /* || max_fd == -1 */) {
           PROBLEM "curl_multi_fdset"
           ERROR;
	}

	if(max_fd != -1) {
	    state = select(max_fd+1, &read_fd_set, &write_fd_set, &exc_fd_set, NULL /* &tm */);
#if 0
            fprintf(stderr, "<select> %d state = %d, max_fd = %d\n", ctr, state, max_fd);
#endif
 	}
      }

     do {
         status = curl_multi_perform(h, &n);
         if(n <= 0)
 	    break;
#if 0
          fprintf(stderr, "status %d, num running %d\n", status, n);
#endif
          ctr ++;
      } while(LOGICAL(repeat)[0] && status == CURLM_CALL_MULTI_PERFORM);

    } while(LOGICAL(repeat)[0] && n > 0);

 
    PROTECT(ans = allocVector(VECSXP, 2));
    SET_VECTOR_ELT(ans, 0, makeCURLcodeRObject(status));
    SET_VECTOR_ELT(ans, 1, ScalarInteger(n));
    UNPROTECT(1);

    return(ans);
}


/*
 Test routine that we can pass to (R code)
     curlPerform(....,  writefunction = getNativeSymbolInfo("R_internalWriteTest")$address)
  to have this routine be called when there is data on the HTTP response.
*/
size_t 
R_internalWriteTest(void *buffer, size_t size, size_t nmemb, void *data)
{
    Rprintf("<R_internalWrite> size = %d, nmemb = %d\n", (int) size, (int) nmemb);
    return(size * nmemb);
}




CURLcode 
R_curl_ssl_ctx_callback(CURL *curl, void *sslctx, void *parm)
{
  SEXP fun = (SEXP) parm;
  SEXP e, ctx, ans;
  CURLcode status;

  PROTECT(e = allocVector(LANGSXP, 3));

  SETCAR(e, fun);
  SETCAR(CDR(e), makeCURLPointerRObject(curl, FALSE));

  PROTECT(ctx=  R_MakeExternalPtr(sslctx, Rf_install("SSL_CTX"), R_NilValue));
  SET_CLASS(ctx, mkString("SSL_CTX"));

  SETCAR(CDR(CDR(e)), ctx);

  ans = eval(e, R_GlobalEnv);

  status = asInteger(ans);

  UNPROTECT(2);

  return(status);
}


#if 0
/*XXX not working
   need to be able to get at cookies but these are in an opaque data type.
 */
SEXP
R_get_Cookies(SEXP handle, SEXP fileName)
{
   CURL *obj = getCURLPointerRObject(handle);
   int status;
   status = Curl_cookie_output(obj->cookies,  CHAR(STRING_ELT(fileName, 0)));

   return(Rf_ScalarLogical(status));
}
#endif




SEXP
R_global_releaseObject(SEXP obj)
{
#if RCURL_DEBUG_MEMORY
    REprintf(stderr, "releasing %p\n", obj);
#endif
    Rf_PrintValue(obj);
    R_ReleaseObject(obj);
    return(R_NilValue);
}


#if 0

#include <R_ext/Riconv.h>

SEXP makeUTF8String(void *buffer, size_t len, cetype_t encoding)
{
#if 0
    void *iconv;
    iconv = Riconv_open("UTF-8", "C99");
    Riconv(iconv, (const char **) buffer);
#else

    SEXP e, str;
    PROTECT(e = allocVector(LANGSXP, 4));
    SETCAR(e, Rf_install("RCurlIconv"));
    SETCAR(CDR(e), str = ScalarString(mkCharLen(buffer, len)));
//Rf_PrintValue(str);
    SETCAR(CDR(CDR(e)), ScalarString(mkChar("C99")));
    SETCAR(CDR(CDR(CDR(e))), ScalarString(mkChar("UTF-8")));
   
    SEXP ans = Rf_eval(e, R_GlobalEnv);
    UNPROTECT(1);
//Rf_PrintValue(ans);
    return(ans);
#endif
}
#endif


int
R_seek(void *instream, curl_off_t offset, int origin)
{
    int status;
    status = fseek((FILE *) instream, (long int) offset, origin);
    /* check status */
    return(0);
}
