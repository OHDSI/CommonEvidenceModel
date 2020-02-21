execute <- function(evidenceUnify){
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

  ################################################################################
  # VARIABLES
  ################################################################################
  source = "source"

  ################################################################################
  # SOURCE
  ################################################################################
  sql <- "IF OBJECT_ID('@targetTable', 'U') IS NOT NULL DROP TABLE @targetTable; SELECT * INTO @targetTable FROM @sourceTable; ALTER TABLE @targetTable OWNER TO RW_GRP;"
  renderedSql <- SqlRender::renderSql(sql=sql,
                                      sourceTable = paste0(Sys.getenv("translated"),'.',source),
                                      targetTable = paste0(Sys.getenv("evidence"),'.',source))
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn, translatedSql$sql)

  ################################################################################
  # UNIFY
  ################################################################################
  evidenceUnify(conn=conn,
                targetDbSchema=Sys.getenv("evidence"),
                targetTable=evidenceUnify,
                sourceSchema=Sys.getenv("translated"))

}
