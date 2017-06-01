source("R/main.R")

################################################################################
# PARAMETERS
################################################################################
Sys.setenv(dbms = "sql server")
Sys.setenv(user = "user")
Sys.setenv(pw = "password")
Sys.setenv(server = "server")
Sys.setenv(port = 1433)

loadEuProducLabels(schema="EU_ADR",xlsName="euProductLabels_20150530.xlsx",
                         startRow=14, colNames = TRUE)
