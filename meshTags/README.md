Basics
----
This package is meant to reduce the amount of MeSH tags used to only those which are of interest (to whom?). It requires access to
an additional (not publicly available) schema with patient level data and therefore is its own package. It will export a
text file that is later used in processing, previously exported text files are already in the right location and this
step can be skipped if no update is required.


Requirements
----

- This package requires a dataset not part of informationPrep, there is a MeshTags.csv file from February 2020 already
  present in the next step which can be used if you don't have access to the data.
- R
- The DatabaseConnector package. It can be downloaded by running `install.packages("DatabaseConnector")` from R

Instructions
-----

- Enter the db connection details in the config files in the extras folder, rename them removing 'example'.
- Build the package `R CMD build ../meshTags` and install it `R CMD INSTALL meshTags_0.1.0.tar.gz`
- From the present folder run codeToRun.R (`Rscript extras/codeToRun.R`)

