source("R/main.R")
config <- read.csv("config.csv",as.is=TRUE)[1,]

################################################################################
# PARAMETERS
################################################################################
Sys.setenv(dbms = config$dbms)
Sys.setenv(user = config$user)
Sys.setenv(pw = config$pw)
Sys.setenv(server = config$server)
Sys.setenv(port = config$port)

################################################################################
# VOCAB
################################################################################

cdmSTCM(schema="CEM", sourceSchema="VOCABULARY")

################################################################################
# LOAD CEM EVIDENCE
################################################################################
#SOURCE
loadSouceDefinitions(schema="CEM",fileName="SOURCE.txt")

#AEOLUS
translateAEOLUS(schema="CEM", sourceSchema="AEOLUS")
evidenceAEOLUS(schema="CEM")

#MEDLINE
translateMedlineAvillach(schema="CEM", sourceSchema="MEDLINE",
                         drugQualifier="where qualifier.value = 'adverse effects'",
                         conditionQualifier="where qualifier.value = 'chemically induced'")
evidenceMedlineAvillach(schema="CEM")

#SPLICER
translateSPLICER(schema="CEM",sourceSchema="SPLICER")
evidenceSPLICER(schema="CEM")

#SEMMEDDB
translateSemMedDB(schema="CEM",sourceSchema="SEMMEDDB")
evidenceSemMedDB(schema="CEM")

#euPLADR
translateEUPLADR(schema="CEM",sourceSchema="EU_PL_ADR")
evidenceEUPLADR(schema="CEM")

################################################################################
# NEGATIVE CONTROLS
################################################################################

#UNIFY
ncUnify(schema="CEM")


