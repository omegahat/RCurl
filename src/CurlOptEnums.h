#ifdef CINIT
#undef CINIT
#endif

#define CINIT(a,b,c) {#a, CURLOPT_##a}

NameValue CurlOptionNames[] = {

#if 1
#include "CURLOptTable.h"
#else
  CINIT(FILE, OBJECTPOINT, 1),
  CINIT(URL,  OBJECTPOINT, 2),
  CINIT(PORT, LONG, 3),
  CINIT(PROXY, OBJECTPOINT, 4),
  CINIT(USERPWD, OBJECTPOINT, 5),
  CINIT(PROXYUSERPWD, OBJECTPOINT, 6),
  CINIT(RANGE, OBJECTPOINT, 7),
  CINIT(INFILE, OBJECTPOINT, 9),
  CINIT(ERRORBUFFER, OBJECTPOINT, 10),
  CINIT(WRITEFUNCTION, FUNCTIONPOINT, 11),
  CINIT(READFUNCTION, FUNCTIONPOINT, 12),
  CINIT(TIMEOUT, LONG, 13),
  CINIT(INFILESIZE, LONG, 14),
  CINIT(POSTFIELDS, OBJECTPOINT, 15),
  CINIT(REFERER, OBJECTPOINT, 16),
  CINIT(FTPPORT, OBJECTPOINT, 17),
  CINIT(USERAGENT, OBJECTPOINT, 18),
  CINIT(LOW_SPEED_LIMIT, LONG , 19),
  CINIT(LOW_SPEED_TIME, LONG, 20),
  CINIT(RESUME_FROM, LONG, 21),
  CINIT(COOKIE, OBJECTPOINT, 22),
  CINIT(HTTPHEADER, OBJECTPOINT, 23),
  CINIT(HTTPPOST, OBJECTPOINT, 24),
  CINIT(SSLCERT, OBJECTPOINT, 25),
  CINIT(SSLCERTPASSWD, OBJECTPOINT, 26),
  CINIT(SSLKEYPASSWD, OBJECTPOINT, 26),
  CINIT(CRLF, LONG, 27),
  CINIT(QUOTE, OBJECTPOINT, 28),
  CINIT(WRITEHEADER, OBJECTPOINT, 29),
  CINIT(COOKIEFILE, OBJECTPOINT, 31),
  CINIT(SSLVERSION, LONG, 32),
  CINIT(TIMECONDITION, LONG, 33),
  CINIT(TIMEVALUE, LONG, 34),
  CINIT(CUSTOMREQUEST, OBJECTPOINT, 36),
  CINIT(STDERR, OBJECTPOINT, 37),
  CINIT(POSTQUOTE, OBJECTPOINT, 39),
  CINIT(WRITEINFO, OBJECTPOINT, 40),
  CINIT(VERBOSE, LONG, 41),      /* talk a lot */
  CINIT(HEADER, LONG, 42),       /* throw the header out too */
  CINIT(NOPROGRESS, LONG, 43),   /* shut off the progress meter */
  CINIT(NOBODY, LONG, 44),       /* use HEAD to get http document */
  CINIT(FAILONERROR, LONG, 45),  /* no output on http error codes >= 300 */
  CINIT(UPLOAD, LONG, 46),       /* this is an upload */
  CINIT(POST, LONG, 47),         /* HTTP POST method */
  CINIT(FTPLISTONLY, LONG, 48),  /* Use NLST when listing ftp dir */
  CINIT(FTPAPPEND, LONG, 50),    /* Append instead of overwrite on upload! */

  CINIT(NETRC, LONG, 51),
  CINIT(FOLLOWLOCATION, LONG, 52),  /* use Location: Luke! */
  CINIT(TRANSFERTEXT, LONG, 53), /* transfer data in text/ASCII format */
  CINIT(PUT, LONG, 54),          /* PUT the input file */
  CINIT(PROGRESSFUNCTION, FUNCTIONPOINT, 56),
  CINIT(PROGRESSDATA, OBJECTPOINT, 57),
  CINIT(AUTOREFERER, LONG, 58),
  CINIT(PROXYPORT, LONG, 59),
  CINIT(POSTFIELDSIZE, LONG, 60),
  CINIT(HTTPPROXYTUNNEL, LONG, 61),
  CINIT(INTERFACE, OBJECTPOINT, 62),
  CINIT(KRB4LEVEL, OBJECTPOINT, 63),
  CINIT(SSL_VERIFYPEER, LONG, 64),
  CINIT(CAINFO, OBJECTPOINT, 65),
  CINIT(MAXREDIRS, LONG, 68),
  CINIT(FILETIME, OBJECTPOINT, 69),
  CINIT(TELNETOPTIONS, OBJECTPOINT, 70),
  CINIT(MAXCONNECTS, LONG, 71),
  CINIT(CLOSEPOLICY, LONG, 72),
  CINIT(FRESH_CONNECT, LONG, 74),

  /* Set to explicitly forbid the upcoming transfer's connection to be re-used
     when done. Do not use this unless you're absolutely sure of this, as it
     makes the operation slower and is less friendly for the network. */
  CINIT(FORBID_REUSE, LONG, 75),

  /* Set to a file name that contains random data for libcurl to use to
     seed the random engine when doing SSL connects. */
  CINIT(RANDOM_FILE, OBJECTPOINT, 76),

  /* Set to the Entropy Gathering Daemon socket pathname */
  CINIT(EGDSOCKET, OBJECTPOINT, 77),

  /* Time-out connect operations after this amount of seconds, if connects
     are OK within this time, then fine... This only aborts the connect
     phase. [Only works on unix-style/SIGALRM operating systems] */
  CINIT(CONNECTTIMEOUT, LONG, 78),

  /* Function that will be called to store headers (instead of fwrite). The
   * parameters will use fwrite() syntax, make sure to follow them. */
  CINIT(HEADERFUNCTION, FUNCTIONPOINT, 79),

  /* Set this to force the HTTP request to get back to GET. Only really usable
     if POST, PUT or a custom request have been used first.
   */
  CINIT(HTTPGET, LONG, 80),

  /* Set if we should verify the Common name from the peer certificate in ssl
   * handshake, set 1 to check existence, 2 to ensure that it matches the
   * provided hostname. */
  CINIT(SSL_VERIFYHOST, LONG, 81),

  /* Specify which file name to write all known cookies in after completed
     operation. Set file name to "-" (dash) to make it go to stdout. */
  CINIT(COOKIEJAR, OBJECTPOINT, 82),

  /* Specify which SSL ciphers to use */
  CINIT(SSL_CIPHER_LIST, OBJECTPOINT, 83),

  /* Specify which HTTP version to use! This must be set to one of the
     CURL_HTTP_VERSION* enums set below. */
  CINIT(HTTP_VERSION, LONG, 84),

  /* Specificly switch on or off the FTP engine's use of the EPSV command. By
     default, that one will always be attempted before the more traditional
     PASV command. */
  CINIT(FTP_USE_EPSV, LONG, 85),

  /* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") */
  CINIT(SSLCERTTYPE, OBJECTPOINT, 86),

  /* name of the file keeping your private SSL-key */
  CINIT(SSLKEY, OBJECTPOINT, 87),

  /* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") */
  CINIT(SSLKEYTYPE, OBJECTPOINT, 88),

  /* crypto engine for the SSL-sub system */
  CINIT(SSLENGINE, OBJECTPOINT, 89),

  /* set the crypto engine for the SSL-sub system as default
     the param has no meaning...
   */
  CINIT(SSLENGINE_DEFAULT, LONG, 90),

  /* Non-zero value means to use the global dns cache */
  CINIT(DNS_USE_GLOBAL_CACHE, LONG, 91), /* To become OBSOLETE soon */

  /* DNS cache timeout */
  CINIT(DNS_CACHE_TIMEOUT, LONG, 92),

  /* send linked-list of pre-transfer QUOTE commands (Wesley Laxton)*/
  CINIT(PREQUOTE, OBJECTPOINT, 93),

  /* set the debug function */
  CINIT(DEBUGFUNCTION, FUNCTIONPOINT, 94),

  /* set the data for the debug function */
  CINIT(DEBUGDATA, OBJECTPOINT, 95),

  /* mark this as start of a cookie session */
  CINIT(COOKIESESSION, LONG, 96),

  /* The CApath directory used to validate the peer certificate
     this option is used only if SSL_VERIFYPEER is true */
  CINIT(CAPATH, OBJECTPOINT, 97),

  /* Instruct libcurl to use a smaller receive buffer */
  CINIT(BUFFERSIZE, LONG, 98),

  /* Instruct libcurl to not use any signal/alarm handlers, even when using
     timeouts. This option is useful for multi-threaded applications.
     See libcurl-the-guide for more background information. */
  CINIT(NOSIGNAL, LONG, 99),

  /* Provide a CURLShare for mutexing non-ts data */
  CINIT(SHARE, OBJECTPOINT, 100),

  /* indicates type of proxy. accepted values are CURLPROXY_HTTP (default),
     CURLPROXY_SOCKS4 and CURLPROXY_SOCKS5. */
  CINIT(PROXYTYPE, LONG, 101),

  /* Set the Accept-Encoding string. Use this to tell a server you would like
     the response to be compressed. */
  CINIT(ENCODING, OBJECTPOINT, 102),

  /* Set pointer to private data */
  CINIT(PRIVATE, OBJECTPOINT, 103),

  /* Set aliases for HTTP 200 in the HTTP Response header */
  CINIT(HTTP200ALIASES, OBJECTPOINT, 104),

  /* Continue to send authentication (user+password) when following locations,
     even when hostname changed. This can potentionally send off the name
     and password to whatever host the server decides. */
  CINIT(UNRESTRICTED_AUTH, LONG, 105),

  /* Specificly switch on or off the FTP engine's use of the EPRT command ( it
     also disables the LPRT attempt). By default, those ones will always be
     attempted before the good old traditional PORT command. */
  CINIT(FTP_USE_EPRT, LONG, 106),

  /* Set this to a bitmask value to enable the particular authentications
     methods you like. Use this in combination with CURLOPT_USERPWD.
     Note that setting multiple bits may cause extra network round-trips. */
  CINIT(HTTPAUTH, LONG, 107),

  /* Set the ssl context callback function, currently only for OpenSSL ssl_ctx
     in second argument. The function must be matching the
     curl_ssl_ctx_callback proto. */
  CINIT(SSL_CTX_FUNCTION, FUNCTIONPOINT, 108),

  /* Set the userdata for the ssl context callback function's third
     argument */
  CINIT(SSL_CTX_DATA, OBJECTPOINT, 109),

  /* FTP Option that causes missing dirs to be created on the remote server */
  CINIT(FTP_CREATE_MISSING_DIRS, LONG, 110),

  /* Set this to a bitmask value to enable the particular authentications
     methods you like. Use this in combination with CURLOPT_PROXYUSERPWD.
     Note that setting multiple bits may cause extra network round-trips. */
  CINIT(PROXYAUTH, LONG, 111),

  /* FTP option that changes the timeout, in seconds, associated with
     getting a response.  This is different from transfer timeout time and
     essentially places a demand on the FTP server to acknowledge commands
     in a timely manner. */
  CINIT(FTP_RESPONSE_TIMEOUT, LONG , 112),

  /* Set this option to one of the CURL_IPRESOLVE_* defines (see below) to
     tell libcurl to resolve names to those IP versions only. This only has
     affect on systems with support for more than one, i.e IPv4 _and_ IPv6. */
  CINIT(IPRESOLVE, LONG, 113),

  /* Set this option to limit the size of a file that will be downloaded from
     an HTTP or FTP server.

     Note there is also _LARGE version which adds large file support for
     platforms which have larger off_t sizes.  See MAXFILESIZE_LARGE below. */
  CINIT(MAXFILESIZE, LONG, 114),
  CINIT(INFILESIZE_LARGE, OFF_T, 115),
  CINIT(RESUME_FROM_LARGE, OFF_T, 116),
  CINIT(MAXFILESIZE_LARGE, OFF_T, 117),
  CINIT(NETRC_FILE, OBJECTPOINT, 118),
  CINIT(FTP_SSL, LONG, 119),
  CINIT(POSTFIELDSIZE_LARGE, OFF_T, 120),
  CINIT(TCP_NODELAY, LONG, 121),

    /* Collect certificate chain info and allow it to get retrievable with
     CURLINFO_CERTINFO after the transfer is complete. (Unfortunately) only
     working with OpenSSL-powered builds. */
  CINIT(CERTINFO, LONG, 172),
#endif
};
