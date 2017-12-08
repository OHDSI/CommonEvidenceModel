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

#' Export
#'
#' @param conn  Connection information where analysis performed
#'
#' @param file name of file to export to
#'
#' @param vocabulary location of the Vocabualry
#'
#' @param conceptsOfInterest what are the concepts that we want to build negative controls for
#'
#' @param conceptsToExclude what concepts were in the exclude list
#'
#' @param conceptsToInclude what concepts were in the include list
#'
#' @param summaryData Where the summarized data can be found
#'
#' @param summaryOptimizedData where the optimized version of the summarized data can be found
#'
#' @param adeSummaryData where the ADEs and PMIDs are stored
#'
#' @export
export <- function(conn,file,vocabulary,conceptsOfInterest,conceptsToExcludeData,
                   conceptsToIncludeData,summaryData,summaryOptimizedData,adeSummaryData){

  if(file.exists(file)){
    file.remove(file)
  }

  wb1 <- openxlsx::createWorkbook()

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "exportDefinition.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           vocabulary=vocabulary,
                                           conceptsOfInterest = conceptsOfInterest,
                                           conceptsToExclude = conceptsToExclude,
                                           conceptsToInclude = conceptsToInclude)
  df <- DatabaseConnector::querySql(conn=conn,sql)
  openxlsx::addWorksheet(wb1,sheetName="Definition")
  openxlsx::writeDataTable(wb1,sheet="Definition",x=df,colNames = TRUE,rowNames = FALSE)
  rm(df)

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "exportNegativeControls.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           summaryData = summaryData)
  df <- DatabaseConnector::querySql(conn=conn,sql)
  openxlsx::addWorksheet(wb1,sheetName="All Potential Controls")
  openxlsx::writeDataTable(wb1,sheet="All Potential Controls",x=df,colNames = TRUE,rowNames = FALSE)
  rm(df)

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "exportNegativeControls.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           summaryData = summaryOptimizedData)
  df <- DatabaseConnector::querySql(conn=conn,sql)
  openxlsx::addWorksheet(wb1,sheetName="Negative Controls")
  openxlsx::writeDataTable(wb1,sheet="Negative Controls",x=df,colNames = TRUE,rowNames = FALSE)
  rm(df)

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "exportPMIDs.sql",
                                           packageName = "postProcessingNegativeControls",
                                           dbms = attr(conn, "dbms"),
                                           oracleTempSchema = NULL,
                                           adeSummaryData=adeSummaryData)
  df <- DatabaseConnector::querySql(conn=conn,sql)
  openxlsx::addWorksheet(wb1,sheetName="PubMed Articles")
  openxlsx::writeDataTable(wb1,sheet="PubMed Articles",x=df,colNames = TRUE,rowNames = FALSE)
  rm(df)

  openxlsx::saveWorkbook(wb1, file, overwrite = TRUE)
}
