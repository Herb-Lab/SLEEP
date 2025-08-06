# Load library-----
library(readr)
library(dplyr) #data manipulation
library(tidyr)
library(lme4)
library(moments) # skewness
library(caret)
library(pROC)        # display and analyze roc curves
# Load function-----
## Get OR range -----
get_or_ci <- function(model) {
  OR <- exp(fixef(model))
  CI <- exp(confint(model, method = "Wald"))
  
  # Extract only the fixed effects' confidence intervals
  fixed_effects_names <- names(fixef(model))
  CI_fixed <- CI[fixed_effects_names, , drop = FALSE]
  
  # Create a formatted column for OR (lower, upper)
  OR_CI_formatted <- sprintf("%.2f (%.2f, %.2f)", OR, CI_fixed[, 1], CI_fixed[, 2])
  
  OR_table <- data.frame(
    Term = fixed_effects_names,
    OR_CI = OR_CI_formatted
  )
  
  return(OR_table)
}

## Define a function to remove outliers using the IQR method
remove_outliers <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  return(x >= lower_bound & x <= upper_bound)
}
