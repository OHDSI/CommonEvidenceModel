# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of evidenceProcessingClean
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

#' Medline CoOccurrence Winnenburg Pull
#'
#' @param conn connection information
#'
#' @param targetDbSchema what schema do you want to write to
#'
#' @param targetTable what table do you want to store in
#'
#' @param sourceSchema schema where the source data resides
#'
#' @param sourceID the name of the type of cooccurrence run you are performing (e.g. Avillach)
#'
#' @param qualifier define the drug qualifiers/condition qualifiers to be used (e.g. adverse effects, chemically induced)
#'
#' @export
medlineCoOccurrenceWinnenburg <- function(conn,targetDbSchema,targetTable,
                                sourceSchema,sourceID,
                                qualifier=0){

  #Find Max PMID and how to iterate to it
  options(scipen=999)
  sql <- paste0("SELECT MAX(PMID) AS MAX_PMID FROM ( SELECT PMID FROM ",
                sourceSchema,
                ".medcit_art_abstract_abstracttext UNION ALL SELECT pmid FROM ",
                sourceSchema,
                ".medcit_otherabstract_abstracttext ) z");
  renderedSql <- SqlRender::renderSql(sql=sql)
  translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                           targetDialect=attr(conn,"dbms"))
  maxPMID <- DatabaseConnector::querySql(conn=conn,translatedSql$sql)
  iterateToPMID <- round(maxPMID[1,1],(nchar(maxPMID[1,1])-1)*-1)
  iterater <- as.data.frame(cbind(seq(0, iterateToPMID, by = 1000000),
                                  append(seq(999999, iterateToPMID, by = 1000000), iterateToPMID)))
  colnames(iterater) <- c("start","end")
  iteraterNum <- nrow(iterater)

  #iterate over query
  for(i in 1:iteraterNum){
    print(paste0(i,":",iteraterNum,"- Start: ",iterater$start[i]," End: ",iterater$end[i]," of ",iterateToPMID," (",maxPMID,")"))

    sql <- SqlRender::readSql("./inst/sql/sql_server/MEDLINE_COOCURRENCE_WINNENBURG.sql")
    renderedSql <- SqlRender::renderSql(sql=sql,
                                        targetTable=paste0(targetDbSchema,'.',targetTable),
                                        i=i,
                                        iteraterNum=iteraterNum,
                                        sourceSchema=sourceSchema,
                                        qualifier=qualifier,
                                        start=iterater$start[i],
                                        end=iterater$end[i],
                                        sourceID = sourceID)
    translatedSql <- SqlRender::translateSql(renderedSql$sql,
                                             targetDialect=Sys.getenv("dbms"))
    DatabaseConnector::executeSql(conn=conn,translatedSql$sql)
  }
}
