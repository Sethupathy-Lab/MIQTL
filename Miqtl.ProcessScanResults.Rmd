### Processing Scan Results
Now that you have run the scans, you can either process the scan results on the CU server or copy the scan results from the CU server to a folder on your local machine using FileZilla, rsync, or some other ftp program.  The downside to running it on the CU server is that you can't directly view the .png files in linux.  To view them you will either have to either use a VNC, which provides a graphical interface, or run the code and then upload your .png files to your local machine for viewing. The downside to running them locally is that the genomecache directory will take a long time to copy over to your local machine.

You will want to upload the kinship.Rdata, do.Rdata, thresh90.Rdata, thresh95.Rdata, the MI11.scan .Rdata files and the genomecache directory.You will also need to copy over some data on the snps in the GigaMUGA array.  The latter is contained in a file called GM_snps.Rdata.  There is a copy of this file in the miqtl_tutorial folder on the CU server.  Copy it over to your local machine or your directory in the CU server.  

Open RStudio and navigate to the folder with the scan results. 

```
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
png(file="ppi6.boxcox.MI11.scan.filtered.png",width = 1050, height=600,)
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

load("ppi6.boxcox.MI11.scan.Rdata")
load("do.Rdata")
phenoDat=data.frame(do$pheno)
phenoDat$SUBJECT.NAME <- rownames(phenoDat)
phenoCol="ppi6.boxcox"
scanObj=ppi6.boxcox.MI11.scan
fn="ppi6.boxcox"
genomecache=("./genomecache/")

# load kinship data
load("kinship.Rdata")

chr=13
formula = paste0(unlist(strsplit(ppi6.boxcox.MI11.scan$formula,"[ ]"))[1],"~1+locus.full")

######## MIQTL PLOTS ######################

# get peak locus on a specific chromosome
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

# create plots
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

Next step [run miqtl tutorial](https://github.com/Sethupathy-Lab/MIQTL/blob/master/Miqtl.Tutorial.Rmd)
