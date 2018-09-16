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

remove(list = ls())

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
# No character data, so do not need to check for blank character values

# Checking for impossible values
# Infinite values
which(sapply(data_raw, FUN = "is.infinite"))
# NAN values
which(sapply(data_raw, FUN = "is.nan"))
# Date seem plausible. Range is about 4.5 months as described by source
months = (max(data_raw$date) - min(data_raw$date)) / 30
# All temperature and dewpoint readings seem plausible. Ranging from -6.6 to 29.86 Celsius (C)
# Appliance and light fixture energy use seems plausible. Ranging from 0 to 1080 Watt-hours (Wh)
# Relative humidity is a % value. Ranges between 0% and 100% as expected
# Pressure at sea-level is 760 millimeters of mercury (mmHg). Data ranges from 729.3 to 772.3 mmHg.
# Windspeed ranges between 0 and 14 meters per second (m/s)
# Visibilty ranges between 1 and 66 kilometers (km)

# Verify that date observations are 10 minutes apart
# Create date lag variable that contains preceding datetime value
data_raw <-
  data_raw %>% arrange(date) %>% mutate(date_lag = lag(date, order_by = date))
# Create datetime difference variable.
data_raw <- data_raw %>% mutate(date_diff = date - date_lag)
# Converting to numeric to inspect with summary()
data_raw <-
  data_raw %>% mutate(date_diff_min = as.numeric(date_diff))
summary(data_raw)
head(data_raw)
# All datetime difference values are 10 minutes apart, except first observation
# First observation is NA. This is the expected output

data_raw <-
  data_raw %>% mutate(lights_on = ifelse(lights == 0, FALSE, TRUE))

# # Checking for outliers with boxplots
# # Spread for all the variables is very large
# # Only appliance energy use had outlier observations that were above 1,000 Wh
# # Typical U.S. household energy use is about 897,000 Wh per month, so 1,000 Wh does not seem unreasonable


# Creating month, day, weekday, hour, and minute variables
data_raw <-
  data_raw %>% mutate(
    date_date = date(date),
    date_time = as.POSIXct(strftime(date, format="%H:%M"),"%H:%M", tz=""),
    date_month = month(date),
    date_day = day(date),
    date_wday = wday(date),
    date_hour = hour(date),
    date_minute = minute(date)
  )

# Creating time of day variable
# Night between 00:00 and 05:59
# Morning between 06:00 and 8:59
# Midday between 09:00 and 14:59
# Afternoon between 15:00 and 17:59
# Evening between 18:00 and 23:59
data_raw <-
  data_raw %>% mutate(date_timeOfDay = ifelse(date_hour < 6, "night", ifelse(
    date_hour < 8,
    "morning",
    ifelse(
      date_hour < 15,
      "midday",
      ifelse(date_hour < 18, "afternoon", ifelse(date_hour < 22, "evening", "night"))
    )
  )))



# data_raw <-
#   data_raw %>% mutate(date_timeOfDay = ifelse(
#     date_hour < 8,
#     "night - morning",
#     ifelse(date_hour < 22, "daytime - evening", "night - morning")
#   ))

# Checking for NA or blank values
data_raw %>% filter(is.na(date_timeOfDay) | date_timeOfDay == '')

# Reordering columns
data_clean <-
  data_raw %>% select(date, date_month:date_timeOfDay, Appliances:Tdewpoint)

# Column names are already nicely formatted
# Data is already tidy.
# Each observation is specific datetime. Each variable is saved in it's own column

str(data_clean)

data_raw %>% ggplot(aes(x = date, y = Appliances, color = date_timeOfDay)) + geom_point(alpha = 0.5, size = 1)
# data_raw %>% filter(date_month == 2, date_day >= 23, date_day <= 23) %>% ggplot(aes(x = date, y = Appliances, color = date_timeOfDay)) + geom_point(alpha = 0.75, size = 1)
# data_raw %>% filter(date_month == 2, date_day >= 15, date_day <= 21) %>% ggplot(aes(x = date_time, y = Appliances)) + geom_line() + facet_grid(rows = vars(date_wday)) 

# Creating CSV output
write_csv(x = data_clean, path = "data_clean.csv")
