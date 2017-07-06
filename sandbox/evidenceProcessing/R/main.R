################################################################################
   ###    ########  ##     ## #### ##    ##
  ## ##   ##     ## ###   ###  ##  ###   ##
 ##   ##  ##     ## #### ####  ##  ####  ##
##     ## ##     ## ## ### ##  ##  ## ## ##
######### ##     ## ##     ##  ##  ##  ####
##     ## ##     ## ##     ##  ##  ##   ###
##     ## ########  ##     ## #### ##    ##
################################################################################

loadSouceDefinitions <- function(schema,fileName) {
  tableName <- "SOURCE"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table
  sql <- SqlRender::readSql("./sql/SOURCE_createTable.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                         targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #Load Data
  df <- read.table(paste0("./docs/",fileName),sep="\t",header=TRUE)

  DatabaseConnector::insertTable(conn,tableName,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)

  #clean up
  RJDBC::dbDisconnect(conn)
}

medlinePubmedFindMeshTags <- function(schema,sourceSchema,filter){
  #use patient data to inform which drug Mesh tags would be valuable to review
  #looking for exposures to drugs to be considered interesting
  #using conditions associated to "chemically induced" to learn which Mesh
  #terms are conditions

  tableName <- "LU_PUBMED_MESH_TAGS"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #connect - also need a patient data to inform pull
  if(Sys.getenv("patient_user") == "NA"){
    connectionDetails <- DatabaseConnector::createConnectionDetails(
      dbms = Sys.getenv("patient_dbms"),
      server = Sys.getenv("patient_server"),
      port = as.numeric(Sys.getenv("patient_port")),
      #user =  Sys.getenv("patient_user"),
      #password = Sys.getenv("patient_pw"),
      schema = Sys.getenv("patient_schema"))
  }
  else {
    connectionDetails <- DatabaseConnector::createConnectionDetails(
      dbms = Sys.getenv("patient_dbms"),
      server = Sys.getenv("patient_server"),
      port = as.numeric(Sys.getenv("patient_port")),
      user =  Sys.getenv("patient_user"),
      password = Sys.getenv("patient_pw"),
      schema = Sys.getenv("patient_schema"))
  }

  patient_conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Grab Patient Data for Drugs
  sql <- SqlRender::readSql("./sql/MEDLINE_PUBMED_FIND_DRUG_UNIVERSE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,filter=filter)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  df <- DatabaseConnector::querySql(conn=patient_conn,translatedSql$sql)

  #Put with CEM
  DatabaseConnector::insertTable(conn, tableName, df, dropTableIfExists = TRUE,
              createTable = TRUE, tempTable = FALSE, oracleTempSchema = NULL)

  #Pull Conditions and put in CEM
  sql <- SqlRender::readSql("./sql/MEDLINE_PUBMED_FIND_CONDITION_UNIVERSE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,filter=filter, sourceSchema= sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  df <- DatabaseConnector::querySql(conn=conn,translatedSql$sql)

  DatabaseConnector::insertTable(conn, tableName, df, dropTableIfExists = FALSE,
                              createTable = FALSE, tempTable = FALSE, oracleTempSchema = NULL)

  #clean up
  RJDBC::dbDisconnect(conn)
  RJDBC::dbDisconnect(patient_conn)

  return(tableName)
}

################################################################################
##     ##  #######   ######     ###    ########
##     ## ##     ## ##    ##   ## ##   ##     ##
##     ## ##     ## ##        ##   ##  ##     ##
##     ## ##     ## ##       ##     ## ########
 ##   ##  ##     ## ##       ######### ##     ##
  ## ##   ##     ## ##    ## ##     ## ##     ##
   ###     #######   ######  ##     ## ########
################################################################################

cdmSTCM <- function(fqTableName,vocabulary,umls) {

    #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"))

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/CEM_SOURCE_TO_CONCEPT_MAP.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,
                                      fqTableName=fqTableName,
                                      vocabulary=vocabulary,
                                      umls=umls)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #Load Manual Maps
  df <- read.csv(file="./docs/EU_PL_ADR_SUBSTANCES_TO_STANDARD.csv",
                 sep=",",header=TRUE)

  DatabaseConnector::insertTable(conn,fqTableName,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)

  #clean up
  rm(df)
  RJDBC::dbDisconnect(conn)
}


################################################################################
   ###    ########  #######  ##       ##     ##  ######
  ## ##   ##       ##     ## ##       ##     ## ##    ##
 ##   ##  ##       ##     ## ##       ##     ## ##
##     ## ######   ##     ## ##       ##     ##  ######
######### ##       ##     ## ##       ##     ##       ##
##     ## ##       ##     ## ##       ##     ## ##    ##
##     ## ########  #######  ########  #######   ######
################################################################################

aeolusClean <- function(schema,sourceSchema) {
  tableName <- "AEOLUS_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/AEOLUS_CLEAN.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

aeolusTranslate <- function(schema) {
  tableName <- "AEOLUS"
  sourceTableName <- "AEOLUS_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/AEOLUS_TRANSLATE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
##     ## ######## ########  ##       #### ##    ## ########
###   ### ##       ##     ## ##        ##  ###   ## ##
#### #### ##       ##     ## ##        ##  ####  ## ##
## ### ## ######   ##     ## ##        ##  ## ## ## ######
##     ## ##       ##     ## ##        ##  ##  #### ##
##     ## ##       ##     ## ##        ##  ##   ### ##
##     ## ######## ########  ######## #### ##    ## ########
################################################################################

medlineAvillachClean <-function(schema,sourceSchema,pullName,drugQualifier,
                                conditionQualifier) {
  options(scipen=999)

  tableName <- paste0(pullName,"_CLEAN")

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table
  sql <- SqlRender::readSql("./sql/MEDLINE_AVILLACH_CLEAN_1.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema,
                                      drugQualifier=drugQualifier,
                                      conditionQualifier=conditionQualifier)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #Find Max PMID and how to iterate to it
  sql <- paste0("SELECT MAX(PMID) AS MAX_PMID
          FROM (
          	SELECT PMID FROM ",sourceSchema,".dbo.medcit_art_abstract_abstracttext
          	UNION ALL
          	SELECT pmid FROM ",sourceSchema,".dbo.medcit_otherabstract_abstracttext
          ) z");
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  maxPMID <- DatabaseConnector::querySql(conn=conn,translatedSql$sql)

  iterateToPMID <- round(maxPMID[1,1],(nchar(maxPMID[1,1])-1)*-1)

  iterater <- as.data.frame(cbind(seq(0, iterateToPMID, by = 1000000),
                append(seq(999999, iterateToPMID, by = 1000000), iterateToPMID)))
  colnames(iterater) <- c("start","end")

  iteraterNum <- nrow(iterater)

  #Iterate over query
  for(i in 1:iteraterNum){
    print(paste0(i,":",iteraterNum,"- Start: ",iterater$start[i]," End: ",iterater$end[i]," of ",iterateToPMID," (",maxPMID,")"))

    sql <- SqlRender::readSql("./sql/MEDLINE_AVILLACH_CLEAN_2.sql")
    renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                        sourceSchema=sourceSchema,
                                        drugQualifier=drugQualifier,
                                        conditionQualifier=conditionQualifier,
                                        tableName = tableName,
                                        start=iterater$start[i],
                                        end=iterater$end[i],
                                        pullName=pullName)
    translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                             targetDialect=Sys.getenv("dbms"))
    DatabaseConnector::executeSql(conn=conn,translatedSql$sql)
  }

  #Create index
  sql <- paste0("CREATE INDEX IDX_UNIQUE_",tableName,"_SOURCE_CODE_1_SOURCE_CODE_2 ON ",tableName," (SOURCE_CODE_1,SOURCE_CODE_2);");
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

medlineAvillachTranslated <- function(pullName,sourceToConceptMap) {
  tableName <- pullName
  sourceTableName <- paste0(pullName,"_CLEAN")

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"))

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/MEDLINE_AVILLACH_TRANSLATE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceTableName=sourceTableName,
                                      sourceToConceptMap=sourceToConceptMap)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

####################

medlinePubmedClean <-function(schema,sourceSchema){
  tableName <- "MEDLINE_PUBMED_CLEAN"
  tableNameForPrep <- paste0(tableName,"_PREP")
  tableNameForPrepTemp <- paste0(tableNameForPrep,"TEMP")

  queryFilter <- "hasabstract[text] AND English[lang] AND humans[MeSH Terms]"

  #learning what MeSH tags to pull in PubMed
  print("Finding MeSH Tags")
  meshTagsTableName <- medlinePubmedFindMeshTags(schema="CEM",
                                                 sourceSchema = "MEDLINE",
                                                 filter = 100)
  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #grab the MeSH tags just pulled
  meshTags <- as.data.frame(DatabaseConnector::querySql(conn=conn,
                                    paste0("SELECT * FROM ",meshTagsTableName)))

  meshTagNum <- nrow(meshTags)

  #prep for pull
  print("Pulling Information from Medline")
  sql <- SqlRender::readSql("./sql/MEDLINE_PUBMED_CLEAN_1.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableNameForPrep)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #pubmed pull
  for(i in 1:meshTagNum){
    print(paste0('PUBMED PULL: ',i,":",meshTagNum," - ", meshTags$MESH_SOURCE_NAME[i]))

    query <- paste(shQuote(URLencode(meshTags$MESH_SOURCE_NAME[i],reserved = TRUE)),
                   queryFilter,sep=" AND ")

    res <- RISmed::EUtilsSummary(query, type="esearch", db="pubmed", datetype='pdat',
                                 retmax=99999999)

    df <- data.frame(rep(meshTags$MESH_SOURCE_CODE[i],res@count),
                       rep(meshTags$MESH_SOURCE_NAME[i],res@count),
                       rep(meshTags$MESH_TYPE[i],res@count),
                       as.numeric(RISmed::QueryId(res)))

    colnames(df) <-c("MESH_CODE","MESH_NAME","MESH_TYPE","PMID")

    DatabaseConnector::insertTable(conn,tableNameForPrepTemp,df,
                                   dropTableIfExists = TRUE,
                                   createTable = TRUE,
                                   tempTable = FALSE)

    rm(df)

    DatabaseConnector::executeSql(conn, paste0("INSERT INTO ",tableNameForPrep,
                                               "(MESH_CODE, MESH_NAME, MESH_TYPE, PMID) SELECT * FROM ",
                                               tableNameForPrepTemp))

    DatabaseConnector::executeSql(conn, paste0("DROP TABLE ",tableNameForPrepTemp))
  }

  #Find distinct MeSH drug/condition pairs
  print("Find Distinct MeSH Drug/Condition Pairs")
  meshPairs <- as.data.frame(DatabaseConnector::querySql(conn=conn,
              paste0("	SELECT *
                        	FROM (
                        		SELECT DISTINCT MESH_CODE AS DRUG_MESH_CODE, MESH_NAME AS DRUG_MESH_NAME
                        		FROM ",tableNameForPrep,"
                        		WHERE MESH_TYPE = 'DRUG'
                        	) z
                        	CROSS JOIN (
                        		SELECT DISTINCT MESH_CODE AS CONDITION_MESH_CODE, MESH_NAME AS CONDITION_MESH_NAME
                        		FROM ",tableNameForPrep,"
                        		WHERE MESH_TYPE = 'CONDITION'
                        	) x")))

  meshPairsNum <- nrow(meshPairs)

  #The data explode in size if we listed every drug/condition pairs's PMIDs
  #so we will summarize how many at each

  #create table
  sql <- SqlRender::readSql("./sql/MEDLINE_PUBMED_CLEAN_2.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #run query for each pair
  for(i in 1:meshPairsNum){
    print(paste0("SUMMARIZE PAIRS: ",i,":",meshPairsNum," - ",meshPairs$DRUG_MESH_NAME[i]," : ",meshPairs$CONDITION_MESH_NAME[i]))

    sql <- SqlRender::readSql("./sql/MEDLINE_PUBMED_CLEAN_3.sql")
    renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                        tableNameForPrep=tableNameForPrep,
                                        drug = meshPairs$DRUG_MESH_CODE[i],
                                        condition = meshPairs$CONDITION_MESH_CODE[i])
    translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                             targetDialect=Sys.getenv("dbms"))
    DatabaseConnector::executeSql(conn=conn,translatedSql$sql)
  }

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
 ######  ########  ##       ####  ######  ######## ########
##    ## ##     ## ##        ##  ##    ## ##       ##     ##
##       ##     ## ##        ##  ##       ##       ##     ##
 ######  ########  ##        ##  ##       ######   ########
      ## ##        ##        ##  ##       ##       ##   ##
##    ## ##        ##        ##  ##    ## ##       ##    ##
 ######  ##        ######## ####  ######  ######## ##     ##
################################################################################

splicerClean <- function(schema,sourceSchema){
  tableName <- "SPLICER_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SPLICER_CLEAN.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

splicerTranlate <- function(schema){
  tableName <- "SPLICER"
  sourceTableName <- "SPLICER_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SPLICER_TRANSLATE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
 ######  ######## ##     ## ##     ## ######## ########  ########  ########
##    ## ##       ###   ### ###   ### ##       ##     ## ##     ## ##     ##
##       ##       #### #### #### #### ##       ##     ## ##     ## ##     ##
 ######  ######   ## ### ## ## ### ## ######   ##     ## ##     ## ########
      ## ##       ##     ## ##     ## ##       ##     ## ##     ## ##     ##
##    ## ##       ##     ## ##     ## ##       ##     ## ##     ## ##     ##
 ######  ######## ##     ## ##     ## ######## ########  ########  ########
################################################################################


semMedDbClean <- function(schema,sourceSchema){
  tableName <- "SEMMEDDB_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SEMMEDDB_CLEAN.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

semMedDbTranslate  <- function(schema){
  tableName <- "SEMMEDDB"
  sourceTableName <- "SEMMEDDB_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/SEMMEDDB_TRANSLATE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

################################################################################
######## ##     ##    ########  ##             ###    ########  ########
##       ##     ##    ##     ## ##            ## ##   ##     ## ##     ##
##       ##     ##    ##     ## ##           ##   ##  ##     ## ##     ##
######   ##     ##    ########  ##          ##     ## ##     ## ########
##       ##     ##    ##        ##          ######### ##     ## ##   ##
##       ##     ##    ##        ##          ##     ## ##     ## ##    ##
########  #######     ##        ########    ##     ## ########  ##     ##
################################################################################

euSplAdrClean<- function(schema,sourceSchema){
  tableName <- "EU_SPL_ADR_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/EU_SPL_ADR_CLEAN.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,
                                      sourceSchema=sourceSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}

euSplAdrTranslate  <- function(schema){
  tableName <- "EU_SPL_ADR"
  sourceTableName <- "EU_SPL_ADR_CLEAN"

  #connect
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #Create Table & Load Data
  sql <- SqlRender::readSql("./sql/EU_SPL_ADR_TRANSLATE.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,tableName=tableName,sourceTableName=sourceTableName)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #clean up
  RJDBC::dbDisconnect(conn)
}


