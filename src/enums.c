#include <curl/curl.h>
#include <Rdefines.h>

typedef struct {
  char name[40];
  int val;
} NameValue;

NameValue CurlErrorNames[] = {

 {"OK",			   CURLE_OK},
 {"UNSUPPORTED_PROTOCOL",      CURLE_UNSUPPORTED_PROTOCOL},    
 {"FAILED_INIT",               CURLE_FAILED_INIT},             
 {"URL_MALFORMAT",             CURLE_URL_MALFORMAT},           
 {"URL_MALFORMAT_USER",        CURLE_URL_MALFORMAT_USER},      
 {"COULDNT_RESOLVE_PROXY",     CURLE_COULDNT_RESOLVE_PROXY},   
 {"COULDNT_RESOLVE_HOST",      CURLE_COULDNT_RESOLVE_HOST},    
 {"COULDNT_CONNECT",           CURLE_COULDNT_CONNECT},         
 {"FTP_WEIRD_SERVER_REPLY",    CURLE_FTP_WEIRD_SERVER_REPLY},  
 {"FTP_ACCESS_DENIED",         CURLE_FTP_ACCESS_DENIED},       
 {"FTP_USER_PASSWORD_INCORRECT",  CURLE_FTP_USER_PASSWORD_INCORRECT}, 
 {"FTP_WEIRD_PASS_REPLY",      CURLE_FTP_WEIRD_PASS_REPLY},    
 {"FTP_WEIRD_USER_REPLY",      CURLE_FTP_WEIRD_USER_REPLY},    
 {"FTP_WEIRD_PASV_REPLY",      CURLE_FTP_WEIRD_PASV_REPLY},    
 {"FTP_WEIRD_227_FORMAT",      CURLE_FTP_WEIRD_227_FORMAT},    
 {"FTP_CANT_GET_HOST",         CURLE_FTP_CANT_GET_HOST},       
 {"FTP_CANT_RECONNECT",        CURLE_FTP_CANT_RECONNECT},      
 {"FTP_COULDNT_SET_BINARY",    CURLE_FTP_COULDNT_SET_BINARY},  
 {"PARTIAL_FILE",              CURLE_PARTIAL_FILE},            
 {"FTP_COULDNT_RETR_FILE",     CURLE_FTP_COULDNT_RETR_FILE},   
 {"FTP_WRITE_ERROR",           CURLE_FTP_WRITE_ERROR},         
 {"FTP_QUOTE_ERROR",           CURLE_FTP_QUOTE_ERROR},         
 {"HTTP_RETURNED_ERROR",       CURLE_HTTP_RETURNED_ERROR},     
 {"WRITE_ERROR",               CURLE_WRITE_ERROR},             
 {"MALFORMAT_USER",            CURLE_MALFORMAT_USER},          
 {"FTP_COULDNT_STOR_FILE",     CURLE_FTP_COULDNT_STOR_FILE},   
 {"READ_ERROR",                CURLE_READ_ERROR},              
 {"OUT_OF_MEMORY",             CURLE_OUT_OF_MEMORY},           
 {"OPERATION_TIMEOUTED",       CURLE_OPERATION_TIMEOUTED},     
 {"FTP_COULDNT_SET_ASCII",     CURLE_FTP_COULDNT_SET_ASCII},   
 {"FTP_PORT_FAILED",           CURLE_FTP_PORT_FAILED},         
 {"FTP_COULDNT_USE_REST",      CURLE_FTP_COULDNT_USE_REST},    
 {"FTP_COULDNT_GET_SIZE",      CURLE_FTP_COULDNT_GET_SIZE},    
 {"HTTP_RANGE_ERROR",          CURLE_HTTP_RANGE_ERROR},        
 {"HTTP_POST_ERROR",           CURLE_HTTP_POST_ERROR},         
 {"SSL_CONNECT_ERROR",         CURLE_SSL_CONNECT_ERROR},       
 {"BAD_DOWNLOAD_RESUME",       CURLE_BAD_DOWNLOAD_RESUME},     
 {"FILE_COULDNT_READ_FILE",    CURLE_FILE_COULDNT_READ_FILE},  
 {"LDAP_CANNOT_BIND",          CURLE_LDAP_CANNOT_BIND},        
 {"LDAP_SEARCH_FAILED",        CURLE_LDAP_SEARCH_FAILED},      
 {"LIBRARY_NOT_FOUND",         CURLE_LIBRARY_NOT_FOUND},       
 {"FUNCTION_NOT_FOUND",        CURLE_FUNCTION_NOT_FOUND},      
 {"ABORTED_BY_CALLBACK",       CURLE_ABORTED_BY_CALLBACK},     
 {"BAD_FUNCTION_ARGUMENT",     CURLE_BAD_FUNCTION_ARGUMENT},   
 {"BAD_CALLING_ORDER",         CURLE_BAD_CALLING_ORDER},       
 {"INTERFACE_FAILED",          CURLE_HTTP_PORT_FAILED/*This is really CURLE_INTERFACE_FAILED in the newer versions. */},        
 {"BAD_PASSWORD_ENTERED",      CURLE_BAD_PASSWORD_ENTERED},    
 {"TOO_MANY_REDIRECTS ",       CURLE_TOO_MANY_REDIRECTS },     
 {"UNKNOWN_TELNET_OPTION",     CURLE_UNKNOWN_TELNET_OPTION},   
 {"TELNET_OPTION_SYNTAX ",     CURLE_TELNET_OPTION_SYNTAX },   
 {"OBSOLETE",	           CURLE_OBSOLETE},	         
 {"SSL_PEER_CERTIFICATE",      CURLE_SSL_PEER_CERTIFICATE},    
 {"GOT_NOTHING",               CURLE_GOT_NOTHING},             
 {"SSL_ENGINE_NOTFOUND",       CURLE_SSL_ENGINE_NOTFOUND},     
 {"SSL_ENGINE_SETFAILED",      CURLE_SSL_ENGINE_SETFAILED},    

 {"SEND_ERROR",                CURLE_SEND_ERROR},              
 {"RECV_ERROR",                CURLE_RECV_ERROR},              
 {"SHARE_IN_USE",              CURLE_SHARE_IN_USE},            
 {"SSL_CERTPROBLEM",           CURLE_SSL_CERTPROBLEM},         
 {"SSL_CIPHER",                CURLE_SSL_CIPHER},              
 {"SSL_CACERT",                CURLE_SSL_CACERT},              
 {"BAD_CONTENT_ENCODING",      CURLE_BAD_CONTENT_ENCODING},    
 {"LDAP_INVALID_URL",          CURLE_LDAP_INVALID_URL},        
 {"FILESIZE_EXCEEDED",         CURLE_FILESIZE_EXCEEDED},       
 {"FTP_SSL_FAILED",            CURLE_FTP_SSL_FAILED}
};          

#include "CurlOptEnums.h"
#include "CurlInfoEnums.h"


SEXP
createNamedEnum(NameValue *Els, int n)
{
	int i;
	SEXP ans, names;
	PROTECT(ans = allocVector(INTSXP, n));
	PROTECT(names = allocVector(STRSXP, n));

	for(i = 0; i < n ; i++) {
		INTEGER(ans)[i] = Els[i].val;
		SET_STRING_ELT(names, i, mkChar(Els[i].name));
	}
	SET_NAMES(ans, names);
	UNPROTECT(2);
	return(ans);
}

SEXP
R_getCURLOptionEnum(void)
{
  return(createNamedEnum(CurlOptionNames, sizeof(CurlOptionNames)/sizeof(CurlOptionNames[0])));
}

SEXP
R_getCURLInfoEnum(void)
{
  return(createNamedEnum(CurlInfoNames, sizeof(CurlInfoNames)/sizeof(CurlInfoNames[0])));
}

SEXP
R_getCURLErrorEnum(void)
{
  return(createNamedEnum(CurlErrorNames, sizeof(CurlErrorNames)/sizeof(CurlErrorNames[0])));
}

