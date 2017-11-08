# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of evidenceProcessingTranslated
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

#' Medline CoOccurrence Pull
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
#' @export
medlineCoOccurrence <- function(conn,targetDbSchema,targetTable,
                                sourceSchema,sourceID,
                                drugQualifier,conditionQualifier){


}
