philosophy.html:

# HOME=D:/cygwin/home/duncan

XSLTPROC=xsltproc
XSL_FILE=$(HOME)/Projects/org/omegahat/Docs/XSL/article.xsl
#XSL_FILE=$(HOME)/docbook-xsl-1.65.1/html/docbook.xsl $(HOME)/Projects/org/omegahat/Docs/XSL/SLanguage.xsl $(HOME)/Projects/org/omegahat/Docs/XSL/html.xsl
XSL_FILE=$(OMEGA_HOME)/Docs/XSL/myarticle.xsl

XSLT_PARAMS=-param "html.stylesheet" '"http://www.omegahat.org/OmegaTech.css"' 

# For controlling indentation in the output. Use the <xsl:output indent="yes"> instead
# -param chunker.output.indent "'yes'"

XSLT_OPTS=--nonet --xinclude 

# -v

#%.html: %.xml GNUmakefile $(XSL_FILE)
#	$(XSLTPROC) -o $@ $(XSLT_OPTS) $(XSLT_PARAMS) $(XSL_FILE) $<


WEB_SITE=www.omegahat.org:/home3/WebSites/Omega/RCurl

.PHONY:	 ship

ship: philosophy.html
	scp $^ $(WEB_SITE)

include $(DYN_DOCS)/inst/Make/Makefile
