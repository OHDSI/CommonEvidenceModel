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
# NEGATIVE CONTROLS
################################################################################

#UNIFY
evidenceUnify(schema="CEM")
