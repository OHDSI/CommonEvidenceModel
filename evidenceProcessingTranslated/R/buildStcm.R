# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of evidenceProcessingTranslated
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Build SOURCE_TO_CONCEPT_MAP
#'
#' @param conn connection information
#'
#' @param vocabulary where is the vocabulary located
#'
#' @param stcmTable where to load the STCM
#'
#' @param umlsSchema where to pick up UMLS mappings
#'
#' @export
buildStcm <- function(conn,vocabulary,stcmTable,umlsSchema){
  #Create Table & Load Data
  sql <- SqlRender::readSql("./inst/sql/sql_server/CEM_SOURCE_TO_CONCEPT_MAP.sql")
  renderedSql <- SqlRender::renderSql(sql=sql,
                                      stcmTable=stcmTable,
                                      vocabulary=vocabulary,
                                      umlsSchema=umlsSchema)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  #Load Manual Maps
  df <- read.csv(system.file("csv","EU_PL_ADR_SUBSTANCES_TO_STANDARD.csv",package="evidenceProcessingTranslated"),
                 sep=",",header=TRUE)
  DatabaseConnector::insertTable(conn,stcmTable,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)
  rm(df)

  df <- read.csv(system.file("csv","TRIFIRO_23_CONDITIONS_STCM.csv",package="evidenceProcessingTranslated"),
                 sep=",",header=TRUE)
  DatabaseConnector::insertTable(conn,stcmTable,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)
  rm(df)

}
