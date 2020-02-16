library(evidenceProcessingTranslated)

################################################################################
# WORK
################################################################################
execute(buildStcm = FALSE,
        pullSR_AEOLUS = FALSE,
        pullPL_SPLICER = FALSE,
        pullPL_EUPLADR = FALSE,
        pullPub_MEDLINE_COOCCURRENCE = FALSE,
        pullPub_MEDLINE_AVILLACH = FALSE,
        pullPub_MEDLINE_WINNENBURG = FALSE,
        pullPub_PUBMED = FALSE,
        pullPub_SEMMEDDB = FALSE,
        pullCT_SHERLOCK = FALSE #This takes about 10 min to run
        )


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
