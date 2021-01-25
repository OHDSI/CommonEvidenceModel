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
#' @param sourceID the name of the type of cooccurrence run you are performing (e.g. Avillach)
#'
#' @param pullPubMed do you want to pull PubMed information
#'
#' @param pubMedPullStart where do you want to start in the pull
#'
#' @param summarize do you want to summarize pubmed information
#'
#' @param summarizeStart where do you want to start summarization
#'
#' @param meshTags where to find the mesh tags
#'
#' @param sqlFile
#'
#' @export
pubmed <- function(conn,targetDbSchema,targetTable,sourceId,meshTags,sqlFile,
                   pullPubMed = 1,
                   pubMedPullStart = 1,
                   summarize = 1,
                   summarizeStart = 1){

  tableName <- paste0(targetDbSchema,'.',targetTable)
  tableNameForPrep <- paste0(tableName,"_PREP")
  tableNameForPrepTemp <- paste0(tableNameForPrep,"TEMP")

  #grab the MeSH tags
  meshTags <- as.data.frame(DatabaseConnector::querySql(conn=conn,
                                                        paste0("SELECT * FROM ",meshTags)))
  meshTagNum <- nrow(meshTags)
  drugsOnly <- meshTags[which(meshTags$MESH_TYPE=="DRUG"),]
  numDrugsOnly <- nrow(drugsOnly)

  if(pullPubMed==1){

    if(pubMedPullStart==1){
      #create a table to pull into
      print("Pulling Information from Medline")
      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                               packageName = "evidenceProcessingClean",
                                               dbms = attr(conn, "dbms"),
                                               oracleTempSchema = NULL,
                                               pullPubMed=pullPubMed,
                                               tableName=tableNameForPrep)
      DatabaseConnector::executeSql(conn=conn,sql)
    }

    queryFilter <- " AND hasabstract[text] AND English[lang] AND humans[MeSH Terms]"

    #pubmed pull
    for(i in pubMedPullStart:meshTagNum){
      print(paste0('PUBMED PULL: ',i,":",meshTagNum," - ", meshTags$MESH_SOURCE_NAME[i]))

      query <- paste0("(", meshTags$MESH_SOURCE_NAME[i], ")", queryFilter)

      res <- tryCatch({
        RISmed::EUtilsSummary(query, type = "esearch", db = "pubmed", datetype = 'pdat')
      }, error = function(e) {
        # connection might fail, we wait 4 seconds and try again
        # TODO: Works for now but ... add a nested tryCatch in case of failing again, add tag to a list to print or something.
        #       where item is added to list that is printed at the end of the run.
        Sys.sleep(4)
        print(paste0('ERROR PUBMED PULL FAILED - RETRY: ', i, ":", meshTagNum, " - ", meshTags$MESH_SOURCE_NAME[i]))
        RISmed::EUtilsSummary(query, type = "esearch", db = "pubmed", datetype = 'pdat')
      })


      # RISmed v 2.2 is buggy :-/, adding a maximum return value when there are no records will throw an error,
      # not adding retmax wil set it to 1000 as default causing the QueryId method to only return 1000 entries.
      # So, when there are over a thousand entries we get the summary again, this time passing a retmax...
      # Good news is that next version of RISmed has a fix for this issue.
      if (res@count >= 999) {
        res <- tryCatch({
          RISmed::EUtilsSummary(query, type = "esearch", db = "pubmed", datetype = 'pdat', retmax = 99999999)
        }, error = function(e) {
          Sys.sleep(4)
          print(paste0('ERROR PUBMED PULL FAILED - RETRY: ', i, ":", meshTagNum, " - ", meshTags$MESH_SOURCE_NAME[i]))
          return(RISmed::EUtilsSummary(query, type = "esearch", db = "pubmed", datetype = 'pdat', retmax = 99999999))
        })
      }


      df <- data.frame(rep(meshTags$MESH_SOURCE_CODE[i],res@count),
                       rep(meshTags$MESH_SOURCE_NAME[i],res@count),
                       rep(meshTags$MESH_TYPE[i],res@count),
                       as.numeric(RISmed::QueryId(res)))

      colnames(df) <-c("MESH_CODE","MESH_NAME","MESH_TYPE","PMID")

      DatabaseConnector::insertTable(conn,tableNameForPrepTemp,df,
                                     dropTableIfExists = TRUE,
                                     createTable = TRUE,
                                     tempTable = FALSE)

      rm(df)

      DatabaseConnector::executeSql(conn, paste0("INSERT INTO ",tableNameForPrep,
                                                 "(MESH_CODE, MESH_NAME, MESH_TYPE, PMID) SELECT * FROM ",
                                                 tableNameForPrepTemp))

      DatabaseConnector::executeSql(conn, paste0("DROP TABLE ",tableNameForPrepTemp))
    }
  }

  if(summarize==1){
    #The data explode in size if we listed every drug/condition pairs's PMIDs
    #so we will summarize how many at each

    if(summarizeStart==1){
      #create table
      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                               packageName = "evidenceProcessingClean",
                                               dbms = attr(conn, "dbms"),
                                               oracleTempSchema = NULL,
                                               summarizeStart=summarizeStart,
                                               tableName=tableName)
      DatabaseConnector::executeSql(conn=conn,sql)
    }
    else{
      DatabaseConnector::executeSql(conn=conn,
                                    paste0("DELETE FROM ",tableName,
                                           " WHERE SOURCE_CODE_1 = '",
                                           drugsOnly$MESH_SOURCE_CODE[summarizeStart],
                                           "'"))
    }

    #run query for each pair
    for(i in summarizeStart:numDrugsOnly){
      print(paste0("SUMMARIZE PAIRS: ",i,":",numDrugsOnly," - ",drugsOnly$MESH_SOURCE_CODE[i]))

      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                               packageName = "evidenceProcessingClean",
                                               dbms = attr(conn, "dbms"),
                                               oracleTempSchema = NULL,
                                               summarize=summarize,
                                               tableName=tableName,
                                               tableNameForPrep=tableNameForPrep,
                                               drug = drugsOnly$MESH_SOURCE_CODE[i])
      DatabaseConnector::executeSql(conn=conn,sql)
    }
  }

}
