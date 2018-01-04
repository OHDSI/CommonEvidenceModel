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

#' Find Concepts of Interest
#'
#' @param conn  Connection information where analysis performed
#'
#' @param connPatientData  Connection information for where patient data is
#'
#' @param schemaRaw  Definition of where raw patient condition data can found
#'
#' @param filter  Filter of how many exposures required to be a condition of interest
#'
#' @param storeData  Where you want to store the data on the analysis connection
#'
#' @export
findConceptUniverse <- function(conn,connPatientData,schemaRaw,filter=1000,
                                storeData){

  old<-Sys.time()
  print(paste0("Current Time: ",Sys.time()))

  #pull data
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "findConceptUniverse.sql",
                                           packageName = "postProcessingNegativeControlsPrep",
                                           dbms = attr(connPatientData, "dbms"),
                                           oracleTempSchema = NULL,
                                           schemaRaw=schemaRaw,
                                           filter=filter)
  df <- DatabaseConnector::querySql(conn=connPatientData,sql)

  #store
  DatabaseConnector::insertTable(conn=conn,
                                 tableName=storeData,
                                 data=df,
                                 dropTableIfExists = TRUE,
                                 createTable = TRUE,
                                 tempTable = FALSE,
                                 oracleTempSchema = NULL)

  #index & ownership
  sql <- paste0("CREATE INDEX IDX_LU_CONCEPT_UNIVERSE_CONCEPT_ID ON ",
                storeData," (CONCEPT_ID);
                ALTER TABLE ", storeData, " OWNER TO RW_GRP;")
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=Sys.getenv("dbms"))
  DatabaseConnector::executeSql(conn=conn,translatedSql$sql)

  print(paste0("Time Duration: ",Sys.time()-old))
  #Clean Up
  return(df)
}
