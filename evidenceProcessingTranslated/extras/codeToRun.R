library(evidenceProcessingTranslated)

################################################################################
# WORK
################################################################################
execute(buildStcm = FALSE,
        loadSource = FALSE,
        pullSR_AEOLUS = TRUE,
        pullPL_SPLICER = FALSE,
        pullPL_EUPLADR = FALSE,
        pullPub_MEDLINE_COOCCURRENCE = FALSE,  #NOT RUNNING FOR V2.0
        pullPub_MEDLINE_AVILLACH = FALSE,
        pullPub_MEDLINE_WINNENBURG = FALSE,
        pullPub_PUBMED = FALSE,
        pullPub_SEMMEDDB = FALSE,
        pullCT_SHERLOCK = FALSE             #This takes about 10 min to run
        )


