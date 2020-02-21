execute <- function(source, executionLog, releaseVersion){

  ################################################################################
  # CONNECTION
  ################################################################################
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

  ################################################################################
  # VARIABLES
  ################################################################################
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw")
  )

  sourceId <- 'COMMONEVIDENCEMODEL'
  packageName <- "postProcessing"
  releaseDate <- Sys.Date()

  ################################################################################
  # WORK
  ################################################################################
  writeLogs(connectionDetails = connectionDetails,
            packageName = packageName,
            sourceId = sourceId,
            source = fqSource,
            executionLog = fqExecutionLog,
            releaseDate = releaseDate,
            releaseVersion = releaseVersion)

}
