#ifndef R_CURL_H
#define R_CURL_H

#include <curl/curl.h>
#include <curl/easy.h>
#include <Rdefines.h>

/*
#define RCURL_DEBUG_MEMORY 1
*/

typedef enum {VOID_TYPE, R_OBJECT} RCurl_OptValueType;

typedef struct _RCurlMemory  RCurlMemory;

struct _RCurlMemory {

	CURL *curl;         /* the CURL object for which this data was allocated.*/
	const void *data;   /* the data */
	CURLoption option;  /* the option, so we can tell what it was for.*/
	
	RCurl_OptValueType type;

	RCurlMemory *next;
};

typedef struct _CURLOptionMemoryManager CURLOptionMemoryManager;

struct _CURLOptionMemoryManager {
	CURL *curl;
	RCurlMemory *top;

	int numTickets; /* Number of entries in the top. Used for debugging here. */

	CURLOptionMemoryManager *next;
	CURLOptionMemoryManager *last;
};

RCurlMemory *RCurl_addMemoryAllocation(CURLoption, const void *, CURL *);
CURLOptionMemoryManager *RCurl_addMemoryTicket(RCurlMemory *);
void RCurl_releaseMemoryTickets(CURL *curl);
CURLOptionMemoryManager* RCurl_getMemoryManager(CURL *curl);

void RCurl_releaseManagerMemoryTickets(CURLOptionMemoryManager *mgr);



typedef struct {
 SEXP fun;
 SEXP headerFun;	
 cetype_t encoding;
 int encodingSetByUser;
 int nobody;
} RWriteDataInfo;


SEXP R_curl_easy_setopt(SEXP handle, SEXP values, SEXP opts, SEXP isProtected, SEXP encoding);
SEXP R_curl_easy_init(void);
SEXP R_curl_easy_duphandle(SEXP);
SEXP R_curl_global_cleanup();
SEXP R_curl_global_init(SEXP);
SEXP R_curl_version_info(SEXP flag);
SEXP R_curl_easy_perform(SEXP handle, SEXP opts, SEXP isProtected, SEXP encoding);
SEXP R_curl_easy_getinfo(SEXP handle, SEXP which);
SEXP R_curl_escape(SEXP vals, SEXP escape);
SEXP R_post_form(SEXP handle, SEXP opts, SEXP params, SEXP isProtected, SEXP style);

SEXP R_getCURLErrorEnum(void);
SEXP R_getCURLInfoEnum(void);
SEXP R_getCURLOptionEnum(void);


#ifdef USE_LOCAL_BAS64_ENCODING
/* This is going away and we will use the version on*/
extern size_t Curl_base64_decode(const char *src, unsigned char **outptr);
extern size_t Curl_base64_encode(const char *inp, size_t insize, char **outptr);
#endif

size_t R_Curl_base64_decode(const char *src, unsigned char **outptr);
size_t R_Curl_base64_encode(const char *inp, size_t insize, char **outptr);


SEXP R_curl_easy_reset(SEXP handle);

#endif
