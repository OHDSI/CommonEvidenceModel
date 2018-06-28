writeLogs <- function(connectionDetails,packageName,sourceId,source,executionLog,releaseDate,releaseVersion){
  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "writeLogs.sql",
                                           packageName = packageName,
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           sourceId = sourceId,
                                           source = source,
                                           executionLog = executionLog,
                                           releaseDate = releaseDate,
                                           releaseVersion = releaseVersion)
  DatabaseConnector::executeSql(conn=conn,sql)
}
