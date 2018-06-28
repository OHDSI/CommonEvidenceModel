################################################################################
# CONFIG
################################################################################
#Connection
config <- read.csv("extras/config.csv",as.is=TRUE)[1,]

Sys.setenv(dbms = config$dbms)
Sys.setenv(user = config$user)
Sys.setenv(pw = config$pw)
Sys.setenv(server = config$server)
Sys.setenv(port = config$port)
Sys.setenv(vocabulary = config$vocabulary)
Sys.setenv(clean = config$evidenceProcessingClean)
Sys.setenv(translated = config$evidenceProcessingTranslated)
Sys.setenv(evidence = config$postProcessing)

#connect
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("dbms"),
  server = Sys.getenv("server"),
  port = as.numeric(Sys.getenv("port")),
  user = Sys.getenv("user"),
  password = Sys.getenv("pw")
)
conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

#variables
schemaVocab <- "vocabulary"
schemaSource <- "staging_audit"
schemaAeolus <- "staging_aeolus"
schemaMedline <- "staging_medline"
schemaSplicer <- "staging_splicer"
schemaEUPLADR <- "staging_eu_pl_adr"
schemaSemMedDb <- "staging_semmeddb"
tableSource <- "source"
tableAeolus <- "aeolus"
tableAvillach <- "medline_avillach"
tableWinnenburg <- "medline_winnenburg"
tableEUPLADR <- "eu_pl_adr"
tableCoOccurrence <- "medline_cooccurrence"
tableSplicer <- "splicer"
tableSemMedDb <- "semmeddb"
tableMeshTags <- paste0(Sys.getenv("clean"),".lu_pubmed_mesh_tags")
tablePubmed <- "pubmed"

library(evidenceProcessingClean)

################################################################################
# DATA LOADING
################################################################################

#SOURCE
genericLoad(conn=conn,
            targetDbSchema=Sys.getenv("clean"),
            targetTable=tableSource,
            sourceSchema=schemaSource,
            sqlFile="source.sql",
            vocabSchema=schemaVocab)

################################################################################
# FAERS
################################################################################

#AEOLUS
genericLoad(conn=conn,
            targetDbSchema=Sys.getenv("clean"),
            targetTable=tableAeolus,
            sourceSchema=schemaAeolus,
            sqlFile="aeolus.sql",
            vocabSchema=schemaVocab)

################################################################################
# MEDLINE
################################################################################

#COOCCURRENCE
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableCoOccurrence,
                    sourceSchema=schemaMedline,
                    sourceID=tableCoOccurrence)

#AVILLACH
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableAvillach,
                    sourceSchema=schemaMedline,
                    sourceID=tableAvillach,
                    qualifier=1)

#WINNENBURG
medlineCoOccurrenceWinnenburg(conn=conn,
                              targetDbSchema=Sys.getenv("clean"),
                              targetTable=tableWinnenburg,
                              sourceSchema=schemaMedline,
                              sourceID=tableWinnenburg)

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
       summarizeStart = 1044)

#bombed at
# 1423:4005 - Hepatitis, Drug-Induced -- 1424:4041 - Hepatitis, Drug-Induced
# 2540:4005 - thonzylamine - 2540:4041 - thonzylamine
# 3416:4005 - Pneumonia, Atypical Interstitial, of Cattle - 3425:4041 - Pneumonia, Atypical Interstitial, of Cattle
# 3805:4005 - Vitreoretinopathy, Proliferative

#SEMMEDDB
genericLoad(conn=conn,
            targetDbSchema=Sys.getenv("clean"),
            targetTable=tableSemMedDb,
            sourceSchema=schemaSemMedDb,
            sqlFile="semmeddb.sql")

################################################################################
# PRODUCT LABELS
################################################################################

#SPLICER
genericLoad(conn=conn,
            targetDbSchema=Sys.getenv("clean"),
            targetTable=tableSplicer,
            sourceSchema=schemaSplicer,
            sqlFile="splicer.sql")

#EUPLADR
genericLoad(conn=conn,
            targetDbSchema=Sys.getenv("clean"),
            targetTable=tableEUPLADR,
            sourceSchema=schemaEUPLADR,
            sqlFile="eu_pl_adr.sql")
