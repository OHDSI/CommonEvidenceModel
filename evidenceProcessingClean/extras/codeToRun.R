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
schemaMedline <- "staging_medline"
tableAvillach <- "medline_avillach"
tableCoOccurrence <- "medline_cooccurrence"

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
#tbd

################################################################################
# MEDLINE
################################################################################

#COOCCURRENCE
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableCoOccurrence,
                    sourceSchema=schemaMedline,
                    sourceID=tableCoOccurrence,
                    drugQualifier="",
                    conditionQualifier="")

#AVILLACH
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableAvillach,
                    sourceSchema=schemaMedline,
                    sourceID=tableAvillach,
                    drugQualifier="AND lower(qualifier.value) = 'adverse effects'",
                    conditionQualifier="AND lower(qualifier.value) = 'chemically induced'")

#PUBMED PULL
#tbd

#WINNENBURG
#tbd

#SEMMEDDB
#tbd

################################################################################
# PRODUCT LABELS
################################################################################

#SPLICER
#tbd

#EUPLADR
#tbd
