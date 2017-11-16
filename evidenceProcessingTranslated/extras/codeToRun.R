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

library(evidenceProcessingTranslated)

################################################################################
# VARIABLES
################################################################################
stcmTable = paste0(Sys.getenv("vocabulary"),".CEM_SOURCE_TO_CONCEPT_MAP")  #!!!THIS SHOULD GO INTO VOCABUALRY, BUT NEED PERMISSIONS
aeolus = "aeolus"
medline_avillach = "medline_avillach"
medline_cooccurrence = "medline_cooccurrence"
semmeddb = "semmeddb"
splicer = "splicer"
euPlAdr = "eu_pl_adr"
source = "source"

################################################################################
# VOCAB
################################################################################
buildStcm(conn=conn,
     vocabulary=vocabulary,
     stcmTable=stcmTable,
     umlsSchema="staging_umls")

################################################################################
# SOURCE
################################################################################
sql <- "IF OBJECT_ID('@targetTable', 'U') IS NOT NULL DROP TABLE @targetTable; SELECT * INTO @targetTable FROM @sourceTable;"
renderedSql <- SqlRender::renderSql(sql=sql,
                                    sourceTable = paste0(Sys.getenv("clean"),'.',source),
                                    targetTable = paste0(Sys.getenv("translated"),'.',source))
translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                         targetDialect=Sys.getenv("dbms"))
DatabaseConnector::executeSql(conn, translatedSql$sql)

################################################################################
# FAERS
################################################################################

#AEOLUS
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',aeolus),
          targetTable=paste0(Sys.getenv("translated"),'.',aeolus),
          stcmTable=stcmTable,
          translationSql="aeolus.sql")

################################################################################
# MEDLINE
################################################################################

#COOCCURRENCE
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',medline_cooccurrence),
          targetTable=paste0(Sys.getenv("translated"),'.',medline_cooccurrence),
          stcmTable=stcmTable,
          translationSql="medline.sql")

#AVILLACH
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',medline_avillach),
          targetTable=paste0(Sys.getenv("translated"),'.',medline_avillach),
          stcmTable=stcmTable,
          translationSql="medline.sql")


#PUBMED PULL
#TBD

#WINNENBURG
#tbd

#SEMMEDDB
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',semmeddb),
          targetTable=paste0(Sys.getenv("translated"),'.',semmeddb),
          stcmTable=stcmTable,
          translationSql="semmeddb.sql")

################################################################################
# PRODUCT LABELS
################################################################################

#SPLICER
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',splicer),
          targetTable=paste0(Sys.getenv("translated"),'.',splicer),
          stcmTable=stcmTable,
          translationSql="splicer.sql")

#EUPLADR
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',euPlAdr),
          targetTable=paste0(Sys.getenv("translated"),'.',euPlAdr),
          stcmTable=stcmTable,
          translationSql="euPlAdr.sql")

