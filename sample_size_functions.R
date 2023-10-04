# ------------------------------------------
# Function: sample.size.table
# Purpose:
#     Calculates the required sample size for various confidence levels based on the provided data.
#     The function can handle multiple groupings and optionally, variables within those groupings.
#     
# Parameters:
#     - c.levs: A vector of desired confidence levels (e.g., c(90, 95, 99)).
#     - dataset: A data frame containing the data to be analyzed.
#     - grouping: Name of the column in the dataset that defines the main groupings.
#     - variable: (Optional) Name of the column in the dataset that defines the variables within each group.
#     - population: Name of the column in the dataset that defines the total population for each variable.
#     - current_sample_size: (Optional) Name of the column in the dataset that defines the current sample size for each variable.
#     - margin: Assumed margin for the survey (default is 0.5, representing 50%).
#     - c.interval: Desired confidence interval (default is 0.05, representing 5%).
#     
# Returns:
#     A list of data frames. Each data frame represents a different grouping and contains the calculated sample sizes for each variable within that group, for each desired confidence level.
# ------------------------------------------

# Sample size function that also checks if there's a column with current sample size
sample.size.table <- function(c.levs, dataset, 
                              group = "group", 
                              variable = NULL,
                              population_col = "population", 
                              current_sample_size_col = NULL,
                              margin = 0.5, c.interval = 0.05) {
  
  # Create an empty data frame to store the results
  results_df <- data.frame()
  
  # Check if current_sample_size_col is provided and exists in dataset
  if (!is.null(current_sample_size_col) && !current_sample_size_col %in% colnames(dataset)) {
    stop("Error: The specified 'current_sample_size_col' column does not exist in the dataset.")
  }
  
  for (confidence_level in c.levs) {
    
    # Determine z.value based on confidence level
    z.val = qnorm(.5 + confidence_level / 200)
    
    # Summarize the dataset based on group and (if provided) variable
    if (!is.null(variable)) {
      summarized_data <- aggregate(dataset[, c(population_col, current_sample_size_col)], 
                                   by = list(dataset[[group]], dataset[[variable]]), 
                                   sum)
      names(summarized_data) <- c(group, variable, population_col, current_sample_size_col)
    } else {
      summarized_data <- aggregate(dataset[, c(population_col, current_sample_size_col)], 
                                   by = list(dataset[[group]]), 
                                   sum)
      names(summarized_data) <- c(group, population_col, current_sample_size_col)
    }
    
    # Calculate required sample size for each row in summarized data
    for (i in 1:nrow(summarized_data)) {
      ss = (z.val^2 * margin * (1 - margin)) / (c.interval^2)
      required_sample_size = ceiling(ss / ((ss / summarized_data[i, population_col]) + 1))
      
      if (!is.null(current_sample_size_col)) {
        enough_samples = ifelse(summarized_data[i, current_sample_size_col] >= required_sample_size, "Yes", "No")
      } else {
        enough_samples = NA
      }
      
      # Add the confidence level, required sample size, and enough samples information
      summarized_data[i, "confidence_level"] <- confidence_level
      summarized_data[i, "sample_size"] <- required_sample_size
      summarized_data[i, "enough_sample_size"] <- enough_samples
    }
    
    # Combine with the overall results
    results_df <- rbind(results_df, summarized_data)
  }
  
  # Group the results by the 'group' variable
  results_list <- split(results_df, results_df[[group]])
  
  return(results_list)
}


# ------------------------------------------
# Function: recommended_confidence_level_per_group
# Purpose:
#     Evaluates the highest confidence level achieved by all variables within a group.
#     The function checks if all variables within a group have a sufficient sample size to achieve a given confidence level.
#     
# Parameters:
#     - sample_size_results: A list of data frames (the output from the sample.size.table function). Each data frame should contain the sample size calculations for a specific group.
#     
# Returns:
#     A list where each item represents a group. The value for each item is the highest confidence level achieved by all variables within that group. If no common confidence level was achieved by all variables within a group, the value is NA.
#     
# Notes:
#     If a group has at least one variable that did not achieve a given confidence level, then that group is considered to not have achieved that confidence level for all its variables.
# ------------------------------------------

# R code to create a function that determines the highest confidence level per grouping
recommended_confidence_level_per_group <- function(sample_size_results) {
  # Initialize a list to store the highest confidence level for each grouping
  highest_conf_levels <- list()
  
  # Loop through each grouping
  for (group_name in names(sample_size_results)) {
    group_data <- sample_size_results[[group_name]]
    
    # Unique confidence levels in the dataset
    conf_levels <- unique(group_data$confidence_level)
    
    # Find the highest confidence level where all variables for a group have sufficient sample size
    found_conf_level <- FALSE
    for (conf_level in sort(conf_levels, decreasing = TRUE)) {
      subset_results <- group_data[group_data$confidence_level == conf_level, ]
      if (all(subset_results$enough_sample_size == "Yes")) {
        highest_conf_levels[[group_name]] <- conf_level
        cat(paste("For grouping", group_name, "all subgroups achieved a confidence level of", conf_level, "%.\n"))
        found_conf_level <- TRUE
        break
      }
    }
    
    # If no confidence level was found, store NA for that group
    if (!found_conf_level) {
      cat(paste("For grouping", group_name, "no common confidence level was achieved by all subgroups.\n"))
      highest_conf_levels[[group_name]] <- NA
    }
  }
  
  return(highest_conf_levels)
}