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

#' Pubmed Pull
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
#' @param pullMesh do you want to find the MeSH tag universe
#'
#' @param pullPubMed do you want to pull PubMed information
#'
#' @param pubMedPullStart where do you want to start in the pull
#'
#' @param summarize do you want to summarize pubmed information
#'
#' @param summarizeStart where do you want to start summarization
#'
#' @export
pubmed <- function(conn,targetDbSchema,targetTable,sourceSchema,sourceId,
                   pullMeSh = 1,
                   pullPubMed = 1,
                   pubMedPullStart = 1,
                   summarize = 1,
                   summarizeStart = 1){

  tableName <- targetTable
  tableNameForPrep <- paste0(tableName,"_PREP")
  tableNameForPrepTemp <- paste0(tableNameForPrep,"TEMP")

  queryFilter <- "hasabstract[text] AND English[lang] AND humans[MeSH Terms]"



}
