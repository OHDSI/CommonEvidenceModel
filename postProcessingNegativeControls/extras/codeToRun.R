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

################################################################################
# CONFIG
################################################################################
outcomeOfInterest <- 'condition'
conceptsOfInterest <- '42904205,1119119,1151789'
#outcomeOfInterest <- 'drug'
#conceptsOfInterest <- '4323887,374343,378139,4335997,4335594,4217546,381282,4082287,4338897,4102032,4336009,4339020,378414,4082762,4198093,378423,381288,4105170,36717618,45757672,4314727,4090262,37017128,4152400,4035100,376113,380103,36717026,45757695,4338898,4334882,4334241,4313156,376964,4055484,375249,4338901,4198120,46273180,4317404,376102,46273990,45773064,4338893,4102641,46273181,439306,4147507,4218281,36716835,378413,45769873,4334242,4338896,4312115,4334883,4090258,4105171,373192,
# 195559,198177,312343,317585,320739,321314,433222,436136,436996,441051,441875,443622,4112154,4119616,4121632,4124844,4138183,4140448,4142261,4142981,4143389,4193054,4198274,4199413,4201941,4228297,4256889,37016882,37109250,37110252,37622385,37622386,37688952,37688953,37688955,37688956,37688957,37688958,37688959,37688960,37688962,37688963,37688964,37688965,37688966,37688967,37688968,40479862,40482910,40482911,40482912,40488006,40488007,40488008,40488026,40488394,40488395,40489419,40490430,40491456,40491457,40491479,40491480,40491481,40491994,40492532,42893881,42893882,42893883,43020500,44807043,46273237,46276857,46277029,46277040'
conceptsToExclude <- '0'
conceptsToInclude <- '0'
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
# EXPORT
################################################################################
dropTable(conn = conn,dropTable=indicationData)
dropTable(conn = conn,dropTable=conceptsToExcludeData)
dropTable(conn = conn,dropTable=conceptsToIncludeData)
dropTable(conn = conn,dropTable=adeSummaryData)
dropTable(conn = conn,dropTable=summaryData)
dropTable(conn = conn,dropTable=summaryOptimizedData)

