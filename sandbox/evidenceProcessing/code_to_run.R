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
fqSTCM <- "CEM_TRANSLATED.dbo.CEM_SOURCE_TO_CONCEPT_MAP"

################################################################################
# VOCAB
################################################################################
cdmSTCM(schema="CEM_TRANSLATED.dbo",fqTableName=fqSTCM,vocabulary="vocabulary.dbo",umls="staging_umls.dbo")

################################################################################
# LOAD CEM EVIDENCE
################################################################################
#SOURCE
loadSourceDefinitions(schema="CEM",fileName="SOURCE.txt")

#AEOLUS
aeolusClean(schema="CEM", sourceSchema="AEOLUS")
aeolusTranslate(fqSourceTableName="CEM.dbo.AEOLUS_CLEAN",
                fqTableName="CEM_TRANSLATED.dbo.AEOLUS")

#MEDLINE WITH QUALIFIERS
medlineAvillachClean(schema="CEM", sourceSchema="MEDLINE",pullName = "MEDLINE_AVILLACH",
                         drugQualifier="AND qualifier.value = 'adverse effects'",
                         conditionQualifier="AND qualifier.value = 'chemically induced'")
medlineAvillachTranslated(fqSourceTableName="CEM.dbo.MEDLINE_AVILLACH_CLEAN",
                          fqTableName="CEM_TRANSLATED.dbo.MEDLINE_AVILLACH")

#MEDLINE WITHOUT QUALIFIERS
medlineAvillachClean(schema="CEM", sourceSchema="MEDLINE",
                     pullName = "MEDLINE_AVILLACH_NO_QUALIFIER",
                     drugQualifier="",
                     conditionQualifier="")
medlineAvillachTranslated(fqSourceTableName="CEM.dbo.MEDLINE_AVILLACH_NO_QUALIFIER_CLEAN",
                          fqTableName="CEM_TRANSLATED.dbo.MEDLINE_AVILLACH_NO_QUALIFIER")

#MEDLINE PUBMED
medlinePubmedClean(schema="CEM", sourceSchema="MEDLINE",
                   pullMesh=0,
                   pullPubMed=0,
                   pubMedPullStart=1,
                   summarize=1,
                   summarizeStart=81)
#!!!STILL NEED A TRANSLATE!!!

#SPLICER
splicerClean(schema="CEM",sourceSchema="SPLICER")
splicerTranlate(fqSourceTableName="CEM.dbo.SPLICER_CLEAN",
                fqTableName="CEM_TRANSLATED.dbo.SPLICER")

#SEMMEDDB
semMedDbClean(schema="CEM",sourceSchema="SEMMEDDB")
semMedDbTranslate(fqSourceTableName="CEM.dbo.SEMMEDDB_CLEAN",
                  fqTableName="CEM_TRANSLATED.dbo.SEMMEDDB")

#euPLADR
euSplAdrClean(schema="CEM.dbo",sourceSchema="EU_SPL_ADR.dbo")
euSplAdrTranslate(fqSourceTableName="CEM.dbo.EU_PL_ADR_CLEAN",
                  fqTableName="CEM_TRANSLATED.dbo.EU_PL_ADR")
