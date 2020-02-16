execute <- function(buildStcm = FALSE,
                    pullSR_AEOLUS = FALSE,
                    pullPL_SPLICER = FALSE,
                    pullPL_EUPLADR = FALSE,
                    pullPub_MEDLINE_COOCCURRENCE = FALSE,
                    pullPub_MEDLINE_AVILLACH = FALSE,
                    pullPub_MEDLINE_WINNENBURG = FALSE,
                    pullPub_PUBMED = FALSE,
                    pullPub_SEMMEDDB = FALSE,
                    pullCT_SHERLOCK = FALSE){

  ################################################################################
  # VARIABLES
  ################################################################################
  configFile <- "extras/config.csv"

  connectionDetails <- getConnectionDetails(configFile)

  config <- read.csv(configFile,as.is=TRUE)[1,]
  Sys.setenv(dbms = config$dbms)
  Sys.setenv(user = config$user)
  Sys.setenv(pw = config$pw)
  Sys.setenv(server = config$server)
  Sys.setenv(port = config$port)
  Sys.setenv(vocabulary = config$vocabulary)
  Sys.setenv(clean = config$evidenceProcessingClean)
  Sys.setenv(translated = config$evidenceProcessingTranslated)
  Sys.setenv(evidence = config$postProcessing)

  aeolus = "aeolus"
  medline_avillach = "medline_avillach"
  medline_winnenburg = "medline_winnenburg"
  medline_cooccurrence = "medline_cooccurrence"
  pubmed = "pubmed"
  semmeddb = "semmeddb"
  splicer = "splicer"
  euPlAdr = "eu_pl_adr"
  sherlock = "sherlock"
  source = "source"

  #schemas
  vocabulary <- Sys.getenv("vocabulary")
  umlsSchema <- "staging_umls"
  cleanSchema <- Sys.getenv("clean")
  translatedSchema <- Sys.getenv("translated")

  #clean data
  cleanAeolus <- paste0(cleanSchema,'.',aeolus)
  cleanSherlock <- paste0(cleanSchema,'.',sherlock)

  #tables
  stcmTable <- paste0(vocabulary,".SOURCE_TO_CONCEPT_MAP")

  ################################################################################
  # WORK - GENERAL
  ################################################################################

  if(buildStcm) {
    #Building Source to Concept Map Tables Needed for Translation
    buildStcm(connectionDetails = connectionDetails,
              vocabulary=vocabulary,
              stcmTable=stcmTable,
              umlsSchema=umlsSchema,
              faers=cleanAeolus,
              sherlock=cleanSherlock)
  }

  ################################################################################
  # WORK - SPONTANEOUS REPORT
  ################################################################################
  #AEOLUS
  translate(connectionDetails = connectionDetails,
            sourceTable=paste0(cleanSchema,'.',aeolus),
            targetTable=paste0(translatedSchema,'.',aeolus),
            id=aeolus,
            stcmTable=stcmTable,
            translationSql="aeolus.sql")

  ################################################################################
  # WORK - PUBLICATIONS
  ################################################################################
  #COOCCURRENCE
  if(pullPub_MEDLINE_COOCCURRENCE){
    #COOCCURRENCE
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',medline_cooccurrence),
              targetTable=paste0(translatedSchema,'.',medline_cooccurrence),
              id=medline_cooccurrence,
              stcmTable=stcmTable,
              translationSql="medline.sql")
  }

  #AVILLACH
  if(pullPub_MEDLINE_AVILLACH){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',medline_avillach),
              targetTable=paste0(translatedSchema,'.',medline_avillach),
              id=medline_avillach,
              stcmTable=stcmTable,
              translationSql="medline.sql")
  }

  #WINNENBURG
  if(pullPub_MEDLINE_WINNENBURG){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',medline_winnenburg),
              targetTable=paste0(translatedSchema,'.',medline_winnenburg),
              id=medline_winnenburg,
              stcmTable=stcmTable,
              translationSql="medline.sql")
  }

  #PUBMED PULL
  if(pullPub_PUBMED){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',pubmed),
              targetTable=paste0(translatedSchema,'.',pubmed),
              id=pubmed,
              stcmTable=stcmTable,
              translationSql="pubmed.sql")

  }

  #SEMMEDDB
  if(pullPub_SEMMEDDB){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',semmeddb),
              targetTable=paste0(translatedSchema,'.',semmeddb),
              id=semmeddb,
              stcmTable=stcmTable,
              translationSql="semmeddb.sql")
  }
  ################################################################################
  # WORK - PRODUCT LABELS
  ################################################################################
  #SPLICER
  if(pullPL_SPLICER){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',splicer),
              targetTable=paste0(translatedSchema,'.',splicer),
              id=splicer,
              stcmTable=stcmTable,
              translationSql="splicer.sql")
  }

  #EUPLADR
  if(pullPL_EUPLADR){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',euPlAdr),
              targetTable=paste0(translatedSchema,'.',euPlAdr),
              id=euPlAdr,
              stcmTable=stcmTable,
              translationSql="euPlAdr.sql")
  }

  ################################################################################
  # WORK - CLINICAL TRIAL
  ################################################################################
  #SHERLOCK
  if(pullCT_SHERLOCK){
    translate(connectionDetails = connectionDetails,
              sourceTable=paste0(cleanSchema,'.',sherlock),
              targetTable=paste0(translatedSchema,'.',sherlock),
              id=sherlock,
              stcmTable=stcmTable,
              translationSql="sherlock.sql")
  }
}
