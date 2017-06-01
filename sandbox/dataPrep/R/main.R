loadEuProducLabels <- function(schema,xlsName,startRow, colNames) {
  tableName <- "EU_PRODUCT_LABELS"

  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = Sys.getenv("dbms"),
    server = Sys.getenv("server"),
    port = as.numeric(Sys.getenv("port")),
    user = Sys.getenv("user"),
    password = Sys.getenv("pw"),
    schema = schema)

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  df <- openxlsx::read.xlsx(xlsxFile=paste0("./docs/euProductLabels/",xlsName),
                              sheet = 1,colNames = colNames,startRow=startRow,
                            detectDates=TRUE)

  #give reasonable column names
  colnames(df)<-(c("product","substance","most_recent_SPC_date","ADR_as_on_SPC",
              "SOC","HLGT","HTL","LLT","meddra_PT","PT_code","SOC_code",
              "age_group","gender","causality","frequency","class_warning",
              "clinical_trials","post_marketing","comment"))

  #fix numeric date
  #although the dates with "optional" are in EU format
  dfRows <- nrow(df)
  for(i in 1:dfRows){
    if(grepl("*opinion*",df$most_recent_SPC_date[i])=="FALSE"){
      df$most_recent_SPC_date[i] <- as.character(as.Date(as.numeric(
        df$most_recent_SPC_date[i]),origin="1899-12-30"))
    }
    if(df$age_group[i]=="o"){
      df$age_group[i] <- 0
    }
  }

  #create table
  sql <- paste0("IF OBJECT_ID('",tableName,"', 'U') IS NOT NULL DROP TABLE ",tableName,";")
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,sourceDialect="sql server",
                               targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  sql <- stringr::str_replace_all(stringr::str_replace_all(paste0("CREATE TABLE ",tableName," (
          product         VARCHAR(500),
          substance       VARCHAR(500),
          most_recent_SPC_date VARCHAR(500),
          ADR_as_on_SPC	  VARCHAR(500),
          SOC			        VARCHAR(500),
          HLGT		        VARCHAR(500),
          HTL			        VARCHAR(500),
          LLT			        VARCHAR(500),
          meddra_PT	      VARCHAR(500),
          PT_code		      VARCHAR(500),
          SOC_code	      VARCHAR(500),
          age_group	      INT,
          gender		      INT,
          causality	      INT,
          frequency	      INT,
          class_warning	  INT,
          clinical_trials INT,
          post_marketing  INT,
          comment	        VARCHAR(2000)
        )"),"[\r\n]",""),"[\r\t]","")
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,sourceDialect="sql server",
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #insert data
  DatabaseConnector::insertTable(conn,tableName,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)
}



