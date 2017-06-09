evidenceUnify <- function(schema,sourceSchema){
  tableName <- "EVIDENCE"

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
  sql <- SqlRender::readSql("./sql/EVIDENCE_UNIFY.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName)
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
