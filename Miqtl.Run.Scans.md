Running the scans should be done on a CU server as the code takes a lot of time and memory to run.  The code requires the DO data from R/qtl2, and that the genome cache has been constructed. It is prudent to save all the objects created in this code for reuse later or in case of failure of a particular step.  In case of a failure, objects from all the steps prior to the failed step can be loaded rather than recreated.  Several steps require quite a bit of time so being able to reload an object rather than recreate it can save lots of headache. 

You will need to create a file like the one below for each phenotype in your do$pheno.  Once the kinship data has been created and saved for one phenotype, it can be loaded and reused for the remaining phenotypes rather than recreating it for each phenotype.  All other objects will be phenotype specific.

```
library(miqtl)

# load do data
load("do.Rdata")
pheno.data=data.frame(do$pheno)
pheno.data$SUBJECT.NAME <- rownames(pheno.data)

# calculate kinship data and save it
k = calc.kinship.from.genomecache.with.DOQTL(genomecache="./genomecache", model="additive")
save(k,file="Kinship.Rdata")
#load("Kinship.Rdata")

# Scans
ppi6.MI11.scan <- scan.h2lmm(genomecache="./genomecache/", data=pheno.data, formula=ppi6.boxcox~1, K=k, use.multi.impute=TRUE, 
	num.imp=11, use.fix.par=TRUE, print.locus.fit=TRUE)
save(ppi6.MI11.scan, file="ppi6.MI11.scan.Rdata")

####  Calculate significance thresholds
ppi6.nullisms <- generate.sample.outcomes.matrix(scan.object=ppi6.MI11.scan, model.type="null", method="bootstrap", use.REML=TRUE, use.BLUP=FALSE, num.samples=250, seed=1)
ppi6.MI11.nullscans <- run.threshold.scans(sim.threshold.object=ppi6.nullisms, keep.full.scans=TRUE, 
                  genomecache="./genomecache/", data=pheno.data, use.par="h2", use.multi.impute=FALSE, brute=TRUE, 
                  use.fix.par=TRUE, scan.seed=1, scale="cM")
save(ppi6.MI11.nullscans, file="ppi6.MI11.nullscans.Rdata")
ppi6.MI11.thresh95 <- get.gev.thresholds(ppi6.MI11.nullscans, use.lod=TRUE, percentile=0.95)
save(ppi6.MI11.thresh95, file="ppi6.MI11.thresh95.Rdata")
ppi6.MI11.thresh90 <- get.gev.thresholds(ppi6.MI11.nullscans,use.lod=TRUE, percentile=0.90)
save(ppi6.MI11.thresh90, file="ppi6.MI11.thresh90.Rdata")

# plot scan results
png(file="ppi6.boxcox.MI11.scan.filtered.png",width = 1050, height=600,)
genome.plotter.whole(scan.list=list(ppi6.boxcox.MI11.scan), use.lod=TRUE,
                     use.legend = FALSE,
                     hard.thresholds=c(ppi6.boxcox.MI11.thresh95, ppi6.boxcox.MI11.thresh90),
                     thresholds.col=c("red", "blue"))
dev.off()

```

If you have multiple phenotypes in your experiment, you will have to have one file like the one above for each phenotype. The following bash script can be used to create phenotype specific files like the one above. 

you can get the exact names of the phenotypes from the do.Rdata files like this...
```
colnames(do$pheno)
[1] "ppi3.boxcox"  "ppi6.boxcox"  "ppi12.boxcox"
```

```
#/bin/bash

gc='./genomecache/'

# for each of your phenotypes, create an R file to run the scans
# phenotype names below should match what's in the do$pheno object
# as shown above
for p in ppi3.boxcox  ppi6.boxcox  ppi12.boxcox 
do

# MI11
  of=$p".miqtl.R"
  
  # use following if on CU server
  #echo '.libPaths(c(.libPaths(), "~/R_libs"))'>$of
  
  # use this if working on your local machine
  echo 'library(miqtl)' >$of

  echo '' >>$of
  echo '# load do data' >>$of
  echo 'load("do.Rdata")' >>$of
  echo 'pheno.data=data.frame(do$pheno)' >>$of
  echo 'pheno.data$SUBJECT.NAME <- rownames(pheno.data)' >>$of
  echo '' >>$of
  echo '# calculate kinship data' >>$of
  echo 'k = calc.kinship.from.genomecache.with.DOQTL(genomecache="./genomecache", model="additive")' >>$of
  echo 'save(k,file="kinship.Rdata")' >>$of
  echo '' >>$of
  echo '# Scans' >>$of
  echo  $p'.MI11.scan <- scan.h2lmm(genomecache="'$gc'", data=pheno.data, formula='$p'~1, K=k, use.multi.impute=TRUE, 
	num.imp=11, use.fix.par=TRUE, print.locus.fit=TRUE)' >>$of
  echo 'save('$p'.MI11.scan, file="'$p'.MI11.scan.Rdata")' >>$of

  echo '' >>$of
  echo '####  Significance thresholds' >>$of
  echo $p'.nullisms <- generate.sample.outcomes.matrix(scan.object='$p'.MI11.scan, model.type="null", method="bootstrap", use.REML=TRUE, use.BLUP=FALSE, num.samples=250, seed=1)' >>$of
  echo $p'.MI11.nullscans <- run.threshold.scans(sim.threshold.object='$p'.nullisms, keep.full.scans=TRUE, 
                  genomecache="'$gc'", data=pheno.data, use.par="h2", use.multi.impute=FALSE, brute=TRUE, 
                  use.fix.par=TRUE, scan.seed=1, scale="cM")' >>$of
  echo 'save('$p'.MI11.nullscans, file="'$p'.MI11.nullscans.Rdata")' >>$of
  echo $p'.MI11.thresh95 <- get.gev.thresholds('$p'.MI11.nullscans, use.lod=TRUE, percentile=0.95)' >>$of
  echo 'save('$p'.MI11.thresh95, file="'$p'.MI11.thresh95.Rdata")' >>$of
  
  echo $p'.MI11.thresh90 <- get.gev.thresholds('$p'.MI11.nullscans,use.lod=TRUE, percentile=0.90)' >>$of
  echo 'save('$p'.MI11.thresh90, file="'$p'.MI11.thresh90.Rdata")' >>$of


  echo '' >>$of
  echo '### plot LOD plot' >>$of
  echo 'png(file="'$p'.MI11.scan.png",width = 1050, height=600,)' >>$of
  echo 'genome.plotter.whole(scan.list=list('$p'.MI11.scan), use.lod=TRUE,
		     use.legend=FALSE,
		     hard.thresholds=c('$p'.MI11.thresh95, '$p'.MI11.thresh90),
                     thresholds.col=c("red", "blue"))' >>$of
  echo 'dev.off()' >>$of

done
```
Assuming  
1) you have logged onto a CU workstation and created a directory called miqtl in /workdir.
2) you have copied do.Rdata and the genomecache directory to miqtl
3) created a bash file with the script above in it

run the bash script to create phenotype specific R scripts like the one above.
```
sh createScanFiles.sh
```

You should now have one R script for each phenotype.

Once you have your R scripts for each phenotype created, you can run them using the command below.  It recommended to run them one at a time in the background on the CU server since they take a long time/lots of memory.  For example, to run the scans for ppi6, use the code below.

```
# on the command line from within a folder in /workdir on a CU workstation.
nohup Rscript ppi6.miqtl.R &
```

Next step [process scan results](https://github.com/Sethupathy-Lab/MIQTL/blob/master/Miqtl.ProcessScanResults.md)
