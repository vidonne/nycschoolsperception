# Load packages
library(readr)
library(dplyr)
library(tidyr)

# Load data in R
combined <- read_csv("data/combined.csv")
survey <- read_tsv("data/masterfile11_gened_final.txt")
survey_d75 <- read_tsv("data/masterfile11_d75_final.txt")survey

# Select needed data for analysis from Survey. Filter "High School" and select only aggregated data
survey_select <- survey %>%
  filter(schooltype == "High School") %>%
  select(dbn:aca_tot_11)

# Select needed data for analysis from Survey D75. Select only aggregated data
survey_d75_select <- survey_d75 %>%
  select(dbn:aca_tot_11)

# Combine survey and survey_d75
survey_combined <- survey_select %>%
  bind_rows(survey_d75_select)

# Rename dbn to DBN to match with combined df
survey_combined <- survey_combined %>%
  rename(DBN = dbn)

# Join combined and combined_surveys
combined_all <- combined %>%
  left_join(survey_combined, by = "DBN")