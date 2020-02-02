library(evidenceProcessingTranslated)

################################################################################
# WORK
################################################################################
execute(buildStcm = FALSE,
        pullSR_AEOLUS = FALSE,
        pullPL_SPLICER = FALSE,
        pullPL_EUPLADR = FALSE,
        pullPub_SEMMEDDB = TRUE)

################################################################################
# SOURCE
################################################################################
sql <- "IF OBJECT_ID('@targetTable', 'U') IS NOT NULL DROP TABLE @targetTable; SELECT * INTO @targetTable FROM @sourceTable;"
renderedSql <- SqlRender::renderSql(sql=sql,
                                    sourceTable = paste0(Sys.getenv("clean"),'.',source),
                                    targetTable = paste0(Sys.getenv("translated"),'.',source))
translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                         targetDialect=Sys.getenv("dbms"))
DatabaseConnector::executeSql(conn, translatedSql$sql)


################################################################################
# MEDLINE
################################################################################

#COOCCURRENCE
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',medline_cooccurrence),
          targetTable=paste0(Sys.getenv("translated"),'.',medline_cooccurrence),
          id=medline_cooccurrence,
          stcmTable=stcmTable,
          translationSql="medline.sql")

#AVILLACH
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',medline_avillach),
          targetTable=paste0(Sys.getenv("translated"),'.',medline_avillach),
          id=medline_avillach,
          stcmTable=stcmTable,
          translationSql="medline.sql")

#WINNENBURG
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',medline_winnenburg),
          targetTable=paste0(Sys.getenv("translated"),'.',medline_winnenburg),
          id=medline_winnenburg,
          stcmTable=stcmTable,
          translationSql="medline.sql")

#PUBMED PULL
translate(conn=conn,
          sourceTable=paste0(Sys.getenv("clean"),'.',pubmed),
          targetTable=paste0(Sys.getenv("translated"),'.',pubmed),
          id=pubmed,
          stcmTable=stcmTable,
          translationSql="pubmed.sql")







