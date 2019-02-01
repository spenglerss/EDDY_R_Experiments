library(tidyr)
library(dplyr)

oct2018_sample_data <- read.csv("~/R/EDDY_R_Experiments/Oct2018SampleData_2.csv", header = TRUE)

new_contingency_table <- xtabs( ~ MarketingUnitId + ClientRelationshipId , data = oct2018_sample_data)

new_contingency_table2 <-  table(oct2018_sample_data$SubChannelId, oct2018_sample_data$SubChannelId)

new_contingency_table3 <-  table(oct2018_sample_data$MarketingUnitId, oct2018_sample_data$ClientRelationshipId)

is.data.frame(oct2018_sample_data)

tidyr::spread(oct2018_sample_data, MarketingUnitID)

oct2018_sample_data %>% group_by(SubChannelId, MarketingUnitId) %>% summarise(sum(CountAgainstCap)) 

oct2018_sample_data %>% group_by(SubChannelId, MarketingUnitId) %>% summarise(n())

tidyr::spread(oct2018_sample_data, MarketingUnitId, sum(CountAgainstCap))

new_test <- oct2018_sample_data %>% select(SubChannelId, MarketingUnitId, ClientRelationshipId, CountAgainstCap)

tidyr::spread(new_test,  MarketingUnitId, sum(CountAgainstCap))
