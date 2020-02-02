execute <- function(buildStcm = FALSE,
                    pullSR_AEOLUS = FALSE,
                    pullPL_SPLICER = FALSE,
                    pullPL_EUPLADR = FALSE,
                    pullPub_SEMMEDDB = FALSE){

  ################################################################################
  # VARIABLES
  ################################################################################
  configFile <- "extras/config.csv"

  connectionDetails <- getConnectionDetails(configFile)

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
  source = "source"

  #schemas
  vocabulary <- Sys.getenv("vocabulary")
  umlsSchema <- "staging_umls"
  cleanSchema <- Sys.getenv("clean")
  translatedSchema <- Sys.getenv("translated")

  #clean data
  cleanAeolus <- paste0(cleanSchema,'.',aeolus)

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
              faers=cleanAeolus)
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

}
