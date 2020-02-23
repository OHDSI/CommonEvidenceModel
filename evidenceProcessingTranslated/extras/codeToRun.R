library(evidenceProcessingTranslated)

################################################################################
# WORK
################################################################################
execute(buildStcm = TRUE,
        loadSource = FALSE,
        pullSR_AEOLUS = TRUE,
        pullPL_SPLICER = TRUE,
        pullPL_EUPLADR = TRUE,
        pullPub_MEDLINE_COOCCURRENCE = FALSE,  #NOT RUNNING FOR V2.0
        pullPub_MEDLINE_AVILLACH = TRUE,
        pullPub_MEDLINE_WINNENBURG = TRUE,
        pullPub_PUBMED = TRUE,
        pullPub_SEMMEDDB = TRUE,
        pullCT_SHERLOCK = TRUE             #This takes about 10 min to run
        )


