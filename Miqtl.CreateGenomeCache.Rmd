As noted in the README on the [miqtl GitHub page ](https://github.com/gkeele/miqtl), the functions in miqtl require a genome cache, which contains the haplotype data in a specific format.  The genome cache can be created from output from DOQTL or R/qtl2 using the convert.DOQTL.to.HAPPY() and convert.qtl2.to.HAPPY() functions.  The code below will take output from R/qtl2 and create a genome cache.

The code below assumes you have previously run Rqtl2 and copied the do.Rdata and pr.Rdata structures into the current directory.

```
# creates genome cache from pr and do objects from qtl2
library(miqtl) 
# or library(miqtl, lib.loc="~/R_libs") if on CU server 

# load probabilities and DO data from R/qtl2
load("pr.Rdata")
load("do.Rdata")
# create the genome cache.
convert.qtl2.to.HAPPY(qtl2.object=pr,
                      cross.object=do,
                      HAPPY.output.path="./genomecache",
                      allele.labels=LETTERS[1:8],
                      chr=c(1:19, "X"),
                      diplotype.order="qtl2")
```

You will now have a directory called genomecache in the current working directory.

Next step [run scans](https://github.com/Sethupathy-Lab/MIQTL/blob/master/Miqtl.Run.Scans.Rmd)
