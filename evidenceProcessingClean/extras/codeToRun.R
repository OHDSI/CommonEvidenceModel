library(evidenceProcessingClean)

execute(loadSource = FALSE,
        loadSR_AEOLUS = TRUE,
        loadPL_SPLICER = TRUE,
        loadPL_EUPLADR = TRUE,
        loadPub_MEDLINE_COOCCURRENCE = FALSE, #Not doing for this build
        loadPub_MEDLINE_AVILLACH = FALSE,     #MAY NOT LOAD THIS AGAIN FOR V2.0
        loadPub_MEDLINE_WINNENBURG = FALSE,   #MAY NOT LOAD THIS AGAIN FOR V2.0
        loadPub_PUBMED = FALSE,               #DO NOT RUN AGAIN FOR V2.0, TAKES 5 days
        loadPub_SEMMEDDB = TRUE,
        loadCT_SHERLOCK = TRUE)
