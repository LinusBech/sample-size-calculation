# sample-size-calculation short description
Tools for calculating and evaluating survey sample sizes. Provides functionalities to estimate required sample sizes based on desired confidence levels and assess the achieved confidence levels across different data groupings.

# Sample Size Calculation for Surveys

This repository provides tools for analysts and researchers to calculate and evaluate the necessary sample sizes for their studies based on desired confidence levels. With these functions, users can determine the sample size required for various confidence levels and evaluate the highest confidence level achieved by different groups in their data.

## Features

- **Sample Size Calculation**: Determine the required sample size for various confidence levels based on the provided data.
- **Confidence Level Evaluation**: Evaluate the highest confidence level achieved by all variables within a group.

## Functions

### 1. sample.size.table

This function calculates the required sample size for various confidence levels based on the provided data. The function can handle multiple groupings and, optionally, variables within those groupings.

Usage:

```R
results <- sample.size.table(
  c(90, 95, 99), #Your target confidence level
  data, #Your dataset 
  group = "your_group_column", 
  variable = "your_optional_variable_column", 
  population_col = "your_population_column", 
  current_sample_size_col = "your_current_sample_size_column"
)
```

### 2. recommended_confidence_level_per_group

This function evaluates the highest confidence level achieved by all variables within a group. It checks if all variables within a group have a sufficient sample size to achieve a given confidence level.

Usage: 
```R
recommended_levels <- recommended_confidence_level_per_group(results)
print(recommended_levels)
```

### Getting Started

  1. Clone this repository or download the functions.
  2. Load the functions into your R environment.
  3. Use the functions as described above with your data.

For a detailed example and advanced usage, refer to the provided example_usage.R script.

### Feedback and Contributions
Feedback, issues, and pull requests are welcome!