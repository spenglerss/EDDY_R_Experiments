library(httr)
library(jsonlite)
library(odbc)

# Experiments to get results from EDDY Matching Engine as a Proof Of Concept for the ability to analyze the information in real-time

GetWizard_url = 'http://drupal-issvc.eddyprod.local/EDDY.IS.MatchingEngine.Service/MatchingService.svc/json/GetWizardMatches'

con_reportcluster01 <- dbConnect(odbc(), 
                                 Driver = "SQL Server", 
                                 Server = "ReportCluster01", 
                                 Database = "EDDYTracking", 
                                 Trusted_Connection = "True")

con_eddyprod <- dbConnect(odbc(), 
                          Driver = "SQL Server", 
                          Server = "isdb.eddyprod.local", 
                          Database = "EDDYTracking", 
                          Trusted_Connection = "True")


# Creating a Unique Email to use so that the unique criterias in Matching Engine don't "dupe" it out:
unique_test_email <- paste("R_test_",
                           format(Sys.time(),"%YY"),
                           format(Sys.time(),"%mM"),
                           format(Sys.time(),"%dD"),
                           format(Sys.time(),"%HH"),
                           format(Sys.time(),"%MM"),
                           format(Sys.time(),"%SS"),
                           "@test.com",sep = "")


GetWizard_body1 <- list(
  "wizardMatchRequest" = list(
    "TrackGuid" = "C665917F-32A9-4444-B5A9-8AC66F5D6E79",
    "ProspectInput" = list(
      "Email" = unique_test_email,
      "PostalCode" = "11432"
    ),
    "LeadCreationType" = 3,
    "IncludeSmartMatchList" = "true",
    "IncludeSchoolSelectionList" = "false"
  )
)


# First you need to call Matching Engine to get the Smart Matches then you have to call it again, but for school selection

w1 <- POST(url = GetWizard_url, body = GetWizard_body1, encode = "json")
warn_for_status(w1)
wiz_result1 <- fromJSON(content(w1,"text"))

# wiz_result1$GetWizardMatchesResult$MatchResponseGuid

# For School Selection you need to modify 4 properties to get the School Selections:
GetWizard_body2 <- GetWizard_body1
GetWizard_body2$wizardMatchRequest$LeadCreationType <- 4
GetWizard_body2$wizardMatchRequest$IncludeSmartMatchList <- "false"
GetWizard_body2$wizardMatchRequest$IncludeSchoolSelectionList <- "true"
GetWizard_body2$wizardMatchRequest$SmartMatchedInstitutionIdList <- wiz_result1$GetWizardMatchesResult$SmartMatchList$InstitutionId

w2 <- POST(url = GetWizard_url, body = GetWizard_body2, encode = "json")
warn_for_status(w2)
wiz_result2 <- fromJSON(content(w2,"text"))

# It takes a few minutes for information to be saved to Porduction then replicated to ReportCluster01
# The rest of this needs to be run some time (like 2-5 mins) afterwards


#This SQL returns 2 JSONs 1st if the Removal Entities and the 2nd is the post request itself
sql_for_removal <- paste("SELECT mrrrj.JsonObject AS RemovalJSON, mr.RequestInput FROM EddyTracking.dbo.MatchResponseRemovalReasonJson mrrrj (NOLOCK)
INNER JOIN EddyTracking.dbo.MatchResponse mr (NOLOCK) ON mr.MatchResponseId = mrrrj.MatchResponseId
WHERE mr.MatchResponseGUID = '",wiz_result1$GetWizardMatchesResult$MatchResponseGuid, "'", sep = "")


sql_results_rptclust <- dbFetch(dbSendQuery(con_reportcluster01,sql_for_removal))
# sql_results_prod <- dbFetch(dbSendQuery(con_eddyprod,sql_for_removal))

removal_JSON_as_list_rptclust <- fromJSON(sql_results_rptclust$RemovalJSON)
#removal_JSON_as_list_prod <- fromJSON(sql_results_prod$RemovalJSON)

request_input_JSON_as_list_rptclust <- fromJSON(sql_results_rptclust$RequestInput)
#requestinput_JSON_as_list_prod <- fromJSON(sql_results_prod$RequestInput)


