DOC_DIR=inst/doc/
DOCS=philosophy.html
# philosophy.pdf
DOC_FILES=$(DOCS:%=$(DOC_DIR)/%)

ifdef R_HOME
 R=$(R_HOME)/bin/R
endif

VERSION=$(shell perl -e 'while(<>) { if(m/Version: (.*)/) {print $$1,"\n";}}' DESCRIPTION)

configure: configure.in
	autoconf

build: configure $(DOC_FILES)
	(cd ..  ; $(R) CMD build RCurl )


ship: build
	scp ../RCurl_$(VERSION).tar.gz www.omegahat.org:/home3/WebSites/Omega/RCurl/


version:
	@echo "$(VERSION)"



docs: $(DOC_FILES)

check: configure
	R CMD check .

install: configure
	R CMD INSTALL .


$(DOC_DIR)/philosophy.html: $(DOC_DIR)/philosophy.xml

%.html: %.xml
	$(MAKE) -C $(@D) $(@F)

