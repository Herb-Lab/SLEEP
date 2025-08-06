# Load library-----
library(readxl)
library(glmnet)# lasso
library(pROC) # display and analyze roc curves
library(caret) # cross validation
# Load function-----
## get OR range -----
get_or_ci <- function(model) {
  # Extract coefficients and confidence intervals (Wald)
  OR <- exp(coef(model))
  CI <- exp(confint.default(model))
  
  # Create a formatted output
  OR_CI_formatted <- sprintf("%.2f (%.2f, %.2f)", OR, CI[, 1], CI[, 2])
  
  # Prepare output as a data frame
  OR_table <- data.frame(
    Term = names(OR),    OR_CI = OR_CI_formatted,
    OR = round(OR, 2),    CI_Lower = round(CI[, 1], 2),    CI_Upper = round(CI[, 2], 2)
  )
  
  return(OR_table)
}