library("RCurl")
## debug(postForm)

xmlQuery = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE Query><Query  virtualSchemaName = 'default' uniqueRows = '1' count = '0' datasetConfigVersion = '0.6' requestid= \"biomaRt\"> <Dataset name = 'hsapiens_gene_ensembl'><Attribute name = '3utr'/><Attribute name = 'entrezgene'/><Filter name = 'entrezgene' value = '25,87,102' /></Dataset></Query>"

uri = "http://www.biomart.org:80/biomart/martservice?"

NoRun = FALSE

tryCatch( {r = postForm(uri, query = xmlQuery, .opts = list(timeout = 10, nosignal = TRUE))},
          error = function(e) {
             cat("problem connecting to biomart. May be temporary.\n")
             NoRun <<- TRUE
          })


if(NoRun == FALSE && require("biomaRt")) {
 h = getCurlHandle(nosignal = 1)
 ensembl = useMart("ensembl",dataset="hsapiens_gene_ensembl")
 tss = getBM(attributes = c("ensembl_gene_id"),
             filters = "ensembl_gene_id",
             values = c("ENSG00000171855","ENSG00000102794","ENSG00000175505"),
             mart = ensembl, curl = curl)
 tss
}
