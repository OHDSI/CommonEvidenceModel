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

#' Pull Evidence for Concept of Interest
#'
#' @param conn  Connection information where analysis performed
#'
#' @param adeData What translated data contains ADE information
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @param vocabulary Schema where Vocabulary can be found
#'
#' @param conceptsOfInterest For what concept do you want to pull evidence
#'
#' @param outcomeOfInterest Either "condition" or "drug" to denote what type of outcome you are looking for
#'
#' @param conceptUniverse List of concepts we want to summarize data for
#'
#' @export
pullEvidence <- function(conn,adeData,storeData,conceptsOfInterest,vocabulary,outcomeOfInterest,conceptUniverse){
  print("### PULL EVIDENCE #####################################################")
  print("--- Table Prep")
  #create table
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "pullEvidencePrep.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData)
  DatabaseConnector::executeSql(conn=conn,sql)

  print("--- Winnenburg")
  #Winnenburg
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "pullEvidence.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           adeType = "MEDLINE_WINNENBURG",
                                           adeData="translated.MEDLINE_WINNENBURG",
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           outcomeOfInterest=outcomeOfInterest,
                                           conceptUniverseData=conceptUniverseData)
  DatabaseConnector::executeSql(conn=conn,sql)

  print("--- Product Labels")
  #product labels
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "pullEvidence.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           adeType = "SPLICER",
                                           adeData="translated.SPLICER",
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           outcomeOfInterest=outcomeOfInterest,
                                           conceptUniverseData=conceptUniverseData)
  DatabaseConnector::executeSql(conn=conn,sql)

  print("--- AEOLUS")
  #FAERS
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "pullEvidence.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData,
                                           adeType = "AEOLUS",
                                           adeData="translated.AEOLUS",
                                           vocabulary=vocabulary,
                                           conceptsOfInterest=conceptsOfInterest,
                                           outcomeOfInterest=outcomeOfInterest,
                                           conceptUniverseData=conceptUniverseData)
  DatabaseConnector::executeSql(conn=conn,sql)

  print("--- Index")
  #Index
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "pullEvidencePost.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           storeData=storeData)
  DatabaseConnector::executeSql(conn=conn,sql)
}
