execute <- function(loadSource = FALSE,
                    loadSR_AEOLUS = FALSE,
                    loadPL_SPLICER = FALSE,
                    loadPL_EUPLADR = FALSE,
                    loadPub_MEDLINE_COOCCURRENCE = FALSE,
                    loadPub_MEDLINE_AVILLACH = FALSE,
                    loadPub_MEDLINE_WINNENBURG = FALSE,
                    loadPub_PUBMED = FALSE,
                    loadPub_SEMMEDDB = FALSE,
                    loadCT_SHERLOCK = FALSE
                    ){
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
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSource,
                sourceSchema=schemaSource,
                sqlFile="source.sql",
                vocabSchema=schemaVocab)
  }

  ################################################################################
  #WORK - FAERS
  ################################################################################
  if(loadSR_AEOLUS){
    print("LOAD SPONTANEOUS REPORTS:  AEOLUS")
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableAeolus,
                sourceSchema=schemaAeolus,
                sqlFile="aeolus.sql",
                vocabSchema=schemaVocab)
  }

  ################################################################################
  #WORK - PRODUCT LABELS
  ################################################################################
  if(loadPL_SPLICER){
    print("LOAD PRODUCT LABELS:  SPLICER")
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSplicer,
                sourceSchema=schemaSplicer,
                sqlFile="splicer.sql")
  }

  if(loadPL_EUPLADR){
    print("LOAD PRODUCT LABELS:  EUPLADR")
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableEUPLADR,
                sourceSchema=schemaEUPLADR,
                sqlFile="eu_pl_adr.sql")
  }

  ################################################################################
  #WORK - Publications
  ################################################################################
  if(loadPub_MEDLINE_COOCCURRENCE){
    #COOCCURRENCE
    medlineCoOccurrence(connectionDetails=connectionDetails,
                        targetDbSchema=Sys.getenv("clean"),
                        targetTable=tableCoOccurrence,
                        sourceSchema=schemaMedline,
                        sourceID=tableCoOccurrence)
  }

  if(loadPub_MEDLINE_AVILLACH){
    print("LOAD PUBLICATIONS:  MEDLINE AVILLACH")
    #AVILLACH
    medlineCoOccurrence(connectionDetails=connectionDetails,
                        targetDbSchema=schemaClean,
                        targetTable=tableAvillach,
                        sourceSchema=schemaMedline,
                        sourceID=tableAvillach,
                        qualifier=1)
  }

  if(loadPub_MEDLINE_WINNENBURG){
    print("LOAD PUBLICATIONS:  MEDLINE WINNENBERG")
    #WINNENBURG
    medlineCoOccurrenceWinnenburg(connectionDetails=connectionDetails,
                                  targetDbSchema=schemaClean,
                                  targetTable=tableWinnenburg,
                                  sourceSchema=schemaMedline,
                                  sourceID=tableWinnenburg)
  }

  if(loadPub_PUBMED){
    conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

    #PUBMED PULL
    #requires loading of Pubmed MeSH tags from the MeshTags Package
    df <- read.table("inst/csv/MeshTags.csv", header = TRUE)
    DatabaseConnector::insertTable(conn=conn,
                                   tableName=tableMeshTags,
                                   data=df,
                                   dropTableIfExists=TRUE,
                                   createTable=TRUE,
                                   tempTable=FALSE,
                                   oracleTempSchema=NULL)
    sql <- "ALTER TABLE @tableName OWNER TO RW_GRP;"
    renderedSql <- SqlRender::renderSql(sql=sql,
                                        tableName = paste0(Sys.getenv("clean"),'.',tablePubmed))
    translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                             targetDialect=Sys.getenv("dbms"))
    DatabaseConnector::executeSql(conn, translatedSql$sql)
    rm(df)

    pubmed(conn,
           targetDbSchema=Sys.getenv("clean"),
           targetTable=tablePubmed,
           sourceId=tablePubmed,
           meshTags=tableMeshTags,
           sqlFile="pubmed.sql",
           pullPubMed = 0,
           pubMedPullStart = 1,
           summarize = 1,
           summarizeStart = 1)

    DatabaseConnector::disconnect(conn)
  }

  if(loadPub_SEMMEDDB){
    print("LOAD PUBLICATIONS:  SEMMEDDB")
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=Sys.getenv("clean"),
                targetTable=tableSemMedDb,
                sourceSchema=schemaSemMedDb,
                sqlFile="semmeddb.sql")
  }

  ################################################################################
  #WORK - Clinical Trials
  ################################################################################
  if(loadCT_SHERLOCK){
    print("LOAD CLINICAL TRIALS:  SHERLOCK")
    genericLoad(connectionDetails=connectionDetails,
                targetDbSchema=schemaClean,
                targetTable=tableSherlock,
                sourceSchema=schemaSherlock,
                sqlFile="sherlock.sql")
  }

  ################################################################################
  # CLEAN
  ################################################################################


}
