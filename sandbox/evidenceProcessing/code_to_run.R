source("R/main.R")

################################################################################
# PARAMETERS
################################################################################
Sys.setenv(dbms = "sql server")
Sys.setenv(user = "user")
Sys.setenv(pw = "password")
Sys.setenv(server = "server")
Sys.setenv(port = 1433)

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
translateEUPLADR(schema="CEM",sourceSchema="EU_ADR")
evidenceEUPLADR(schema="CEM")

################################################################################
# NEGATIVE CONTROLS
################################################################################

#UNIFY
ncUnify(schema="CEM")


