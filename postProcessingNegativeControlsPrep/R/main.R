execute <- function(connectionDetails,
                    connectionDetailsPatientData,
                    ohdsiPostgres = 0,
                    vocabulary,
                    clean,
                    translated,
                    evidence,
                    patient_schema1,
                    patient_schema2,
                    patient_schema3,
                    findPotentialConcepts=FALSE,
                    ftpPotentialConcepts = FALSE,
                    findBroadConcepts=FALSE,
                    findDrugRelated=FALSE,
                    findPregnancyRelated = FALSE){
  ################################################################################
  # CONNECTIONS
  ################################################################################

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  connPatientData <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  #FTP connection info
  #configFTP <- read.csv("extras/config_ftp.csv",as.is=TRUE)[1,]
  #Sys.setenv(ftpHost = configFTP$host)
  #Sys.setenv(ftpUserid = configFTP$userid)


  ################################################################################
  # VARIABLES
  ################################################################################
  sourceData1 <- patient_schema1
  sourceData2 <- patient_schema2
  sourceData3 <- patient_schema3
  vocabulary <- vocabulary

  conceptUniverseData <- paste0(evidence,".nc_lu_concept_universe")
  broadConceptsData <- paste0(evidence,".NC_LU_BROAD_CONCEPTS")
  drugInducedConditionsData <- paste0(evidence,".NC_LU_DRUG_INDUCED_CONDITIONS")
  pregnancyConditionData <- paste0(evidence,".NC_LU_PREGNANCY_CONDITIONS")

  fileConceptUniverse <- paste0("EVIDENCE.NC_LU_CONCEPT_UNIVERSE_",Sys.Date(),".csv")

  ################################################################################
  # FIND POTENTIAL CONCEPTS
  ################################################################################
  if(findPotentialConcepts){
    #Because this file is so large, we'll pull local and put to FTP for loading
    print("Find Potential Concepts")
    conceptUniverse <- findConceptUniverse(connPatientData=connPatientData,
                                           schemaRaw1=sourceData1,
                                           schemaRaw2=sourceData2,
                                           schemaRaw3=sourceData3,
                                           conn=conn,
                                           storeData=conceptUniverseData)


    #Store to CSV
    utils::write.csv(x=conceptUniverse,fileConceptUniverse,row.names = FALSE)


  }

  if(ftpPotentialConcepts){
    #Because this file is so large, we'll pull local and put to FTP for loading
    #Put CSV on FTP
    RCurl::ftpUpload(what = fileConceptUniverse,
                     to = paste0("ftp://",Sys.getenv("ftpUserid"),":",Sys.getenv("ftpPassword"),"@",Sys.getenv("ftpHost"),"/",fileConceptUniverse))

  }

  ################################################################################
  # FIND CONDITIONS OF INTEREST
  ################################################################################

  if(findBroadConcepts){
    #BROAD CONDITIONS
    print("Find Broad Concepts")
    findConcepts(conn = conn,
                 ohdsiPostgres = ohdsiPostgres,
                 storeData = broadConceptsData,
                 vocabulary=vocabulary,
                 conceptUniverseData=conceptUniverseData,
                 sqlFile="broadConcepts.sql")
  }

  if(findDrugRelated){
    #DRUG RELATED
    print("Find Drug Related Concepts")
    findConcepts(conn = conn,
                 storeData = drugInducedConditionsData,
                 vocabulary=vocabulary,
                 conceptUniverseData=conceptUniverseData,
                 sqlFile="drugRelatedConditions.sql")
  }

  if(findPregnancyRelated){
    #PREGNANCY
    print("Find Pregnancy Concepts")
    findConcepts(conn = conn,
                 storeData = pregnancyConditionData,
                 vocabulary=vocabulary,
                 conceptUniverseData=conceptUniverseData,
                 sqlFile="pregnancyConditions.sql")
  }


}
