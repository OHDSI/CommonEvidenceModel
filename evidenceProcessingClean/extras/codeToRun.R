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
tableSource <- "source"
fileSource <- "source.csv"
createTableSource <-"source.sql"
schemaVocab <- "vocabulary"
schemaAeolus <- "staging_aeolus"
schemaMedline <- "staging_medline"
schemaSplicer <- "staging_splicer"
schemaEUPLADR <- "staging_eu_pl_adr"
schemaSemMedDb <- "staging_semmeddb"
tableAeolus <- "aeolus"
tableAvillach <- "medline_avillach"
tableEUPLADR <- "eu_pl_adr"
tableCoOccurrence <- "medline_cooccurrence"
tableSplicer <- "splicer"
tableSemMedDb <- "semmeddb"

library(evidenceProcessingClean)

################################################################################
# DATA LOADING
################################################################################
loadTable(conn=conn,
          targetDbSchema=Sys.getenv("clean"),
          targetTable=tableSource,
          fileName=fileSource,
          createTableSql=createTableSource)

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
                    drugQualifier=1,
                    conditionQualifier=1)

#PUBMED PULL
#tbd

#WINNENBURG
#tbd

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
