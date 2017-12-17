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
ade <- paste0(Sys.getenv("translated"),".MEDLINE_WINNENBURG")

conceptUniverseData <- paste0(Sys.getenv("evidence"),".NC_CONCEPT_UNIVERSE")
conceptsToExcludeData <- paste0(Sys.getenv("evidence"),".NC_EXCLUDED_CONCEPTS")
conceptsToIncludeData <- paste0(Sys.getenv("evidence"),".NC_INCLUDED_CONCEPTS")
indicationData <- paste0(Sys.getenv("evidence"),".NC_INDICATIONS")
evidenceData <- paste0(Sys.getenv("evidence"),".NC_EVIDENCE")
broadConceptsData <- paste0(Sys.getenv("evidence"),".NC_BROAD_CONDITIONS")
drugInducedConditionsData <- paste0(Sys.getenv("evidence"),".NC_DRUG_INDUCED_CONDITIONS")
pregnancyConditionData <- paste0(Sys.getenv("evidence"),".NC_PREGNANCY_CONDITIONS")
safeConceptData <- paste0(Sys.getenv("evidence"),".NC_SAFE_CONCEPTS")
splicerConceptData <- paste0(Sys.getenv("evidence"),".NC_SPLICER_CONCEPTS")
faersConceptsData <- paste0(Sys.getenv("evidence"),".NC_FAERS_CONCEPTS")
adeSummaryData <- paste0(Sys.getenv("evidence"),".NC_ADE_SUMMARY")
summaryData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY")
summaryOptimizedData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY_OPTIMIZED")

################################################################################
# CONFIG
################################################################################
outcomeOfInterest <- 'drug'
conceptsOfInterest <- '4344040'
conceptsToExclude <- '0'
conceptsToInclude <- '1186087,19015230,1381504,757688,1314865,715233,950933,1563600,980311,1541079,19008009,19010482,1311078,1304643,1338512,1301125,1151789,1352213,1304850,1542948,1597235,19048493,19097463,1536743,751889,19041065,787787,1512480,19117912,40238188,1112921,1351541,1192218,19024227,1305058,909841,708298,1114220,1522957,785788,1378382,19071160,19049105,753626,42903728,19090761,1584910,836208,1236744,40171288'
fileName <-paste0("NEGATIVE_CONTROLS_",Sys.Date(),".xlsx")

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
findSplicerConcepts(conn=conn,
                    storeData=splicerConceptData,
                    splicerData=splicer,
                    sqlFile="splicerConcepts.sql",
                    conceptsOfInterest=conceptsOfInterest,
                    vocabulary=vocabulary,
                    outcomeOfInterest=outcomeOfInterest)

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
