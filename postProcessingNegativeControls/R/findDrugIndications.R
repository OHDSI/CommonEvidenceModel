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

#' Find Drug Indications
#'
#' @param conn  Connection information where analysis performed
#'
#' @param storeData  Where you want to store teh data on the analysis connection
#'
#' @param conceptsOfInterest For what drug do you want to pull indications
#'
#' @param vocabulary Schema where Vocabulary can be found
#'
#' @param outcomeOfInterest Either "condition" or "drug" to denote what type of outcome you are looking for
#'
#' @export
findDrugIndications <- function(conn,storeData,conceptsOfInterest,vocabulary, outcomeOfInterest){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "findDrugIndications.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           outcomeOfInterest=outcomeOfInterest)
  DatabaseConnector::executeSql(conn=conn,sql)
}
