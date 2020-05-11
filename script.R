# Load packages
library(readr)
library(dplyr)
library(tidyr)

# Load data in R
combined <- read_csv("data/combined.csv")
survey <- read_tsv("data/masterfile11_gened_final.txt")
survey_d75 <- read_tsv("data/masterfile11_d75_final.txt")