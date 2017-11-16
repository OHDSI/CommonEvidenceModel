# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of meshTag
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

#' Generic Patient Level Data Pull
#'
#' @param conn connection information
#'
#' @param sqlFile what is the SQL file needed
#'
#' @export
genericPatientDataPull <- function(conn,sqlFile){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                           packageName = "meshTags",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL)
  df <- DatabaseConnector::querySql(conn=conn,sql)
  return(df)
}
