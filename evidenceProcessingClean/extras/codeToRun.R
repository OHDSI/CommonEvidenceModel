library(evidenceProcessingClean)

execute(loadSource = FALSE,
        loadSR_AEOLUS = FALSE,
        loadPL_SPLICER = FALSE,
        loadPL_EUPLADR = FALSE,
        loadCT_SHERLOCK = FALSE,
        loadPub_SEMMEDDB = TRUE)

################################################################################
# MEDLINE
################################################################################

#COOCCURRENCE
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableCoOccurrence,
                    sourceSchema=schemaMedline,
                    sourceID=tableCoOccurrence)

#AVILLACH
medlineCoOccurrence(conn=conn,
                    targetDbSchema=Sys.getenv("clean"),
                    targetTable=tableAvillach,
                    sourceSchema=schemaMedline,
                    sourceID=tableAvillach,
                    qualifier=1)

#WINNENBURG
medlineCoOccurrenceWinnenburg(conn=conn,
                              targetDbSchema=Sys.getenv("clean"),
                              targetTable=tableWinnenburg,
                              sourceSchema=schemaMedline,
                              sourceID=tableWinnenburg)

#PUBMED PULL
#requires loading of Pubmed MeSH tags from the MeshTags Package
df <- read.table("inst/csv/MeshTags.csv", header = TRUE)
DatabaseConnector::insertTable(conn=conn,
                               tableName=tableMeshTags,
                               data=df,
                               dropTableIfExists=TRUE,
                               createTable=TRUE,
                               tempTable=FALSE,
                               oracleTempSchema=NULL)
sql <- "ALTER TABLE @tableName OWNER TO RW_GRP;"
renderedSql <- SqlRender::renderSql(sql=sql,
                                    tableName = paste0(Sys.getenv("clean"),'.',tablePubmed))
translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                         targetDialect=Sys.getenv("dbms"))
DatabaseConnector::executeSql(conn, translatedSql$sql)
rm(df)

pubmed(conn,
       targetDbSchema=Sys.getenv("clean"),
       targetTable=tablePubmed,
       sourceId=tablePubmed,
       meshTags=tableMeshTags,
       sqlFile="pubmed.sql",
       pullPubMed = 0,
       pubMedPullStart = 1,
       summarize = 1,
       summarizeStart = 1044)

#bombed at
# 1423:4005 - Hepatitis, Drug-Induced -- 1424:4041 - Hepatitis, Drug-Induced
# 2540:4005 - thonzylamine - 2540:4041 - thonzylamine
# 3416:4005 - Pneumonia, Atypical Interstitial, of Cattle - 3425:4041 - Pneumonia, Atypical Interstitial, of Cattle
# 3805:4005 - Vitreoretinopathy, Proliferative

#SEMMEDDB




