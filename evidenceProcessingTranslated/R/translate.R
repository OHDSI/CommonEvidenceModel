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

#' Translate
#'
#' @param conn connection information
#'
#' @param sourceTable where will we get the information to translate
#'
#' @param targetTable what table do you want to store in
#'
#' @param stcmTable where is the lookup file
#'
#' @param translationSql sql to do the translation
#'
#' @export
translate <- function(conn,sourceTable,targetTable,stcmTable,
                      translationSql){

  sql <- SqlRender::readSql(paste0("./inst/sql/sql_server/",translationSql))
  renderedSql <- SqlRender::renderSql(sql=sql,
                                      targetTable=targetTable,
                                      sourceTable=sourceTable,
                                      stcmTable=stcmTable)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

}
