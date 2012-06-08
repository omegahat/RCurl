curl:

CURL_CONFIG=curl-config

CFLAGS=$(shell $(CURL_CONFIG) --cflags)
LIBS=$(shell $(CURL_CONFIG) --libs)

curl: curl.o
	$(CC) -o $@ curl.o $(LIBS)

post: post.o
	$(CC) -o $@ $^ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<


XSL_HTML_STYLE_FILE=$(OMEGA_HOME)/Docs/XSL/Rexample.xsl
ifndef XSLTPROC
XSLTPROC=xsltproc
endif
# %.html: %.xml $(OMEGA_HOME)/Docs/XSL/Rexample.xsl
#	$(XSLTPROC) $(XSLT_FLAGS) --output $@ $(XSL_HTML_STYLE_FILE) $< 

ifndef DYN_DOCS
 DYN_DOCS=$(HOME)/Classes/StatComputing/XDynDocs/inst
endif

include $(DYN_DOCS)/Make/Makefile



