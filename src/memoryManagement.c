#include "Rcurl.h"

#include <stdlib.h>

CURLOptionMemoryManager *OptionMemoryManager = NULL;


#ifdef RCURL_DEBUG_MEMORY
struct {
	int handleCount;
	int ticketAddCount;
	int ticketReleaseCount;
} RCurlMemoryDiagnostics;
#endif



RCurlMemory *
RCurl_addMemoryAllocation(CURLoption opt, const void *data, CURL *curl)
{
	RCurlMemory *el;
	el = (RCurlMemory *) malloc(sizeof(RCurlMemory));
	if(!el) {
		PROBLEM "Can't allocate space for RCurlMemory structure."
		ERROR;
	}
	el->data = data;
	el->option = opt;
	el->type = VOID_TYPE;
	el->curl = curl;
	el->next = NULL;

	RCurl_addMemoryTicket(el);

	return(el);
}

CURLOptionMemoryManager *
RCurl_addMemoryTicket(RCurlMemory *el)
{
	CURLOptionMemoryManager *ptr;
	ptr = RCurl_getMemoryManager(el->curl);

	if(!ptr) {
	    ptr = (CURLOptionMemoryManager *) malloc(sizeof(CURLOptionMemoryManager));
	    ptr->curl = el->curl;
	    ptr->top = NULL;

	    ptr->last = NULL;
	    ptr->next = OptionMemoryManager;
	    OptionMemoryManager = ptr;
	    if(ptr->next)
		    ptr->next->last = ptr;

#ifdef RCURL_DEBUG_MEMORY
	    ptr->numTickets = 0;
	    RCurlMemoryDiagnostics.handleCount++;

	    fprintf(stderr, "Adding CURL table: %p\n", el->curl);fflush(stderr);
#endif
	}

	el->next = ptr->top;
	ptr->top = el;


#ifdef RCURL_DEBUG_MEMORY
	RCurlMemoryDiagnostics.ticketAddCount++;
	ptr->numTickets++;
	fprintf(stderr, "Adding ticket for %p (%p)\n", el->curl, el->data);fflush(stderr);
#endif

	return(ptr);	
}

CURLOptionMemoryManager*
RCurl_getMemoryManager(CURL *curl)
{
	CURLOptionMemoryManager *ptr;

	ptr = OptionMemoryManager;
	while(ptr) {
		if(ptr->curl == curl) {
		   break;
		}
		ptr = ptr->next;
	}

	return(ptr);
}

void
RCurl_releaseMemoryTickets(CURL *curl)
{
   RCurl_releaseManagerMemoryTickets( RCurl_getMemoryManager(curl) );
}

void
RCurl_releaseManagerMemoryTickets(CURLOptionMemoryManager *mgr)
{
    RCurlMemory *ptr, *tmp;

#ifdef RCURL_DEBUG_MEMORY
    int ctr = 0;
#endif

    if(!mgr) {
#if 0
/* This is okay as we may not have needed to protected it. */
	    PROBLEM "CURL object (%p) that is not handled in the RCurl memory management system.", (void*)curl
	    WARN;
#endif
	    return;
    }

#ifdef RCURL_DEBUG_MEMORY
    fprintf(stderr, "Releasing CURL data: %p, # tickets = %d\n", curl, mgr->numTickets);fflush(stderr);
#endif    

    ptr = mgr->top;

    while(ptr) {
	    tmp = ptr->next;


	    if(ptr->option == CURLOPT_HTTPHEADER) {
		    /* */
#ifdef RCURL_DEBUG_MEMORY
		    fprintf(stderr, "Releasing HTTPHEADER list %p\n", ptr->data);fflush(stderr);
#endif
		    curl_slist_free_all((struct curl_slist *) ptr->data);
            } else if(ptr->option == CURLOPT_HTTPPOST) {
		    /* */
#ifdef RCURL_DEBUG_MEMORY
		    fprintf(stderr, "Releasing HTTPPOST struct %p\n", ptr->data);fflush(stderr);
#endif
		    curl_formfree((struct curl_httppost *) ptr->data);
            } else if(ptr->option > CURLOPTTYPE_FUNCTIONPOINT  && ptr->option < CURLOPTTYPE_OFF_T) {
		    /* Leak here. We Preserved the R function, but if we unpreserve it, others may lose it also. */
	    } else if(ptr->type == R_OBJECT) {
     	          R_ReleaseObject((SEXP) ptr->data);
	    } else
  	          free((void *) ptr->data);

	    free(ptr);
	    ptr = tmp;

#ifdef RCURL_DEBUG_MEMORY
	    mgr->numTickets--;
	    RCurlMemoryDiagnostics.ticketReleaseCount++;
	    ctr++;
#endif
    }


    if(mgr == OptionMemoryManager) {
          /* head of the linked list so move global pointer to the next one. */
	    OptionMemoryManager = OptionMemoryManager->next;
	    if(OptionMemoryManager)
		    OptionMemoryManager->last = NULL;
    } else {
	    /* Connect the one on the left and the right. */
        if(mgr->next) 
          mgr->next->last = mgr->last;
	if(mgr->last)
	  mgr->last->next = mgr->next;

    }


#ifdef RCURL_DEBUG_MEMORY
    fprintf(stderr, "Release %d items for %p (%d left)\n", ctr, curl, mgr->numTickets);fflush(stderr);
#endif

    free(mgr);
}

#ifdef RCURL_DEBUG_MEMORY
void
Rcurl_showMemoryDebug(void)
{

	fprintf(stderr,"# CURL handles %d\n# tickets %d\n# tickets released %d\n",
		RCurlMemoryDiagnostics.handleCount,
		RCurlMemoryDiagnostics.ticketAddCount,
		RCurlMemoryDiagnostics.ticketReleaseCount);
	fflush(stderr);
}
#endif
