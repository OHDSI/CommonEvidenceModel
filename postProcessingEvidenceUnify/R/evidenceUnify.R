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

#' Pubmed Pull
#'
#' @param conn connection information
#'
#' @param targetDbSchema what schema do you want to write to
#'
#' @param targetTable what table do you want to store in
#'
#' @param sourceSchema where can evidence be located
#'
#' @export
evidenceUnify <- function(conn,targetDbSchema,targetTable,sourceSchema){

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "evidence_unify.sql",
                                           packageName = "postProcessingEvidenceUnify",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           sourceSchema=sourceSchema,
                                           tableName=paste0(targetDbSchema,'.',targetTable))
  DatabaseConnector::executeSql(conn=conn,sql)

}
