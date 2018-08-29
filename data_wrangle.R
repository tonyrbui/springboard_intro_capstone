# Intro to Data Science
# Capstone - Appliance Energy Use
# Data Wrangling

library(tibble)
library(tidyr)
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)

options(dplyr.width = Inf)

# Importing raw data
data_raw <-
  as_tibble(read_csv("data_raw.csv", col_types = cols(date = col_datetime(format = "%Y-%m-%d %H:%M:%S"))))

# Inspecting raw data
str(data_raw)
summary(data_raw)
head(data_raw)

# Checking for missing values
# NA values
which(sapply(data_raw, FUN = "is.na"))
# NAN values
which(sapply(data_raw, FUN = "is.nan"))
# No character data, so do not need to check for blank character values
# Verify that date observations are 10 minutes apart
# Create date lag variable that contains preceding datetime value
data_raw <- data_raw %>% arrange(date) %>% mutate(date_lag = lag(date, order_by = date))
# Create datetime difference variable. 
data_raw <- data_raw %>% mutate(date_diff = date - date_lag)
# Converting to numeric to inspect with summary()
data_raw <- data_raw %>% mutate(date_diff_min = as.numeric(date_diff))
summary(data_raw)
head(data_raw)
# All datetime difference values are 10 minutes apart, except first observation 
# First observation is NA. This is the expected output

# Checking for impossible values
# Infinite values
which(sapply(data_raw, FUN = "is.infinite"))
# Date seem plausible. Range is about 4.5 months as described by source
months = (max(data_raw$date) - min(data_raw$date)) / 30 
# All temperature and dewpoint readings seem plausible. Ranging from -6.6 to 29.86 Celsius (C)
# Appliance and light fixture energy use seems plausible. Ranging from 0 to 1080 Watt-hours (Wh)
# Relative humidity is a % value. Ranges between 0% and 100% as expected
# Pressure at sea-level is 760 millimeters of mercury (mmHg). Data ranges from 729.3 to 772.3 mmHg.
# Windspeed ranges between 0 and 14 meters per second (m/s)
# Visibilty ranges between 1 and 66 kilometers (km)
summary(data_raw)


# Checking for outliers with boxplots
# Spread for all the variables is very large
# Only appliance energy use had outlier observations that were above 1,000 Wh
# Typical U.S. household energy use is about 897,000 Wh per month, so 1,000 Wh does not seem unreasonable
data_boxplot_Wh <- data_raw %>% select(Appliances, lights)

boxplot(data_boxplot_Wh, main = "Energy Use (Wh)")

data_boxplot_T <- data_raw %>% select(T1, T2, T3, T4, T5, T6, T7, T8, T9, T_out, Tdewpoint)

boxplot(data_boxplot_T, main = "Temperature (C)")

data_boxplot_RH <- data_raw %>% select(RH_1, RH_2, RH_3, RH_4, RH_5, RH_6, RH_7, RH_8, RH_9, RH_out)

boxplot(data_boxplot_RH, main = "Relative Humidity %")

data_boxplot_Wh <- data_raw %>% select(Appliances, lights)

boxplot(data_raw$Press_mm_hg, main = "Atmosphere Pressure (mmHg)")

boxplot(data_raw$Windspeed, main = "Windspeed (m/s)")

boxplot(data_raw$Visibility, main = "Visibility (km)")

# Creating month, day, and weekday variables
date
