################################################################################
# CONFIG
################################################################################
source("R/main.R")

config <- read.csv("docs/config.csv",as.is=TRUE)[1,]
Sys.setenv(dbms = config$dbms)
Sys.setenv(user = config$user)
Sys.setenv(pw = config$pw)
Sys.setenv(server = config$server)
Sys.setenv(port = config$port)

#Used when connecting to patient data to inform raw data pull
patient_config <- read.csv("docs/config_patient_data.csv",as.is=TRUE)[1,]
Sys.setenv(patient_dbms = patient_config$dbms)
Sys.setenv(patient_user = patient_config$user)
Sys.setenv(patient_pw = patient_config$pw)
Sys.setenv(patient_server = patient_config$server)
Sys.setenv(patient_port = patient_config$port)
Sys.setenv(patient_schema = patient_config$schema)

#VocabMappings
fqSTCM <- "TRANSLATED.CEM_SOURCE_TO_CONCEPT_MAP"

################################################################################
# VOCAB
################################################################################
cdmSTCM(fqTableName=fqSTCM,vocabulary="vocabulary",umls="staging_umls")

################################################################################
# LOAD CEM EVIDENCE
################################################################################
#SOURCE
loadSouceDefinitions(schema="CEM",fileName="SOURCE.txt")

#AEOLUS
aeolusClean(schema="CEM", sourceSchema="AEOLUS")
aeolusTranslate(schema="CEM")

#MEDLINE WITH QUALIFIERS
medlineAvillachClean(schema="CEM", sourceSchema="MEDLINE",pullName = "MEDLINE_AVILLACH",
                         drugQualifier="AND qualifier.value = 'adverse effects'",
                         conditionQualifier="AND qualifier.value = 'chemically induced'")
medlineAvillachTranslated(schema="CEM",pullName = "MEDLINE_AVILLACH")

#MEDLINE WITHOUT QUALIFIERS
medlineAvillachClean(schema="CEM", sourceSchema="MEDLINE",
                     pullName = "MEDLINE_AVILLACH_NO_QUALIFIER",
                     drugQualifier="",
                     conditionQualifier="")
medlineAvillachTranslated(pullName = "CEM.dbo.MEDLINE_AVILLACH_NO_QUALIFIER",
                          sourceToConceptMap = "CEM.dbo.CEM_SOURCE_TO_CONCEPT_MAP")

#MEDLINE PUBMED
medlinePubmedClean(schema="CEM", sourceSchema="MEDLINE")

#SPLICER
splicerClean(schema="CEM",sourceSchema="SPLICER")
splicerTranlate(schema="CEM")

#SEMMEDDB
semMedDbClean(schema="CEM",sourceSchema="SEMMEDDB")
semMedDbTranslate(schema="CEM")

#euPLADR
euSplAdrClean(schema="CEM",sourceSchema="EU_PL_ADR")
euSplAdrTranslate(schema="CEM")
