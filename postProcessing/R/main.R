execute <- function(connectionDetails, source, executionLog, releaseVersion){

  sourceId <- 'COMMONEVIDENCEMODEL'
  packageName <- "postProcessing"
  releaseDate <- Sys.Date()

  writeLogs(connectionDetails = connectionDetails,
            packageName = packageName,
            sourceId = sourceId,
            source = fqSource,
            executionLog = fqExecutionLog,
            releaseDate = releaseDate,
            releaseVersion = releaseVersion)

}
