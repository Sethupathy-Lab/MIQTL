There is a complete tutorial on the CU servers in the Sethupathy Lab directory.  
It is called miqtl_tutorial and can be found here...  
/home/pr46_0001/cornell_tutorials  
All the files needed to run it are contained in the miqtl_tutorial folder.
There is also a folder in miqtl_tutorial called tutorial_results which contains all of the output that will be generated from this tutorial.  You can compare your results with it for confirmation that everything worked fine.


Assuming you have installed all the required software as directed [here](https://github.com/Sethupathy-Lab/MIQTL/blob/master/Miqtl.Software.Setup.md)

Run the tutorial...  
# make a reservation on a workstation  
# login to your login node and then
```
# ssh to the workstation and cd to the /workdir
ssh your_user_name@workstation_name.tc.cornell.edu
# cd to the workdir on the workstation
cd /workdir
# create a directory to run the tutorial
mkdir miqtl_tutorial
cd miqtl_tutorial

# copy the files, but not the tutorial_results folder form the miqtl_tutorial folder to /workdir
cp /home/pr46_0001/cornell_tutorials/miqtl_tutorial/* ./

# create your genomecache
nohup Rscript createGenomeCashe.R &

# you should now have a folder called genomecache in your working directory
# create your scan files for the phenotypes in do.Rdata
sh createScanFiles.sh

# you should now have one <phenotype>.boxcox.miqtl.R file each phenotype in your working directory
# run scans e.g. run ppi6 scan
nohup Rscript ppi6.boxcox.miqtl.R &

# the above code will create a number of .Rdata objects for the ppi6 phenotype
# ppi6.boxcox.MI11.scan.Rdata
# ppi6.boxcox.MI11.nullscans.Rdata
# ppi6.boxcox.MI11.thresh90.Rdata
# ppi6.boxcox.MI11.thresh95.Rdata
# ppi6.boxcox.MI11.scan.png
# ppi6.boxcox.MI11.scan.png is the LOD plot for all chromosomes
# you can view it on the CU server if you are using VNC, if not you will
# need to ftp it to a local computer to view it.

# you can now process the miqtl results to view and get info on significant peaks
# this part is actually best done interactively so that you can specifiy details
# about which peaks your are interested in

# start an R session and run the code in processScanResults.R line by line.
# on the command line...
R

# within R....
# use this if on the CU server
# .libPaths(c(.libPaths(), "~/R_libs"))
library(miqtl)

# load the scan and threshold files
load("ppi6.boxcox.MI11.scan.Rdata")
load("ppi6.boxcox.MI11.thresh90.Rdata")
load("ppi6.boxcox.MI11.thresh95.Rdata")
# load the GM_snps data
load("GM_snps.Rdata")


# print the LOD plots for the ppi6 phenotype
png(file="ppi6.boxcox.MI11.scan.png",width = 1050, height=600,)
genome.plotter.whole(scan.list=list(ppi6.boxcox.MI11.scan), use.lod=TRUE,
                     use.legend = FALSE,
                     hard.thresholds=c(ppi6.boxcox.MI11.thresh95, ppi6.boxcox.MI11.thresh90),
                     thresholds.col=c("red", "blue"))
dev.off()


# We have an interesting peak on chr13, so get the identity 
# and exact location of the locus
# get peak locus on a specific chromosome
scanObj=ppi6.boxcox.MI11.scan
(peak.locus.ppi6.chr13 = scanObj$loci[scanObj$chr == 13][which.min(scanObj$p.value[scanObj$chr ==13])])
# [1] "UNCHS036777"

# get the marker information from GM_snps 
GM_snps[GM_snps$marker=="UNCHS036777",]
# marker      chr   Mbp     cM
#UNCHS036777  13 93.91029 42.23474


################ ppi6 allele effects plots ################
library(Diploffect.INLA)
library(INLA)

load("do.Rdata")
phenoDat=data.frame(do$pheno)
phenoDat$SUBJECT.NAME <- rownames(phenoDat)
phenoCol="ppi6.boxcox"
scanObj=ppi6.boxcox.MI11.scan
fn="ppi6.boxcox"
genomecache=("./genomecache/")

# load kinship data
load("kinship.Rdata")


# get peak locus on a specific chromosome
chr=13
formula = paste0(unlist(strsplit(ppi6.boxcox.MI11.scan$formula,"[ ]"))[1],"~1+locus.full")
peak.locus = scanObj$loci[scanObj$chr == chr][which.min(scanObj$p.value[scanObj$chr == chr])]

# probability heatmap
png(file=paste(fn, peak.locus,"ProbHeatmap.png",sep="."))
prob.heatmap(marker=peak.locus, genomecache=genomecache,
             phenotype=phenoCol, phenotype.data=phenoDat, model="additive")
dev.off()


# get the data
inla.diploffect <- run.diploffect.inla.through.genomecache(formula=as.formula(formula),
                    locus=peak.locus, data=phenoDat, K=k, genomecache=genomecache,
                    num.draws=10, use.dip.lincomb=TRUE, seed=1, gamma.rate=1)

inla.diploffect.summary <- run.diploffect.inla.summary.stats(inla.diploffect)

# create effects plots
png(file=paste(fn,chr,peak.locus,"StrainEff.png",sep="."))
plot_straineff.ci(inla.diploffect.summary, flip=FALSE)
dev.off()
png(file=paste(fn,chr,peak.locus,"DeviationEff.png",sep="."))
plot_deviation.ci(inla.diploffect.summary, flip=FALSE)
dev.off()
png(file=paste(fn,chr, peak.locus,"DipplotypeEff.png",sep="."))
plot_diplotype.ci(inla.diploffect.summary, flip=FALSE)
dev.off()
png(file=paste(fn,chr,peak.locus,"VarianceExp.png",sep="."))
plot_varexp.ci(inla.diploffect.summary, add.numbers=TRUE)
dev.off()
```




