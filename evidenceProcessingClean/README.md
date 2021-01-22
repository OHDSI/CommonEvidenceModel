# Evidence Processing - Clean

The goal of this package is to take raw data and put it into as much of a standardized format as possible.

# Requirements

- R version 3.6.0 or up
- R packages RISmed and DatabaseConnector. In R use `install.packages(c("RISmed","DatabaseConnector"))`
- 1TB of available disk space (mainly for the MedlineCoOccurrence table)

# Instructions

- Edit the config csv
- Build the package `R CMD build ../meshTags` and install it `R CMD INSTALL meshTags_0.1.0.tar.gz`
- Set the datasets you would like to update to `true` in the codeToRun.R file Instructions
- From the present folder run codeToRun.R (`Rscript extras/codeToRun.R`)

# Notes

- If you don't have the required packages the installation of this package will fail, automatically downloading when
  installing the tar.gz file should work but doesn't :-)
  https://stackoverflow.com/questions/6907937/how-to-install-dependencies-when-using-r-cmd-install-to-install-r-packages
  