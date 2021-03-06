library(httr)
library(jsonlite)
library(odbc)

# Experiments to get results from EDDY Matching Engine as a Proof Of Concept for the ability to analyze the information in real-time

GetInstitutions_url = 'http://drupal-issvc.eddyprod.local/EDDY.IS.MatchingEngine.Service/MatchingService.svc/json/GetInstitutions'
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





GetIntitutions_body1 <- list(
  "directoryMatchRequest" = list(
    "TrackGuid" = "351C687F-E7A2-42F8-A3AA-31B4D4C792F2",
    "MaxResultsCount" = 7,
    "MaxNestedProgramCount" = 2,
    "ProspectInput" = list(
      "FirstName" = "san",
      "LastName" = "sad",
      "Email" = "blahblah123@test.com",
      "StateId" = 32,
      "CountryId" = 4,
      "PostalCode" = "07070",
      "IsCitizen" = "true"
    ),
    "SortMethod" = 1
  )
) 

GetIntitutions_body2 <- list(
  "directoryMatchRequest" = list(
    "TrackGuid" = "351C687F-E7A2-42F8-A3AA-31B4D4C792F2",
    "MaxResultsCount" = 7,
    #"MaxNestedProgramCount" = 2,
    "ProspectInput" = list(
      "FirstName" = "san",
      "LastName" = "sad",
      "Email" = "blahblah123@test.com",
      "StateId" = 32,
      "CountryId" = 4,
      "PostalCode" = "07070",
      "IsCitizen" = "true"
    ),
    "SortMethod" = 1
  )
) 


r1 <- POST(url = GetInstitutions_url, body = GetIntitutions_body1, encode = "json")
r2 <- POST(url = GetInstitutions_url, body = GetIntitutions_body2, encode = "json")

warn_for_status(r1)
warn_for_status(r2)
#r$content

# content(r, "text")

results1 <- fromJSON(content(r1, "text"))
results2 <- fromJSON(content(r2, "text"))

results1$GetInstitutionsResult$MatchResponseGuid




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
    # "MaxResultsCount" = 7,
    # "MaxNestedProgramCount" = 2,
    "ProspectInput" = list(
      "Email" = unique_test_email,
      "PostalCode" = "11432"
    ),
    "LeadCreationType" = 3,
    "IncludeSmartMatchList" = "true",
    "IncludeSchoolSelectionList" = "false"
  )
)


w1 <- POST(url = GetWizard_url, body = GetWizard_body1, encode = "json")

warn_for_status(w1)

# First you need to call Matching Engine to get the Smart Matches then you have to call it again, but for school selection
wiz_result1 <- fromJSON(content(w1,"text"))

wiz_result1$GetWizardMatchesResult$MatchResponseGuid

# For School Selection you need to modify the call to send a list with the institutionIds as exclusions:

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

sql_for_removal <- paste("SELECT mrrrj.JsonObject AS RemovalJSON, mr.RequestInput FROM EddyTracking.dbo.MatchResponseRemovalReasonJson mrrrj (NOLOCK)
INNER JOIN EddyTracking.dbo.MatchResponse mr (NOLOCK) ON mr.MatchResponseId = mrrrj.MatchResponseId
WHERE mr.MatchResponseGUID = '",wiz_result1$GetWizardMatchesResult$MatchResponseGuid, "'", sep = "")


sql_results_clust <- dbFetch(dbSendQuery(con_reportcluster01,sql_for_removal))
# sql_results_prod <- dbFetch(dbSendQuery(con_eddyprod,sql_for_removal))

removal_JSON_as_list_clust <- fromJSON(sql_results_clust$RemovalJSON)
#removal_JSON_as_list_prod <- fromJSON(sql_results_prod$RemovalJSON)

requestinput_JSON_as_list_clust <- fromJSON(sql_results_clust$RequestInput)
#requestinput_JSON_as_list_prod <- fromJSON(sql_results_prod$RequestInput)


