################################################################################
# CONFIG
################################################################################
#Connection
config <- read.csv("extras/config.csv",as.is=TRUE)[1,]
Sys.setenv(dbms = config$dbms)
Sys.setenv(user = config$user)
Sys.setenv(pw = config$pw)
Sys.setenv(server = config$server)
Sys.setenv(port = config$port)

#connect
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("dbms"),
  server = Sys.getenv("server"),
  port = as.numeric(Sys.getenv("port")),
  user = Sys.getenv("user"),
  password = Sys.getenv("pw"))

conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

patient_config <- read.csv("extras/config_patient_data.csv",as.is=TRUE)[1,]
Sys.setenv(patient_dbms = patient_config$dbms)
Sys.setenv(patient_user = patient_config$user)
Sys.setenv(patient_pw = patient_config$pw)
Sys.setenv(patient_server = patient_config$server)
Sys.setenv(patient_port = patient_config$port)
Sys.setenv(patient_schema = patient_config$schema)

#connect - also need a patient data to inform pull
if(Sys.getenv("patient_user") == "NA"){
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("patient_dbms"),
    server = Sys.getenv("patient_server"),
    port = as.numeric(Sys.getenv("patient_port")),
    #user =  Sys.getenv("patient_user"),
    #password = Sys.getenv("patient_pw"),
    schema = Sys.getenv("patient_schema"))
} else {
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("patient_dbms"),
    server = Sys.getenv("patient_server"),
    port = as.numeric(Sys.getenv("patient_port")),
    user =  Sys.getenv("patient_user"),
    password = Sys.getenv("patient_pw"),
    schema = Sys.getenv("patient_schema"))
}
patient_conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

library(meshTags)

################################################################################
# VARIABLES
################################################################################
schemaMedline <- "staging_medline"

################################################################################
# Find Drug MeSH Tags
################################################################################
drugMesh <- genericPatientDataPull(conn=patient_conn,
                                   sqlFile="find_drug_mesh_tags.sql")

################################################################################
# Find Condition MeSH Tags
################################################################################
conditionMesh <- genericPatientDataPull(conn=patient_conn,
                                        sqlFile="find_condition_mesh_tags.sql")

conditionMeshMedline <- medlineMeshTagPull(conn=conn,
                                            sourceSchema=schemaMedline,
                                            sqlFile="find_medline_condition_mesh_tags.sql")

################################################################################
# COMBO
################################################################################
df <- unique(rbind(conditionMesh,drugMesh,conditionMeshMedline))
write.table(df,file="MeshTags.txt",sep="\t",row.names=FALSE)

