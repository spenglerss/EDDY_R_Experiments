library(httr)
library(jsonlite)

# Experiments to get results from EDDY Matching Engine as a Proof Of Concept for the ability to analyze the information in real-time

url = 'http://drupal-issvc.eddyprod.local/EDDY.IS.MatchingEngine.Service/MatchingService.svc/json/GetInstitutions'
body_stuff <- fromJSON('{"directoryMatchRequest":{"TrackGuid":"351C687F-E7A2-42F8-A3AA-31B4D4C792F2","MaxResultsCount":5,"ProspectInput":{"FirstName":"san","LastName":"sad","StateId":32,"CountryId":4,"PostalCode":"07070","IsCitizen":"true"},"SortMethod":1}}')


r <- POST(url = url, body = body_stuff, encode = "json", verbose())

r
warn_for_status(r)
r$content

 content(r, "text")

results <- fromJSON(content(r, "text"))




