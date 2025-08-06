#1. Gini coefficient-----
compute_gini <- function(df, x_col = "City_x", y_col) {
  # Calculate the Gini coefficient for each city
  gini_results <- df %>%
    group_by(get(x_col)) %>%
    summarise(
      Gini = ineq::Gini(get(y_col), na.rm = TRUE)
    ) %>%
    rename(City = `get(x_col)`)
  
  # Return the results as a dataframe
  return(gini_results)
}

# Example usage
compute_gini(merged_df, x_col = "City", y_col = "Annual_EMS.OSA5_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "Summer_EMS.OSA5_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "Winter_EMS.OSA5_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "transitional_EMS.OSA5_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "Annual_EMS.OSA5_prob_2_mean")

compute_gini(merged_df, x_col = "City", y_col = "Annual_EMS.SE85_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "Summer_EMS.SE85_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "Winter_EMS.SE85_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "transitional_EMS.SE85_prob_1_mean")
compute_gini(merged_df, x_col = "City", y_col = "transitional_EMS.SE85_prob_2_mean")