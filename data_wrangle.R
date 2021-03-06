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
# All datetime difference values are 10 minutes apart, except first observation
# First observation is NA. This is the expected output

# Checking for outliers with boxplots
# Spread for all the variables is very large
# Only appliance energy use had outlier observations that were above 1,000 Wh
# But does not seem unrealistic
# A typical household in France uses 4760 kWh in a year
data_boxplot_Wh <- data_raw %>% select(Appliances, lights)
boxplot(data_boxplot_Wh, main = "Energy Use (Wh)")
data_boxplot_T <-
  data_raw %>% select(T1, T2, T3, T4, T5, T6, T7, T8, T9, T_out, Tdewpoint)
boxplot(data_boxplot_T, main = "Temperature (C)")
data_boxplot_RH <-
  data_raw %>% select(RH_1, RH_2, RH_3, RH_4, RH_5, RH_6, RH_7, RH_8, RH_9, RH_out)
boxplot(data_boxplot_RH, main = "Relative Humidity %")
data_boxplot_Wh <- data_raw %>% select(Appliances, lights)
boxplot(data_raw$Press_mm_hg, main = "Atmosphere Pressure (mmHg)")
boxplot(data_raw$Windspeed, main = "Windspeed (m/s)")
boxplot(data_raw$Visibility, main = "Visibility (km)")

# Creating month, day, weekday, hour, and minute variables
data_raw <-
  data_raw %>% mutate(
    date_date = date(date),
    date_time = as.POSIXct(strftime(date, format = "%H:%M"), "%H:%M", tz =
                             ""),
    date_month = month(date),
    date_day = day(date),
    date_wday = wday(date),
    date_hour = hour(date),
    date_minute = minute(date)
  )

# Creating time of day 5 variable
# Night between 22:00 and 05:59
# Morning between 06:00 and 7:59
# Midday between 08:00 and 14:59
# Afternoon between 15:00 and 17:59
# Evening between 18:00 and 21:59
data_raw <-
  data_raw %>% mutate(date_timeOfDay5 = ifelse(date_hour < 6, "night", ifelse(
    date_hour < 8,
    "morning",
    ifelse(
      date_hour < 15,
      "midday",
      ifelse(
        date_hour < 18,
        "afternoon",
        ifelse(date_hour < 22, "evening", "night")
      )
    )
  )))

# Creating time of day 2 variable
# Night - Morning between 22:00 and 07:59
# Daytime - Evening between 08:00 and 21:59
data_raw <-
  data_raw %>% mutate(date_timeOfDay2 = ifelse(
    date_hour < 8,
    "night - morning",
    ifelse(date_hour < 22, "midday - evening", "night - morning")
  ))

# Creating time of day 3 variable
# Night - Morning between 22:00 and 07:59
# Daytime - Evening between 08:00 and 21:59
data_raw <-
  data_raw %>% mutate(date_timeOfDay3 = ifelse(
    date_hour < 8,
    "night - morning",
    ifelse(date_hour < 17, "midday", ifelse(date_hour < 20, "evening", "night - morning"))
  ))

# Checking for NA or blank values
data_raw %>% filter(is.na(date_timeOfDay1) | date_timeOfDay1 == '')
data_raw %>% filter(is.na(date_timeOfDay2) | date_timeOfDay2 == '')

# Reordering columns
data_clean <-
  data_raw %>% select(date, date_date:date_timeOfDay3, Appliances:Tdewpoint)

# Creating appliances energy used scatterplot, color-coded by time of day variables
data_clean %>%
  ggplot(aes(x = date, y = Appliances, color = date_timeOfDay5)) +
  geom_point(alpha = 0.6, size = 1)
data_clean %>% ggplot(aes(x = date, y = Appliances, color = date_timeOfDay2)) +
  geom_point(alpha = 0.6, size = 1)
data_clean %>% ggplot(aes(x = date, y = Appliances, color = date_timeOfDay3)) +
  geom_point(alpha = 0.6, size = 1)


data_clean %>% filter(date_month == 4) %>% ggplot(aes(x = date, y = Appliances, color = date_wday)) +
  geom_point(alpha = 0.6, size = 1)

# data_clean %>%
#   filter(date_month == 5, date_day >= 1, date_day <= 7) %>%
#   ggplot(aes(x = date_time, y = Appliances)) +
#   geom_line() +
#   facet_grid(rows = vars(date_day))

# Column names are already nicely formatted
# Data is already tidy.
# Each observation is specific datetime. Each variable is saved in it's own column

# Creating CSV output
write_csv(x = data_clean, path = "data_clean.csv")

data_hour <- data_clean %>% group_by(date_hour) %>% summarise(mean_Appliances = mean(Appliances))

data_hour %>% ggplot(aes(x = date_hour, y = mean_Appliances)) + geom_line()

data_clean %>% ggplot(aes(x = T_out, y = Appliances)) + geom_point(alpha = 0.6, size = 1)

data_clean %>% ggplot(aes(x = T_out)) + geom_histogram(bins = 5)
