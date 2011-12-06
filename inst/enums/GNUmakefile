ifndef CURL_CONFIG
  CURL_CONFIG= curl-config
endif

CFLAGS=$(shell $(CURL_CONFIG) --cflags --libs)
CC=gcc

Renums:	Renums.c
	$(CC) -o $@  $(CFLAGS) $<

