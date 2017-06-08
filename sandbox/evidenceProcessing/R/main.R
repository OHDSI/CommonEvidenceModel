loadSouceDefinitions <- function(schema,fileName) {
  tableName <- "SOURCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table
  sql <- SqlRender::readSql("./sql/SOURCE_createTable.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                         targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #Load Data
  df <- read.table(paste0("./docs/",fileName),sep="\t",header=TRUE)

  DatabaseConnector::insertTable(conn,tableName,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
   ###    ########  #######  ##       ##     ##  ######
  ## ##   ##       ##     ## ##       ##     ## ##    ##
 ##   ##  ##       ##     ## ##       ##     ## ##
##     ## ######   ##     ## ##       ##     ##  ######
######### ##       ##     ## ##       ##     ##       ##
##     ## ##       ##     ## ##       ##     ## ##    ##
##     ## ########  #######  ########  #######   ######
################################################################################

translateAEOLUS <- function(schema,sourceSchema) {
  tableName <- "AEOLUS_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/AEOLUS_T_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

evidenceAEOLUS <- function(schema) {
  tableName <- "AEOLUS_EVIDENCE"
  sourceTableName <- "AEOLUS_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/AEOLUS_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
##     ## ######## ########  ##       #### ##    ## ########
###   ### ##       ##     ## ##        ##  ###   ## ##
#### #### ##       ##     ## ##        ##  ####  ## ##
## ### ## ######   ##     ## ##        ##  ## ## ## ######
##     ## ##       ##     ## ##        ##  ##  #### ##
##     ## ##       ##     ## ##        ##  ##   ### ##
##     ## ######## ########  ######## #### ##    ## ########
################################################################################

translateMedlineAvillach <-function(schema,sourceSchema,drugQualifier,conditionQualifier) {
  tableName <- "MEDLINE_AVILLACH_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/MEDLINE_AVILLACH_T_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema,
                                      drugQualifier=drugQualifier,
                                      conditionQualifier=conditionQualifier,
                                      tableName = tableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

evidenceMedlineAvillach <- function(schema) {
  tableName <- "MEDLINE_AVILLACH_EVIDENCE"
  sourceTableName <- "MEDLINE_AVILLACH_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/MEDLINE_AVILLACH_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
 ######  ########  ##       ####  ######  ######## ########
##    ## ##     ## ##        ##  ##    ## ##       ##     ##
##       ##     ## ##        ##  ##       ##       ##     ##
 ######  ########  ##        ##  ##       ######   ########
      ## ##        ##        ##  ##       ##       ##   ##
##    ## ##        ##        ##  ##    ## ##       ##    ##
 ######  ##        ######## ####  ######  ######## ##     ##
################################################################################

translateSPLICER <- function(schema,sourceSchema){
  tableName <- "SPLICER_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SPLICER_T_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

evidenceSPLICER <- function(schema){
  tableName <- "SPLICER_EVIDENCE"
  sourceTableName <- "SPLICER_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SPLICER_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
 ######  ######## ##     ## ##     ## ######## ########  ########  ########
##    ## ##       ###   ### ###   ### ##       ##     ## ##     ## ##     ##
##       ##       #### #### #### #### ##       ##     ## ##     ## ##     ##
 ######  ######   ## ### ## ## ### ## ######   ##     ## ##     ## ########
      ## ##       ##     ## ##     ## ##       ##     ## ##     ## ##     ##
##    ## ##       ##     ## ##     ## ##       ##     ## ##     ## ##     ##
 ######  ######## ##     ## ##     ## ######## ########  ########  ########
################################################################################


translateSemMedDB <- function(schema,sourceSchema){
  tableName <- "SEMMEDDB_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SEMMEDDB_T_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

evidenceSemMedDB  <- function(schema){
  tableName <- "SEMMEDDB_EVIDENCE"
  sourceTableName <- "SEMMEDDB_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SEMMEDDB_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
######## ##     ##    ########  ##             ###    ########  ########
##       ##     ##    ##     ## ##            ## ##   ##     ## ##     ##
##       ##     ##    ##     ## ##           ##   ##  ##     ## ##     ##
######   ##     ##    ########  ##          ##     ## ##     ## ########
##       ##     ##    ##        ##          ######### ##     ## ##   ##
##       ##     ##    ##        ##          ##     ## ##     ## ##    ##
########  #######     ##        ########    ##     ## ########  ##     ##
################################################################################

translateEUPLADR<- function(schema,sourceSchema){
  tableName <- "EU_PL_ADR_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/EU_PL_ADR_T_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

evidenceEUPLADR  <- function(schema){
  tableName <- "EU_PL_ADR_EVIDENCE"
  sourceTableName <- "EU_PL_ADR_T_EVIDENCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/EU_PL_ADR_createTable_load.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
##    ## ########  ######      ###    ######## #### ##     ## ########     ######   #######  ##    ## ######## ########   #######  ##        ######
###   ## ##       ##    ##    ## ##      ##     ##  ##     ## ##          ##    ## ##     ## ###   ##    ##    ##     ## ##     ## ##       ##    ##
####  ## ##       ##         ##   ##     ##     ##  ##     ## ##          ##       ##     ## ####  ##    ##    ##     ## ##     ## ##       ##
## ## ## ######   ##   #### ##     ##    ##     ##  ##     ## ######      ##       ##     ## ## ## ##    ##    ########  ##     ## ##        ######
##  #### ##       ##    ##  #########    ##     ##   ##   ##  ##          ##       ##     ## ##  ####    ##    ##   ##   ##     ## ##             ##
##   ### ##       ##    ##  ##     ##    ##     ##    ## ##   ##          ##    ## ##     ## ##   ###    ##    ##    ##  ##     ## ##       ##    ##
##    ## ########  ######   ##     ##    ##    ####    ###    ########     ######   #######  ##    ##    ##    ##     ##  #######  ########  ######
################################################################################

ncUnify <- function(schema,sourceSchema){
  tableName <- "NEG_CON_EVIDENCE_UNIFY"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/NEGATIVE_CONTROLS_EVIDENCE_UNIFY.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}
