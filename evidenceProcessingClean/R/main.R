execute <- function(loadSource = FALSE,
                    loadSR_AEOLUS = FALSE,
                    loadPL_SPLICER = FALSE,
                    loadPL_EUPLADR = FALSE,
                    loadCT_SHERLOCK = FALSE){
  ################################################################################
  # VARIABLES
  ################################################################################
  configFile <- "extras/config.csv"

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

  schemaClean <- Sys.getenv("clean")
  schemaVocab <- "vocabulary"
  schemaSource <- "staging_audit"
  schemaAeolus <- "staging_aeolus"
  schemaMedline <- "staging_medline"
  schemaSplicer <- "staging_splicer"
  schemaEUPLADR <- "staging_eu_pl_adr"
  schemaSemMedDb <- "staging_semmeddb"
  schemaSherlock <- "staging_sherlock"

  tableSource <- "source"
  tableAeolus <- "aeolus"
  tableAvillach <- "medline_avillach"
  tableWinnenburg <- "medline_winnenburg"
  tableEUPLADR <- "eu_pl_adr"
  tableCoOccurrence <- "medline_cooccurrence"
  tableSplicer <- "splicer"
  tableSemMedDb <- "semmeddb"
  tableMeshTags <- paste0(schemaClean,".lu_pubmed_mesh_tags")
  tablePubmed <- "pubmed"
  tableSherlock <- "sherlock"

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  ################################################################################
  #WORK - GENERAL
  ################################################################################
  if(loadSource){
    genericLoad(connnectionDetails=connnectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSource,
                sourceSchema=schemaSource,
                sqlFile="source.sql",
                vocabSchema=schemaVocab)
  }

  ################################################################################
  #WORK - FAERS
  ################################################################################

  #AEOLUS
  genericLoad(connnectionDetails=connnectionDetails,
              targetDbSchema=schemaClean,
              targetTable=tableAeolus,
              sourceSchema=schemaAeolus,
              sqlFile="aeolus.sql",
              vocabSchema=schemaVocab)

  ################################################################################
  #WORK - PRODUCT LABELS
  ################################################################################
  if(loadPL_SPLICER){
    genericLoad(connnectionDetails=connnectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSplicer,
                sourceSchema=schemaSplicer,
                sqlFile="splicer.sql")
  }

  if(loadPL_EUPLADR){
    genericLoad(connnectionDetails=connnectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableEUPLADR,
                sourceSchema=schemaEUPLADR,
                sqlFile="eu_pl_adr.sql")
  }

  ################################################################################
  #WORK - Clinical Trials
  ################################################################################
  if(loadCT_SHERLOCK){
    genericLoad(connnectionDetails=connnectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSherlock,
                sourceSchema=schemaSherlock,
                sqlFile="sherlock.sql")
  }

  ################################################################################
  # CLEAN
  ################################################################################

}
