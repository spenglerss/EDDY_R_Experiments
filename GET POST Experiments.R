library(httr)
library(jsonlite)

# Experiments to get results from EDDY Matching Engine as a Proof Of Concept for the ability to analyze the information in real-time

GetInstitutions_url = 'http://drupal-issvc.eddyprod.local/EDDY.IS.MatchingEngine.Service/MatchingService.svc/json/GetInstitutions'
GetSintitutions_body1 <- list(
  "directoryMatchRequest" = list(
    "TrackGuid" = "351C687F-E7A2-42F8-A3AA-31B4D4C792F2",
    "MaxResultsCount" = 5,
    "MaxNestedProgramCount" = 2,
    "ProspectInput" = list(
      "FirstName" = "san",
      "LastName" = "sad",
      "StateId" = 32,
      "CountryId" = 4,
      "PostalCode" = "07070",
      "IsCitizen" = "true"
    ),
    "SortMethod" = 1
  )
) 

GetSintitutions_body2 <- list(
  "directoryMatchRequest" = list(
    "TrackGuid" = "351C687F-E7A2-42F8-A3AA-31B4D4C792F2",
    "MaxResultsCount" = 5,
    #"MaxNestedProgramCount" = 2,
    "ProspectInput" = list(
      "FirstName" = "san",
      "LastName" = "sad",
      "StateId" = 32,
      "CountryId" = 4,
      "PostalCode" = "07070",
      "IsCitizen" = "true"
    ),
    "SortMethod" = 1
  )
) 

r1 <- POST(url = GetInstitutions_url, body = GetSintitutions_body1, encode = "json")
r2 <- POST(url = GetInstitutions_url, body = GetSintitutions_body2, encode = "json")

warn_for_status(r1)
warn_for_status(r2)
#r$content

# content(r, "text")

results1 <- fromJSON(content(r1, "text"))
results2 <- fromJSON(content(r2, "text"))




