#1. Data preparation-----
df_city <- read_csv("Data.csv") # The data that support the findings of this study are available on request from the corresponding author

#2. Collinearity checks-----
pairs.panels(df_city[,c(2:13)], main = "Scatter Plot Matrix",cex.cor = 3) 
cor_matrix <- cor(df_city[, c(2:13)], use = "complete.obs")

#3. Regression with exceedance hours for LSE risk -----
## Model I full model-----
se_full_model <- lm(
  median_SE_unmet_hours ~ 
    climate_thermal_zone + 
    #climate_zone_letter + 
    #percentage_single_family + 
    percentage_vintage_before_1980s + 
    percentage_occupants_per_bedroom_gt_1 + 
    percentage_HVAC_no_cooling + 
    #percentage_HVAC_no_heating + 
    percentage_cooling_setpoint_22_23+ 
    percentage_heating_setpoint_22_23 + 
    percentage_tenure_renter +
    percentage_fpl_0_100,  
  data = df_city
)
summary(se_full_model)
model_summary <- summary(se_full_model)
coeff_table <- model_summary$coefficients

# Round the p-values to 4 digits
coeff_table[, 4] <- round(coeff_table[, 4], 4)
round(confint(se_full_model),2)

## Model II backward stepwise-----
stepwise_backward_se_model <- step(
  se_full_model, 
  direction = "backward",  # Enables both forward and backward stepwise selection
  trace = TRUE         # Displays the stepwise process in the console
)

summary(stepwise_backward_se_model)

## Final model-----
se_model <- lm(median_SE_unmet_hours ~ percentage_vintage_before_1980s + 
                 percentage_cooling_setpoint_22_23+
                 percentage_tenure_renter,
               data = df_city)
summary(se_model)
round(confint(se_model),2)
vif(se_model)

#4. Regression with exceedance hours for MOSA risk -----
## Model I full model-----
osa_full_model <- lm(
  median_OSA_unmet_hours ~ 
    climate_thermal_zone + 
    #climate_zone_letter + 
    #percentage_single_family + 
    percentage_vintage_before_1980s + 
    percentage_occupants_per_bedroom_gt_1 + 
    percentage_HVAC_no_cooling + 
    #percentage_HVAC_no_heating + 
    percentage_cooling_setpoint_22_23+ 
    percentage_heating_setpoint_22_23 + 
    percentage_tenure_renter +
    percentage_fpl_0_100,  
  data = df_city
)
summary(osa_full_model)
round(confint(osa_full_model),2)

## Model II backward stepwise-----
stepwise_backward_osa_model <- step(
  osa_full_model, 
  direction = "backward",  # Enables both forward and backward stepwise selection
  trace = TRUE         # Displays the stepwise process in the console
)

summary(stepwise_backward_osa_model)

## Final model-----
osa_model <- lm(median_OSA_unmet_hours ~ climate_thermal_zone + percentage_vintage_before_1980s + 
                  percentage_occupants_per_bedroom_gt_1 + percentage_HVAC_no_cooling + 
                  percentage_cooling_setpoint_22_23+ percentage_tenure_renter,
               data = df_city)
summary(osa_model)
round(confint(osa_model),2)
#5. RMSE-----
# Make predictions
predictions <- predict(se_full_model, newdata = df_city)

# Calculate residuals
residuals <- df_city$median_SE_unmet_hours - predictions

# Compute MSE
mse <- mean(residuals^2)

# Compute RMSE
rmse <- sqrt(mse)

# Print results
cat("MSE:", mse, "\n")
cat("RMSE:", rmse, "\n")