execute <- function(conceptsOfInterest = 0,
                    outcomeOfInterest = 'condition',
                    conceptsToExclude = 0,
                    conceptsToInclude = 0){
  ################################################################################
  # CONNECTIONS
  ################################################################################
  #Connection
  options(java.parameters = "-Xmx1024m")
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
  rm(config)

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw")
  )
  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw")
  )
  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Used when connecting to patient data to inform raw data pull
  patient_config <- read.csv("extras/config_patient_data.csv",as.is=TRUE)[1,]
  Sys.setenv(patient_dbms = patient_config$dbms)
  Sys.setenv(patient_user = patient_config$user)
  Sys.setenv(patient_pw = patient_config$pw)
  Sys.setenv(patient_server = patient_config$server)
  Sys.setenv(patient_port = patient_config$port)
  Sys.setenv(patient_schema = patient_config$schema)
  rm(patient_config)

  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("patient_dbms"),
    server = Sys.getenv("patient_server"),
    port = as.numeric(Sys.getenv("patient_port"))#,
    #user = Sys.getenv("patient_user"),
    #password = Sys.getenv("patient_pw")
  )
  connPatientData <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  ################################################################################
  # VARIABLES
  ################################################################################
  #PREPROCESSED
  conceptUniverseLookupData <- paste0(Sys.getenv("evidence"),".NC_LU_CONCEPT_UNIVERSE")
  broadConceptsData <- paste0(Sys.getenv("evidence"),".NC_LU_BROAD_CONCEPTS")
  drugInducedConditionsData <- paste0(Sys.getenv("evidence"),".NC_LU_DRUG_INDUCED_CONDITIONS")
  pregnancyConditionData <- paste0(Sys.getenv("evidence"),".NC_LU_PREGNANCY_CONDITIONS")

  sourceData <- paste0(Sys.getenv("patient_schema"),".dbo")
  vocabulary <-"VOCABULARY"
  fqSTCM <- paste0(vocabulary,".CEM_SOURCE_TO_CONCEPT_MAP")

  faers <- paste0(Sys.getenv("translated"),".AEOLUS")
  splicer <- paste0(Sys.getenv("translated"),".SPLICER")
  ade <- paste0(Sys.getenv("translated"),".MEDLINE_WINNENBURG")

  conceptUniverseData <- paste0(Sys.getenv("evidence"),".NC_CONCEPT_UNIVERSE") #Don't use if using preprocessed
  conceptsToExcludeData <- paste0(Sys.getenv("evidence"),".NC_EXCLUDED_CONCEPTS")
  conceptsToIncludeData <- paste0(Sys.getenv("evidence"),".NC_INCLUDED_CONCEPTS")
  indicationData <- paste0(Sys.getenv("evidence"),".NC_INDICATIONS")
  evidenceData <- paste0(Sys.getenv("evidence"),".NC_EVIDENCE")
  safeConceptData <- paste0(Sys.getenv("evidence"),".NC_SAFE_CONCEPTS")
  splicerConceptData <- paste0(Sys.getenv("evidence"),".NC_SPLICER_CONCEPTS")
  faersConceptsData <- paste0(Sys.getenv("evidence"),".NC_FAERS_CONCEPTS")
  adeSummaryData <- paste0(Sys.getenv("evidence"),".NC_ADE_SUMMARY")
  summaryData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY")
  summaryOptimizedData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY_OPTIMIZED")

  fileName <-paste0("NEGATIVE_CONTROLS_",Sys.Date(),".xlsx")

  ################################################################################
  # FIND POTENTIAL CONCEPTS
  ################################################################################
  #For a given concept of interest, find concepts after to be used for the
  #outcome of interest
  conceptUniverse <- findConceptUniverse(connPatientData=connPatientData,
                                         sourceData = conceptUniverseLookupData,
                                         conn=conn,
                                         storeData=conceptUniverseData,
                                         outcomeOfInterest=outcomeOfInterest,
                                         conceptsOfInterest = conceptsOfInterest,
                                         vocabulary = vocabulary)

  ################################################################################
  # FIND CONDITIONS OF INTEREST
  ################################################################################

  #SPLICER
  # findSplicerConcepts(conn=conn,
  #                     storeData=splicerConceptData,
  #                     splicerData=splicer,
  #                     sqlFile="splicerConcepts.sql",
  #                     conceptsOfInterest=conceptsOfInterest,
  #                     vocabulary=vocabulary,
  #                     outcomeOfInterest=outcomeOfInterest)

  #FIND INDICATIONS
  findDrugIndications(conn=conn,
                      storeData=indicationData,
                      vocabulary=vocabulary,
                      conceptsOfInterest=conceptsOfInterest,
                      outcomeOfInterest=outcomeOfInterest)

  #USER IDENTIFIED CONCEPTS TO EXCLUDE
  findConcepts(conn = conn,
               storeData = conceptsToExcludeData,
               vocabulary=vocabulary,
               concepts=conceptsToExclude,
               expandConcepts=1)

  #USER IDENTIFIED CONCEPTS TO INCLUDE
  findConcepts(conn = conn,
               storeData = conceptsToIncludeData,
               vocabulary=vocabulary,
               concepts=conceptsToInclude)

  #FAERS
  # findFaersADRs(conn = conn,
  #               faersData = faers,
  #               storeData = faersConceptsData,
  #               vocabulary=vocabulary,
  #               conceptsOfInterest=conceptsOfInterest,
  #               outcomeOfInterest = outcomeOfInterest)


  ################################################################################
  # PULL EVIDENCE
  ################################################################################
  pullEvidence(conn = conn,
               adeData = ade,
               storeData = adeSummaryData,
               vocabulary=vocabulary,
               conceptsOfInterest=conceptsOfInterest,
               outcomeOfInterest = outcomeOfInterest,
               conceptUniverse=conceptUniverseData)

  ################################################################################
  # SUMMARIZE EVIDENCE
  ################################################################################
  summarizeEvidence(conn=conn,
                    outcomeOfInterest=outcomeOfInterest,
                    conceptUniverseData=conceptUniverseData,
                    storeData=summaryData,
                    adeSummaryData=adeSummaryData,
                    indicationData=indicationData,
                    broadConceptsData=broadConceptsData,
                    drugInducedConditionsData=drugInducedConditionsData,
                    pregnancyConditionData=pregnancyConditionData,
                    conceptsToExclude=conceptsToExcludeData,
                    conceptsToInclude=conceptsToIncludeData)

  ################################################################################
  # OPTIMIZE
  ##############################################################################
  optimizeEvidence(conn=conn,
                   outcomeOfInterest=outcomeOfInterest,
                   storeData=summaryOptimizedData,
                   vocabulary=vocabulary,
                   summaryData=summaryData)

  ################################################################################
  # EXPORT
  ################################################################################
  export(conn = conn,
         file=fileName,
         vocabulary = vocabulary,
         outcomeOfInterest=outcomeOfInterest,
         conceptsOfInterest = conceptsOfInterest,
         conceptsToExcludeData = conceptsToExcludeData,
         conceptsToIncludeData = conceptsToIncludeData,
         summaryData = summaryData,
         summaryOptimizedData = summaryOptimizedData,
         adeSummaryData = adeSummaryData)

  ################################################################################
  # CLEAN UP
  ################################################################################
  dropTable(conn = conn,dropTable=indicationData)
  dropTable(conn = conn,dropTable=conceptsToExcludeData)
  dropTable(conn = conn,dropTable=conceptsToIncludeData)
  dropTable(conn = conn,dropTable=adeSummaryData)
  dropTable(conn = conn,dropTable=summaryData)
  dropTable(conn = conn,dropTable=summaryOptimizedData)
}
