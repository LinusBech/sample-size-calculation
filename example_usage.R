# --------------------
# Introduction and Setup
# --------------------

# This script demonstrates how to use the sample size calculation and 
# confidence level evaluation functions on the UCBAdmissions dataset. 
# The goal is to determine the required survey sample sizes for different 
# confidence levels and then evaluate which confidence levels have been achieved.

# Load the necessary dataset
data("UCBAdmissions")

# --------------------
# Data Preparation
# --------------------

# Transform the UCBAdmissions dataset to a suitable format
df <- as.data.frame(UCBAdmissions)
df$surveys <- round(df$Freq * 0.55)  # Assume we've conducted surveys equivalent to 55% of the total frequency.

# Summarize the data based on desired group and its variables
library(dplyr)

df <- df %>%
  group_by(Admit, Gender) %>%
  summarise(Freq = sum(Freq, na.rm = TRUE),
            surveys = sum(surveys, na.rm = TRUE)) %>%
  ungroup()

# --------------------
# Sample Size Calculation
# --------------------

# Load the functions
source("sample_size_functions.R")

# Use the sample.size.table function to calculate required sample sizes
# In this case we calculate the needed sample size for group Admitted and Rejected under "Admit" 
# and "Male" and "Female" as variable under "Gender". 
# We use the confidence levels 80, 85 and 90. Our population is "Freq" and the current sample size is "surveys"
results <- sample.size.table(c.levs = c(80, 85, 90), 
                                  dataset = df, 
                                  group = "Admit", 
                                  variable = "Gender", 
                                  population_col = "Freq", 
                                  current_sample_size_col = "surveys")

# Display the results for the 'Dept' grouping
print(results)

# --------------------
# Evaluate Confidence Levels
# --------------------

# Use the recommended_confidence_level_per_group function to evaluate achieved confidence levels
recommended_levels <- recommended_confidence_level_per_group(results)
print(recommended_levels)

# --------------------
# Discussion
# --------------------

# The results provide insights into the sample sizes required to achieve various confidence levels. 
# For instance, if we observe that certain groups haven't achieved a desired confidence level, 
# we might need to conduct more surveys in those groups. On the other hand, if all groups within 
# a grouping achieve a common confidence level, we can confidently present our findings at that level. 
# These functions help in ensuring robustness and reliability in our analyses.
