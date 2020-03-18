library(evidenceProcessingClean)

execute(loadSource = FALSE,
        loadSR_AEOLUS = FALSE,
        loadPL_SPLICER = FALSE,
        loadPL_EUPLADR = FALSE,
        loadPub_MEDLINE_COOCCURRENCE = FALSE, #Not doing for this build
        loadPub_MEDLINE_AVILLACH = TRUE,     #MAY NOT LOAD THIS AGAIN FOR V2.0
        loadPub_MEDLINE_WINNENBURG = FALSE,    #RERAN AFTER FINDING NOT ALL WERE PROCESSED
        loadPub_PUBMED = FALSE,               #DO NOT RUN AGAIN FOR V2.0, TAKES 5 days
        loadPub_SEMMEDDB = FALSE,
        loadCT_SHERLOCK = FALSE)
