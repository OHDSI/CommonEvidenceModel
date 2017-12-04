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

#' Find Splicer Conditions
#'
#' @param conn  Connection information where analysis performed
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @param splicerData where the splicer Data is stored
#'
#' @param sqlFile where can you find the SQL
#'
#' @param conceptsOfInterest what are the drugs of interest
#'
#' @param vocabulary where can the Vocab be found
#'
#' @export
findSplicerConditions <- function(conn,storeData,splicerData,sqlFile,conceptsOfInterest,vocabulary){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           splicerData=splicerData)
  DatabaseConnector::executeSql(conn=conn,sql)
}
