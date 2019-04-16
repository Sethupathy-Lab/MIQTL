
## 1) Acquiring/Setting up the software on the CU server

### WARNINGS:  
#### 1) Miqtl is in active development so the code changes frequently and it is not currently hosted on Bioconductor. You should always start with the latest version of code from Greg's Github page.  
#### 2) Reading/Writing the files for this program requires a lot of space and memory and is best done on the CU servers.  
#### 3) Unfortunately, because of #1, the CU servers don't always have the current version of Miqtl and it may change midstream of your analysis.  For this reason, it is best to install the latest version in your own R repository so that you know you have the latest and greatest and can update it whenever you need to without help from CU bioinformatics staff. This is bit of a pain, but learning how to do this will help you with this and many other projects that require software that may not exist or be up to date on the CU servers. 

### Step 1: Installing R packages to your own repository  

#### You should only have to do this once on the CU server.

#### 1) Reserve yourself time on a CU workstation.  The software install should take about an hour or less. Reserve more time than you think you will need. You can always cancel if you don't need it all. Worst case is running out of time in the middle of the process only to have to start it over. 

#### 2) Login to one of the login nodes and then ssh to your reserved workstation.
```
ssh user@serverlm01.tc.cornell.edu
```
#### 3) Create a working directory on the CU workstation (not the login node)
Within /workdir on the workstation, create a directory to store your input and output files.  Name it something meaningful for your project.   In this example the directory is called miqtl_tutorial  
```
# On the CU workstation...
mkdir /workdir/miqtl_tutorial
# move to the directory
cd /workdir/miqtl_tutorial
```
#### 4) create an R repository in your local directory (login node) on the CU server.
```
# create repository in your local directory on the login node
# and set permissions 
mkdir ~/R_libs
chmod 755 `/R_libs/*
```
#### 5)  Start R to install miqtl from the Github repository into your local repository in your login node  
```
# start R 
/programs/R-3.4.2/bin/R

# in R...
# install the package in your local repository
library(devtools)
install_github("gkeele/miqtl", lib="~/R_libs")
install.packages("INLA", repos="https://www.math.ntnu.no/inla/R/stable", lib="~/R_libs")
install_github("gkeele/Diploffect.INLA", lib="~/R_libs")
```
This should install miqtl and all it's dependencies.  If you are prompted to install dependencies during the install process, answer yes.

Occasionally, this installation method fails and you have to download a "master", create a tar.gz from the master and then install from that.  In that case the code looks something like.  
Open a browser and navigate to [Greg's Github page ](https://github.com/gkeele/miqtl)  
Click on clone or download  
Right click/Control click on Download ZIP and select Copy Link Address  
In your Terminal window, on the command line (not in R) 
```
# on the command line (not in R) on a workstation, within /workdir/miqtl_tutorial
# download the master file by typing wget and then pasting the Link Address you
# just copied from Karl's Github page
wget https://github.com/gkeele/miqtl/archive/master.zip
# unzip it
unzip master.zip
# rename the master file
mv master miqtl

# Now start R to install it
/programs/R-3.4.2/bin/R

# create a package from github master file
library(devtools)
devtools::build("miqtl")
# this will create a file called miqtl.tar.gz in your current directory
# install the package in your local R repository
install.packages("miqtl.tar.gz", lib="~/R_libs")
```
Once you have installed miqtl successfully, you can delete the miqtl.tar.gz file  

To install Diploffect.INLA, follow the same procedure as for miqtl.

For INLA, use the instructions [here ](http://www.r-inla.org/download).

#### To install miqtl on your local computer
From the repository...  
Open RStudio  
```
library(devtools)
install_github("gkeele/miqtl")
install.packages("INLA", repos="https://www.math.ntnu.no/inla/R/stable")
install_github("gkeele/Diploffect.INLA")
```
OR from the master...  
Follow the instructions for installing from the master on the CU servers but leave off the lib="~/R_libs" part of the commands.


Next step [create genome cache](https://github.com/Sethupathy-Lab/MIQTL/blob/master/Miqtl.CreateGenomeCache.Rmd)
