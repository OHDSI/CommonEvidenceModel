# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of postProcessingNegativeControls
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

#' Optimize Evidence
#'
#' @param conn  Connection information where analysis performed
#'
#' @param storeData  Where you want to store teh data on the analysis connection
#'
#' @param summaryData Where the summarized data can be found
#'
#' @param vocabulary Schema where Vocabulary can be found
#'
#' @export
optimizeEvidence <-function(conn,storeData,summaryData,vocabulary){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "optimizeEvidence.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           vocabulary=vocabulary,
                                           summaryData=summaryData)
  DatabaseConnector::executeSql(conn=conn,sql)
}
