library(evidenceProcessingClean)

execute(loadSource = FALSE,
        loadSR_AEOLUS = FALSE,
        loadPL_SPLICER = FALSE,
        loadPL_EUPLADR = FALSE,
        loadPub_MEDLINE_COOCCURRENCE = FALSE,
        loadPub_MEDLINE_AVILLACH = TRUE,
        loadPub_MEDLINE_WINNENBURG = TRUE,
        loadPub_PUBMED = FALSE, #DO NOT RUN AGAIN FOR V2.0, TAKES 5 days
        loadPub_SEMMEDDB = FALSE,
        loadCT_SHERLOCK = FALSE)
