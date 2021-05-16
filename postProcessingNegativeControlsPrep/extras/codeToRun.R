library(postProcessingNegativeControlsPrep)

################################################################################
# SETUP
################################################################################
#Connection to CEM Data
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "redshift",
  server = Sys.getenv("CEM_SERVER"),
  user = keyring::key_get("redShiftUserName"),
  password = keyring::key_get("redShiftPassword"),
  extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

#Schema names with CEM info
vocabulary <-  "vocabulary_schema"
clean <- "clean_schema"
translated <- "translated_schema"
evidence <- "evidence_schema"

#Connection to PATIENT Data
connectionDetailsPatientData <- DatabaseConnector::createConnectionDetails(
  dbms = "redshift",
  server = Sys.getenv("DB_SERVER"),
  user = keyring::key_get("redShiftUserName"),
  password = keyring::key_get("redShiftPassword"),
  extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

patient_schema1 <- "DB1"
patient_schema2 <- "DB2"
patient_schema3 <- "DB3"

################################################################################
# WORK
################################################################################
execute(connectionDetails = connectionDetails,
        connectionDetailsPatientData = connectionDetailsPatientData,
        ohdsiPostgres = 0,                  #Running in OHDSI environment
        vocabulary = vocabulary,
        clean = clean,
        translated = translated,
        evidence = evidence,
        patient_schema1 = patient_schema1,
        patient_schema2 = patient_schema2,
        patient_schema3 = patient_schema3,
        findPotentialConcepts=FALSE,        #Need to Fix for non APS Environment
        ftpPotentialConcepts=FALSE,         #LEE LOADED MANUALLY, might remove this
        findBroadConcepts=FALSE,
        findDrugRelated=FALSE,
        findPregnancyRelated = TRUE)
