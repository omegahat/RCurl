/*
  This code is adapted from Alex Couture-Beil's <rjson_pkg@mofo.ca>
  rjson package.  It converts strings containing Unicode of the form 
  \u<4 hex characters> to R's format, i.e. by mapping them to 
  1, 2, 3 or 4 bytes.

  This is adapted so that it can be used independently of a JSON string
  and just converts an arbitrary character.

  It is distributed under the GPL-2 license.
 */

#if 0
static int x;
#else
#include <Rdefines.h>
#include <Rinternals.h>

#include <stdlib.h>

#define         MASKBITS                0x3F
#define         MASKBYTE                0x80
#define         MASK2BYTES              0xC0
#define         MASK3BYTES              0xE0



int UTF8Encode2BytesUnicode( unsigned short input, char * s )
{
	// 0xxxxxxx
	if( input < 0x80 )
	{
		s[ 0 ] = input;
		return 1;
	}
	// 110xxxxx 10xxxxxx
	else if( input < 0x800 )
	{
		s[ 0 ] = (MASK2BYTES | ( input >> 6 ) );
		s[ 1 ] = (MASKBYTE | ( input & MASKBITS ) );
		return 2;
	}
	// 1110xxxx 10xxxxxx 10xxxxxx
	else if( input < 0x10000 )
	{
		s[ 0 ] = (MASK3BYTES | ( input >> 12 ) );
		s[ 1 ] = (MASKBYTE | ( ( input >> 6 ) & MASKBITS ) );
		s[ 2 ] = (MASKBYTE | ( input & MASKBITS ) );
		return 3;
	}
}


SEXP mapString(const char *s, char *buf, size_t bufLen)
{
	int i = 0; 
	int nchar = strlen(s);
	buf[0] = '\0';
	char *cur = buf;

	while( i < nchar ) {
	    while(i < nchar && s[ i ] != '\\' && s[ i ] != '\0') {
		cur[0] = s[i];
		i++; cur++;
	    }

	    if(s[i] == '\0')
		break;

	    if( s[ i ] == '\\' ) {
		i++;
		switch( s[ i ] ) {
		case '"':
		    cur[0] = '\\';
		    cur[1] = '"';
		    cur+=2;
		    break;
		case '\\':
		case '/':
		    cur[ 0 ] = s[ i ];
		    cur++;
		    break;
		case 'r':
		    cur[0] = '\r'; cur++;
		    break;
		case 'n':
		    cur[0] = '\n'; cur++;
		    break;
		case 'b':
		    cur[0] = '\b'; cur++;
		    break;
		case 't':
		    cur[0] = '\t'; cur++;
		    break;
		case 'f':
		    cur[0] = '\f'; cur++;
		    break;
		case 'u':
		    for( int j = 1; j <= 4; j++ )
			if( ( ( s[ i + j ] >= 'a' && s[ i + j ] <= 'f' ) || 
			      ( s[ i + j ] >= 'A' && s[ i + j ] <= 'F' ) ||
			      ( s[ i + j ] >= '0' && s[ i + j ] <= '9' ) ) == FALSE ) {
			    PROBLEM "unexpected unicode escaped char '%c'; 4 hex digits should follow the \\u (found %i valid digits)", s[ i + j ], j - 1 
				ERROR;
			}

		    unsigned short unicode;
		    char unicode_buf[ 5 ]; /* to hold 4 digit hex (to prevent scanning a 5th digit accidentally */
		    strncpy( unicode_buf, s + i + 1, 5 );
		    unicode_buf[ 4 ] = '\0';
		    sscanf( unicode_buf, "%hx", &unicode);
		    cur += UTF8Encode2BytesUnicode( unicode, cur);

		    i += 4; /* skip the four digits - actually point to last digit, which is then incremented outside of switch */
		    
		    break;
		default:
		    cur[ 0 ] = s[ i ];
		    cur++;
		    break;		    
/*
		    PROBLEM  "unexpected escaped character '\\%c' at position %d", s[ i ], i + 1
			ERROR;
*/
		    break;
		}

		i++; /* move to next char */
	    }
	}
	cur[0] = '\0';
	

	return(mkCharCE( buf, CE_UTF8 ));
}



SEXP R_mapString(SEXP str, SEXP suggestedLen)
{
    int numEls = Rf_length(str);
    SEXP ans;
    PROTECT(ans = NEW_CHARACTER(numEls));
    for(int i = 0; i < numEls; i++) {

	int num;
	if(Rf_length(suggestedLen))
	    num = INTEGER(suggestedLen)[i];
	else
	    num = 4 * strlen(CHAR(STRING_ELT(str, i)));

	char * buf = (char *) R_alloc(num, sizeof(char));
	if(!buf) {
	    PROBLEM "can't allocate memory for working buffer"
		ERROR;
	}

	SET_STRING_ELT(ans, i, mapString(CHAR(STRING_ELT(str, i)), buf, INTEGER(suggestedLen)[i]));
    }

    UNPROTECT(1);
    return(ans);
}

#endif


