# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of evidenceProcessingClean
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

#' Generic Load
#'
#' @param conn connection information
#'
#' @param targetDbSchema what schema do you want to write to
#'
#' @param targetTable what table do you want to store in
#'
#' @param sourceSchema schema where the source data resides
#'
#' @param sqlFile what is the SQL file needed
#'
#' @param vocabSchema where can the Vocabulary be found
#'
#' @export
genericLoad <- function(connectionDetails,targetDbSchema,targetTable,sourceSchema,sqlFile,
                        vocabSchema=NULL){

  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                           packageName = "evidenceProcessingClean",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           sourceId=targetTable,
                                           tableName=paste0(targetDbSchema,'.',targetTable),
                                           sourceSchema=sourceSchema,
                                           vocabSchema=vocabSchema)
  DatabaseConnector::executeSql(conn=conn,sql)

  DatabaseConnector::disconnect(conn)
}
