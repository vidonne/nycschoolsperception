# Load packages
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(stringr)

# Load data in R
combined <- read_csv("data/combined.csv")
survey <- read_tsv("data/masterfile11_gened_final.txt")
survey_d75 <- read_tsv("data/masterfile11_d75_final.txt")

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
combined_all <- left_join(combined, survey_combined, by = "DBN")

# Create a correlation matrix to find interesting relationships
cor_mat <- combined_all %>%
  select(avg_sat_score, saf_p_11:aca_tot_11) %>% # results vs perception
  cor(use = "pairwise.complete.obs")

cor_tib <- cor_mat %>%
  as_tibble(rownames = "variable")

# Look for strong correlation >0.25 or <-0.25
strong_cor <- cor_tib %>%
  select(variable, avg_sat_score) %>%
  filter(avg_sat_score > 0.25 | avg_sat_score < -0.25)

# Create scatter plot function to plot the strong correlations
create_scatter <- function(x, y) {     
  ggplot(data = combined_all) + 
    aes_string(x = x, y = y) +
    geom_point(alpha = 0.3)
}
x_var <- strong_cor$variable[2:5]
y_var <- "avg_sat_score"

map2(x_var, y_var, create_scatter)

# reshape data for analisys purpose
combined_all_longer <- combined_all %>%
  pivot_longer(cols = c(saf_p_11:aca_tot_11), names_to="survey_questions", values_to="score")
               
# Use stringr to create new variables
combined_all_longer <- combined_all_longer %>%
  mutate(response_type = str_sub(survey_questions, 4,6)) %>%
  mutate(metric = str_sub(survey_questions, 1, 3))

# Rename value to more comprehensible
combined_all_longer <- combined_all_longer %>%
  mutate(response_type = ifelse(response_type  == "_p_", "parent", 
                                ifelse(response_type == "_t_", "teacher",
                                       ifelse(response_type == "_s_", "student", 
                                              ifelse(response_type == "_to", "total", "NA")))))

# Make boxplot to see differences between parents, teachers and students.
combined_all_longer %>%
  filter(response_type != "total") %>%
  ggplot() +
  aes(x = metric, y = score, fill = response_type) +
  geom_boxplot()
               