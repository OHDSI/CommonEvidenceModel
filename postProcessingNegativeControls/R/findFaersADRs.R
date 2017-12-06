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

#' Find FAERS ADRs
#'
#' @param conn  Connection information where analysis performed
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @param conceptsofInterest What concepts do you want to look for in FAERS
#'
#' @param vocabulary where can you find a Vocabulary
#'
#' @param faersData where you can find the FAERS data
#'
#' @param outcomeOfInterest Either "condition" or "drug" to denote what type of outcome you are looking for
#'
#' @export
findFaersADRs <- function(conn,storeData,faersData,conceptsOfInterest,vocabulary,outcomeOfInterest){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "findFaersADRs.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           faersData=faersData,
                                           outcomeOfInterest=outcomeOfInterest)
  DatabaseConnector::executeSql(conn=conn,sql)
}
