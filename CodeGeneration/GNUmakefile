../inst/enums/Renums.c:

-include local.config

ifndef CURL_CONFIG
  CURL_CONFIG= curl-config
endif

CFLAGS=$(shell $(CURL_CONFIG) --cflags)

CC=gcc

%.tu:	%.c
	$(CC) -o /dev/null -c -fdump-translation-unit $(CFLAGS) $<

../inst/enums/Renums.c: enum.tu
	R --no-save < generate.R
