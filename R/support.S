collectChunks =
  # Not exported but can be used via RCurl:::collectChunks()
function(max = 10)
{
  chunks = character()
  ctr = 0

  list(chunks = function() chunks,
       read = function(txt) {

                ctr <<- ctr + 1

                chunks[ctr] <<- txt

                if(ctr >= max)
                   stop("Got enough")
              })
}  
  
chunkToLineReader =
function(f, verbose = FALSE)
{
  leftOvers = ""

  read = function(txt) {

    if(nzchar(leftOvers)) {
      txt = paste(leftOvers, txt, sep = "")
      leftOvers <<- ""
    }

      # Now find the bit at the end if there is any that is not a complete line.
    leftOvers <<- gsub('^.*\n', '', txt)

    if(verbose && nchar(leftOvers))
       cat("Left over:", leftOvers, "\n")

    Lines = strsplit(txt, "\n")[[1]]
    if(nchar(leftOvers)) 
        Lines = Lines[-length(Lines)]


    if(length(Lines))
       f(Lines)

    nchar(txt)
  }

  list(read = read, pending = function() leftOvers)
}  
