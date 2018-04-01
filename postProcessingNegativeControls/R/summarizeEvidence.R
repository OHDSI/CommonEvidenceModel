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

#' Summarize Negative Control Information
#'
#' @param conn  Connection information where analysis performed
#'
#' @param outcomeOfInterest Either "condition" or "drug" to denote what type of outcome you are looking for
#'
#' @param conceptUniverseData what concepts are allowed.
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @param adeSummaryData Where the data of ADEs for our negative controls of interest are
#'
#' @param conceptUniverseData where the condition universe is stored
#'
#' @param broadConditionsData conditions too broad for use
#'
#' @param drugInducedConditionsData conditions associated with drug induced injury
#'
#' @param pregnancyConditionsData where are the pregnancy conditions stored
#'
#' @param Vocabulary where to get the Vocabulary
#'
#' @param fqSTCM where is the SOURCE_TO_CONCEPT_MAP located
#'
#' @param conceptsToExclude look up tabel with concepts to exclude
#'
#' @param conceptsToInclude look up table with concepts to include
#'
#' @export
summarizeEvidence <- function(conn,outcomeOfInterest,conceptUniverseData,
                              storeData,adeSummaryData,
                              indicationData,
                              broadConceptsData,drugInducedConditionsData,
                              pregnancyConditionData,
                              conceptsToExclude,conceptsToInclude){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "summarizeEvidence.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           outcomeOfInterest=outcomeOfInterest,
                                           conceptUniverseData=conceptUniverseData,
                                           storeData=storeData,
                                           adeSummaryData=adeSummaryData,
                                           indicationData=indicationData,
                                           broadConceptsData=broadConceptsData,
                                           drugInducedConditionsData=drugInducedConditionsData,
                                           pregnancyConditionData=pregnancyConditionData,
                                           conceptsToExclude=conceptsToExclude,
                                           conceptsToInclude=conceptsToInclude)
  DatabaseConnector::executeSql(conn=conn,sql)
}
