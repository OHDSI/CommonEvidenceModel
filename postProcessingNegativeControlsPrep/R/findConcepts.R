# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of postProcessingNegativeControlsPrep
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

#' Find Concepts
#'
#' @param conn  Connection information where analysis performed
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @param conceptUniverseData where the condition universe is stored
#'
#' @param sqlFile where can you find the SQL
#'
#' @param vocabulary where can you find a Vocabulary
#'
#' @param concepts a comma separated list of concepts for you to review
#'
#' @param expandConcepts if you want to leverage the Vocabulary to use your concepts of interest and their desecendants.
#'
#' @export
findConcepts <- function(conn,storeData,
                         conceptUniverseData='',
                         sqlFile='',
                         vocabulary='',
                         concepts='',
                         expandConcepts=0){
  if(sqlFile!=''){
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                             packageName = "postProcessingNegativeControlsPrep",
                                             dbms = attr(conn, "dbms"),
                                             oracleTempSchema = NULL,
                                             storeData=storeData,
                                             vocabulary=vocabulary,
                                             conceptUniverseData=conceptUniverseData)
    DatabaseConnector::executeSql(conn=conn,sql)
  }

  if(sqlFile==''){
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "findConcepts.sql",
                                             packageName = "postProcessingNegativeControlsPrep",
                                             dbms = attr(conn, "dbms"),
                                             oracleTempSchema = NULL,
                                             storeData=storeData,
                                             vocabulary=vocabulary,
                                             concepts=concepts,
                                             expandConcepts=expandConcepts)
    DatabaseConnector::executeSql(conn=conn,sql)
  }

}
