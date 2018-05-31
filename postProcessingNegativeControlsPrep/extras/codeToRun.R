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

#Used when connecting to patient data to inform raw data pull
patient_config <- read.csv("extras/config_patient_data.csv",as.is=TRUE)[1,]
Sys.setenv(patient_dbms = patient_config$dbms)
Sys.setenv(patient_user = patient_config$user)
Sys.setenv(patient_pw = patient_config$pw)
Sys.setenv(patient_server = patient_config$server)
Sys.setenv(patient_port = patient_config$port)
Sys.setenv(patient_schema1 = patient_config$schema1)
Sys.setenv(patient_schema2 = patient_config$schema2)
Sys.setenv(patient_schema3 = patient_config$schema3)
rm(patient_config)

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("patient_dbms"),
  server = Sys.getenv("patient_server"),
  port = as.numeric(Sys.getenv("patient_port"))#,
  #user = Sys.getenv("patient_user"),
  #password = Sys.getenv("patient_pw")
)
connPatientData <- DatabaseConnector::connect(connectionDetails = connectionDetails)

#FTP connection info
configFTP <- read.csv("extras/config_ftp.csv",as.is=TRUE)[1,]
Sys.setenv(ftpHost = configFTP$host)
Sys.setenv(ftpUserid = configFTP$userid)
Sys.setenv(ftpPassword = configFTP$password)

library(postProcessingNegativeControlsPrep)

################################################################################
# VARIABLES
################################################################################
sourceData1 <- paste0(Sys.getenv("patient_schema1"),".dbo")
sourceData2 <- paste0(Sys.getenv("patient_schema2"),".dbo")
sourceData3 <- paste0(Sys.getenv("patient_schema3"),".dbo")
vocabulary <-"VOCABULARY.dbo"

conceptUniverseData <- paste0(Sys.getenv("evidence"),".NC_LU_CONCEPT_UNIVERSE")
broadConceptsData <- paste0(Sys.getenv("evidence"),".NC_LU_BROAD_CONCEPTS")
drugInducedConditionsData <- paste0(Sys.getenv("evidence"),".NC_LU_DRUG_INDUCED_CONDITIONS")
pregnancyConditionData <- paste0(Sys.getenv("evidence"),".NC_LU_PREGNANCY_CONDITIONS")

fileConceptUniverse <- paste0("CONCEPT_UNIVERSE_",Sys.Date(),".xlsx")

################################################################################
# FIND POTENTIAL CONCEPTS
################################################################################
#Because this file is so large, we'll pull local and put to FTP for loading

conceptUniverse <- findConceptUniverse(connPatientData=connPatientData,
                                       schemaRaw1=sourceData1,
                                       schemaRaw2=sourceData2,
                                       schemaRaw3=sourceData3,
                                       conn=conn,
                                       storeData=conceptUniverseData)

#Store to XLS
wb1 <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb1,sheetName="CONCEPT_UNIVERSE")
openxlsx::writeDataTable(wb1,sheet="CONCEPT_UNIVERSE",x=conceptUniverse,colNames = TRUE,rowNames = FALSE)
openxlsx::saveWorkbook(wb1, fileConceptUniverse, overwrite = TRUE)

#Put XLS on FTP
RCurl::ftpUpload(what = fileConceptUniverse,
                 to = paste0("ftp://",Sys.getenv("ftpUserid"),":",Sys.getenv("ftpPassword"),"@",Sys.getenv("ftpHost"),"/",fileConceptUniverse))

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
             vocabulary=vocabulary,
             conceptUniverseData=conceptUniverseData,
             sqlFile="drugRelatedConditions.sql")

#PREGNANCY
findConcepts(conn = conn,
             storeData = pregnancyConditionData,
             vocabulary=vocabulary,
             conceptUniverseData=conceptUniverseData,
             sqlFile="pregnancyConditions.sql")
