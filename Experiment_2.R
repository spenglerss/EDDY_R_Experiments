library(tidyr)
library(dplyr)

oct2018_sample_data2 <- read.csv("~/R/EDDY_R_Experiments/Oct2018SampleData_Pivot_1.csv", header = TRUE)


# Let's only keep TrackIDs where at least ten CountAgainstCap lead occured
use_data <- oct2018_sample_data2[oct2018_sample_data2$Grand.Total > 10,]

