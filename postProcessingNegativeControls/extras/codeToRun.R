################################################################################
# CONNECTIONS
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
summaryData <- paste0(Sys.getenv("evidence"),".NC_SUMMARY")

################################################################################
# CONFIG
################################################################################
outcomeOfInterest <- 'condition'
conceptsOfInterest <- '932745,956874,942350'
conceptsToExclude <- '4329041,4113999,438112,40481517,444208,44784217,437312,435227,444202,442793,4028244,4288734,4134595,4024558,4018852,440059,4134593,4168498,315078,4025202,4022830,4116964,4180645,4134596,4145825,378444,45772120,4115105,436677,4027369,4129143,4051956,4129389,75650,197928,43530647,4103995,4113547,4171394,138255,195856,73553,432867,4041664,4179141,4178431,435524,4283893,4028970,321052,318443,432661,4182007,318800,45766714,45763613,4115106,4201554,4275722,4197065,4087640,4103662,4326403,4185932,317009,4226263,435613,4185207,4116778,4209224,4229392,4177703,4047791,4128492,201340,314658,4183452,4201402,4266809,254061,79864,4090425,40483613,4162038,30753,318459,4103192,4319447,201773,31317,4127688,4112748,194406,437541,4324838,79908,199860,4104000,4120274,434821,80502,437390,43020424,4344273,4115576,4209223,4185976,4269221,4124650,4344039,4079709,134453,378427,195588,4344027,4105886,4102562,36714559,4116962' #/*Added a few by hand using unmapped drug concepts in MEDLINE AVILLACH*/
conceptsToInclude <- '433736,4134455,440009,141825,4155902,4167354,4171549,443410,138384,440329,4291005,433125,133727,4151842'
fileName <-paste0("NEGATIVE_LOOP_DIURETICS_",Sys.Date(),".xlsx")

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


