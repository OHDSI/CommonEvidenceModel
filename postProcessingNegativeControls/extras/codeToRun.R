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

library(postProcessingNegativeControls)

################################################################################
# VARIABLES
################################################################################
sourceData <- paste0(Sys.getenv("patient_schema"),".dbo")
vocabulary <-"VOCABULARY.dbo"
fqSTCM <- paste0(vocabulary,".CEM_SOURCE_TO_CONCEPT_MAP")

faers <- paste0(Sys.getenv("translated"),".AEOLUS")
splicer <- paste0(Sys.getenv("translated"),".SPLICER")
ade <- paste0(Sys.getenv("translated"),".MEDLINE_AVILLACH")

conceptUniverseData <- paste0(Sys.getenv("evidence"),".NC_CONCEPT_UNIVERSE")
conceptsToExcludeData <- paste0(Sys.getenv("evidence"),".NC_EXCLUDED_CONCEPTS")
conceptsToIncludeData <- paste0(Sys.getenv("evidence"),".NC_INCLUDED_CONCEPTS")
indicationData <- paste0(Sys.getenv("evidence"),".NC_INDICATIONS")
evidenceData <- paste0(Sys.getenv("evidence"),".NC_EVIDENCE")
broadConceptsData <- paste0(Sys.getenv("evidence"),".NC_BROAD_CONDITIONS")
drugInducedConditionsData <- paste0(Sys.getenv("evidence"),".NC_DRUG_INDUCED_CONDITIONS")
pregnancyConditionData <- paste0(Sys.getenv("evidence"),".NC_PREGNANCY_CONDITIONS")
safeConceptData <- paste0(Sys.getenv("evidence"),".NC_SAFE_CONCEPTS")
splicerConditionData <- paste0(Sys.getenv("evidence"),".NC_SPLICER_CONDITIONS")
faersConceptsData <- paste0(Sys.getenv("evidence"),".NC_FAERS_CONCEPTS")
adeSummaryData <- paste0(Sys.getenv("evidence"),".NC_ADE_SUMMARY")
summaryData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY")
summaryOptimizedData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY_OPTIMIZED")

################################################################################
# CONFIG
################################################################################
outcomeOfInterest <- 'condition'
conceptsOfInterest <- '40241331,1310149'
conceptsToExclude <- '374060,4108356,4110192,4043731,372924,375557,441874,
                      376713,439847,436430,4174299,432923,439040,443752,441709,4017105,252477,42873157,
                      4280942,28779,198798,4112183,194382,192671,196436,4338225,194158,194395'
conceptsToInclude <- '28060,134438,194083,254443,374048,441542,2109919,2212542,2212830,2212884,2212945,2213440,2213473,2313636,4005823,35406331,35406349,35406361,35406391,35406402,35506612,35506621,35607337,35607461,36110386,36110587,36110933,36110951,36211101,36313741,36314156,36315380,36315910,36315934,36416637,36416695,36516895,36516905,36516909,36617158,36617163,36617187,36617553,36718555,36918850,36919212,37019460,37119529,37119607,37320079,37320098,37320318,37403846,37420358,37520888,37521024,37522022'
fileName <-paste0("EPI465_NEGATIVE_CONTROLS_",Sys.Date(),".xlsx")

################################################################################
# FIND POTENTIAL CONCEPTS
################################################################################
#For a given concept of interest, find concepts after to be used for the
#outcome of interest
conceptUniverse <- findConceptUniverse(connPatientData=connPatientData,
                                       schemaRaw=sourceData,
                                       conn=conn,
                                       storeData=conceptUniverseData,
                                       outcomeOfInterest=outcomeOfInterest,
                                       conceptsOfInterest = conceptsOfInterest)

################################################################################
# FIND CONDITIONS OF INTEREST
################################################################################

#BROAD CONDITIONS
findConcepts(conn = conn,
             storeData = broadConceptsData,
             vocabulary=vocabulary,
             conceptUniverseData=conceptUniverseData,
             sqlFile="broadConcepts.sql")

#DRUG RELATED
findConcepts(conn = conn,
             storeData = drugInducedConditionsData,
             conceptUniverseData=conceptUniverseData,
             sqlFile="drugRelatedConditions.sql")

#PREGNANCY
findConcepts(conn = conn,
             storeData = pregnancyConditionData,
             conceptUniverseData=conceptUniverseData,
             sqlFile="pregnancyConditions.sql")

#SPLICER
findSplicerConditions(conn=conn,
                    storeData=splicerConditionData,
                    splicerData=splicer,
                    sqlFile="splicerConditions.sql",
                    conceptsOfInterest=conceptsOfInterest,
                    vocabulary=vocabulary)

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
findFaersADRs(conn = conn,
              faersData = faers,
              storeData = faersConceptsData,
              vocabulary=vocabulary,
              conceptsOfInterest=conceptsOfInterest,
              outcomeOfInterest = outcomeOfInterest)


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
                  splicerConditionData=splicerConditionData,
                  faersConceptsData=faersConceptsData,
                  conceptsToExclude=conceptsToExcludeData,
                  conceptsToInclude=conceptsToIncludeData)

################################################################################
# OPTIMIZE
################################################################################
optimizeEvidence(conn=conn,
                 storeData=summaryOptimizedData,
                 vocabulary=vocabulary,
                 summaryData=summaryData)

################################################################################
# EXPORT
################################################################################
export(conn = conn,
       file=fileName,
       vocabulary = vocabulary,
       conceptsOfInterest = conceptsOfInterest,
       conceptsToExcludeData = conceptsToExcludeData,
       conceptsToIncludeData = conceptsToIncludeData,
       summaryData = summaryData,
       summaryOptimizedData = summaryOptimizedData,
       adeSummaryData = adeSummaryData)
