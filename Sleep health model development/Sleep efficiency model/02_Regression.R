#1. Data preparation-----

df<-read_csv("Data.csv") # The data that support the findings of this study are available on request from the corresponding author

df$Class <- ifelse(df$sleepefficiency>0.85, 0, 1)

# Gather data into long format
long_d <- df %>%
  pivot_longer(cols = -c(id, Class, sleepefficiency), names_to = "variable", values_to = "value")

# Calculate skewness for each variable
skewness_df <- long_d %>%
  group_by(variable) %>%
  summarise(skewness = skewness(value, na.rm = TRUE))

df$Obese <- ifelse(df$BMI_zscore<2, 0, 1)
df$age_group <-ifelse(df$age<=12, 0, 1)

df$Class <-as.factor(df$Class)
df$id <-as.factor(df$id)
df$Obese <-as.factor(df$Obese)
df$age_group <-as.factor(df$age_group)
df <- subset(df, select = c(      "Class","id", "Obese", "age_group",
                                  "dewpoint_MX_mean", "wetbulb_mean", "air_temp_mean",  
                                  "op_temp_mean", "relative_humidity_mean", "black_globe_temp_mean",
                                  "co2_telaire_mean","log_pm25", "wall_temp_mean"
))

#2. Remove outliers of variable with |skewness|>3-----
df_clean <- df[remove_outliers(df$air_temp_mean) & remove_outliers(df$black_globe_temp_mean), ]
df <-df_clean
#3. Oversampling-----
prop.table(table(df$Class)) # 0.0.8174603 0.1825397 
rows_to_repeat <- which(df$Class == "1")
repeated_rows <- rep(rows_to_repeat, each = 4)
df_up <- rbind(df, df[repeated_rows, ])
prop.table(table(df_up$Class)) # 0.4724771 0.5275229

#4. Model I-----
model_I_1 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + log_pm25, 
                                data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_1 )
get_or_ci(model_I_1 )
model_I_2 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + air_temp_mean , 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_2 )
get_or_ci(model_I_2)
model_I_3 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + co2_telaire_mean, 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_3 )
get_or_ci(model_I_3)
model_I_4 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + black_globe_temp_mean , 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_4 )
get_or_ci(model_I_4)
model_I_5 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + op_temp_mean , 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_5 )
get_or_ci(model_I_5)
model_I_6 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + relative_humidity_mean , 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_6 )
get_or_ci(model_I_6)
model_I_7 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + wall_temp_mean, 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_7 )
get_or_ci(model_I_7)
model_I_8 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + wetbulb_mean , 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_8 )
get_or_ci(model_I_8)
model_I_9 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + dewpoint_MX_mean, 
                   data = df_up, family="binomial") #nAGQ = 10 
summary(model_I_9 )
get_or_ci(model_I_9)
#5. Model II  Lasso-----
df_up$Class <- as.numeric(df_up$Class)-1
df$Class <- as.numeric(df$Class)-1

# Define a sequence of lambda values
lambda <- 10^seq(log10(1), log10(50), length = 50)

CV_result_Class <- data.frame(lambda = numeric(), fold = integer(),
                              binomial_deviance_train = numeric(), 
                              binomial_deviance_test = numeric())

coefficients_Class <- data.frame(lambda = numeric(), loop = integer())
#need to average the class 1 in each fold,so seperate fold first then repeat class 1 4 times
folds <- createFolds(y = seq_len(nrow(df)), k = 5, list = TRUE)

for (lambda_index in seq_along(lambda)) {
  current_lambda <- lambda[lambda_index]
  
  for (i in 1:5) {
    # Get indices for the current fold
    fold_indices <- unlist(folds[i])
    
    train_fold <- df[-fold_indices, ]
    rows_to_repeat <- which(train_fold$Class == 1)
    repeated_rows <- rep(rows_to_repeat, each = 4)
    train_fold  <- rbind(train_fold , train_fold [repeated_rows, ])
    test_fold <- df[fold_indices, ]
    
    print(paste("Iteration ", lambda_index, i, sep=""))
    
    # Fit the model
    model <- glmmLasso(Class ~ age_group + Obese + 
                         wall_temp_mean + log_pm25 + black_globe_temp_mean + co2_telaire_mean +
                         relative_humidity_mean + op_temp_mean + air_temp_mean + wetbulb_mean +
                         dewpoint_MX_mean, 
                       data = train_fold,
                       rnd = list(id = ~1),
                       family = binomial(link = "logit"),
                       lambda = current_lambda,
                       switch.NR = TRUE,
                       final.re = TRUE
    )
    summary(model)
    # Calculate predictions for training and testing sets
    predicted_train <- predict(model, data = train_fold, type = "response")
    predicted_test <- predict(model, data = test_fold, type = "response", allow.new.levels = TRUE)
    
    # Calculate binomial deviance
    deviance_train <- -2 * sum(ifelse(train_fold$Class == 1, log(predicted_train), log(1 - predicted_train)))/nrow(train_fold)
    deviance_test <- -2 * sum(ifelse(test_fold$Class == 1, log(predicted_test), log(1 - predicted_test)))/nrow(test_fold)
    
    # Add results to data frame
    CV_result_Class <- rbind(CV_result_Class, data.frame(
      lambda = current_lambda,
      fold = i,
      binomial_deviance_train = deviance_train, 
      binomial_deviance_test = deviance_test
    ))
    
    # Store coefficients for the current model
    coefficients <- coef(model)
    loop_data <- data.frame(lambda = current_lambda, loop = i)
    for (j in 1:length(coefficients)) {
      loop_data[[paste0("coefficient_", j)]] <- coefficients[j]
    }
    
    # Adjust the column names dynamically to match the length of coefficients
    coefficients_Class <- rbind(coefficients_Class, loop_data, fill=TRUE)
  }
}

summary_results <- CV_result_Class %>%
  group_by(lambda) %>%
  summarize(
    mean_deviance_test = mean(binomial_deviance_test),
    sd_deviance_test = sd(binomial_deviance_test)
  )

# Plot the average binomial deviance with error bars
ggplot(summary_results, aes(x = lambda, y = mean_deviance_test)) +
  geom_line(color = "blue") +  # Line plot for the mean deviance
  geom_point(color = "blue") +  # Points at each lambda
  geom_errorbar(aes(ymin = mean_deviance_test - sd_deviance_test,
                    ymax = mean_deviance_test + sd_deviance_test),
                width = 0.1, color = "red") +  # Error bars for standard deviation
  scale_x_log10() +  # Log scale for lambda
  labs(title = "Average Binomial Deviance for Test Set vs Lambda",
       x = "Lambda",
       y = "Average Binomial Deviance (Test)") +
  theme_minimal()

best_lambda <- 33.54 
model <- glmmLasso(Class ~ age_group + Obese + 
                     wall_temp_mean + log_pm25 + black_globe_temp_mean + co2_telaire_mean +
                     relative_humidity_mean + op_temp_mean + air_temp_mean + wetbulb_mean +
                     dewpoint_MX_mean, 
                   data = df_up,
                   rnd = list(id = ~1),
                   family = binomial(link = "logit"),
                   lambda =best_lambda,# 
                   switch.NR = TRUE,
                   final.re = TRUE
)
summary(model)
## adjusted for age_group and Obese
model_lasso1 <- glmer(Class ~ 1 + (1|id) + age_group + Obese,
                     data = df_up, family="binomial",nAGQ = 10)
summary(model_lasso1)

model_lasso2 <- glmer(Class ~ 1 + (1|id) +age_group + Obese + log_pm25 + relative_humidity_mean + dewpoint_MX_mean,
                     data = df_up, family="binomial") 
summary(model_lasso2)

#6. Model III Stepwise-----
full_model <- glmer(Class ~ 1 + (1|id) + age_group + Obese + 
                      wall_temp_mean + log_pm25 + black_globe_temp_mean + co2_telaire_mean +
                      relative_humidity_mean + op_temp_mean + air_temp_mean + wetbulb_mean +
                      dewpoint_MX_mean,
                    data = df_up,
                    family = binomial(link = "logit"), 
                    control = glmerControl(optimizer = "bobyqa"))

# Start with the null model
null_model <- glmer(Class ~ 1 + (1|id) + age_group + Obese, 
                    data = df_up,
                    family = binomial(link = "logit"), 
                    control = glmerControl(optimizer = "bobyqa"))

## forward stepwise selection based on AIC-----
current_model <- null_model
stepwise_finished <- FALSE

# List of candidate predictors
predictors <- c("wall_temp_mean", "log_pm25", "black_globe_temp_mean", "co2_telaire_mean", 
                "relative_humidity_mean", "op_temp_mean", "air_temp_mean", "wetbulb_mean", 
                "dewpoint_MX_mean")

while (!stepwise_finished) {
  current_aic <- AIC(current_model)
  best_aic <- current_aic
  best_model <- current_model
  
  for (term in predictors) {
    
    # Try adding each term that is not already in the model
    new_model <- update(current_model, paste(". ~ . +", term))
    
    # Get the AIC of the new model
    new_aic <- AIC(new_model)
    
    # Show the tested term and its AIC
    print(paste("Tested term:", term, " | AIC:", new_aic))
    
    # Check model convergence
    if (is.null(new_model@optinfo$conv$lme4$messages)) {
      if (new_aic < best_aic) {  # Accept the model if AIC is lower
        best_model <- new_model
        best_aic <- new_aic
        print(paste("Term added:", term))
        print(paste("New best AIC:", best_aic))
      }
    }
  }
  
  if (best_aic < current_aic) {
    current_model <- best_model
    current_aic <- best_aic
    
    # Remove the term that was just added from the list of candidates
    added_term <- setdiff(all.vars(formula(current_model)), all.vars(formula(null_model)))
    predictors <- setdiff(predictors, added_term)
    
    print(paste("Updated model with best AIC:", current_aic))
  } else {
    stepwise_finished <- TRUE
    print("No further improvement, stepwise finished.")
  }
}


# The resulting model after forward stepwise selection
summary(current_model)

model_stepwise_forward <- glmer(Class ~ 1 + (1|id) + age_group + Obese + log_pm25 + relative_humidity_mean, 
                                data = df_up,
                                family = binomial(link = "logit"), 
                                control = glmerControl(optimizer = "bobyqa"))
summary(model_stepwise_forward)

## backward stepwise selection based on AIC-----
current_model <- full_model
stepwise_finished <- FALSE

# Backward Elimination loop
while (!stepwise_finished) {
  current_aic <- AIC(current_model)
  best_aic <- current_aic
  best_model <- current_model
  term_to_remove <- NULL  # To store the term to be removed
  
  # Check each term in the model for potential removal
  for (term in all.vars(formula(current_model))[-1]) {  # Skip the intercept term
    
    # Try removing each term
    new_model <- update(current_model, paste(". ~ . -", term))
    new_aic <- AIC(new_model)
    
    # Show tested term and its AIC
    print(paste("Tested term:", term, " | AIC:", new_aic))
    
    if (new_aic < best_aic) {  # Accept the model if AIC is lower
      best_model <- new_model
      best_aic <- new_aic
      term_to_remove <- term  # Store the term to remove
    }
  }
  
  # Check if there was any improvement
  if (best_aic < current_aic) {
    current_model <- best_model
    current_aic <- best_aic
    print(paste("Term removed:", term_to_remove, " | New best AIC:", best_aic))
  } else {
    stepwise_finished <- TRUE
    print("No further improvement, stepwise finished.")
  }
}

# The resulting model after backward stepwise selection
summary(current_model)
# The resulting model after backward stepwise selection
model_stepwise_backrward1 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + log_pm25  + co2_telaire_mean +wetbulb_mean  + dewpoint_MX_mean, 
                                  data = df_up,
                                  family = binomial(link = "logit"))
summary(model_stepwise_backrward1)
#because pm2.5 beta should be positive, so delete pm2.5
model_stepwise_backrward2 <- glmer(Class ~ 1 + (1|id) + age_group + Obese + co2_telaire_mean +wetbulb_mean  + dewpoint_MX_mean, 
                                  data = df_up,
                                  family = binomial(link = "logit"))
summary(model_stepwise_backrward2)
get_or_ci(model_stepwise_backrward2)
#7. Cross validation----
Class_1 <- subset(df, df$Class==1)
Class_0 <- subset(df, df$Class==0)
Class_1_fold <- split(Class_1, sample(rep(1:5, each = ceiling(nrow(Class_1)/5))))
Class_0_fold <- split(Class_0, sample(rep(1:5, each = ceiling(nrow(Class_0)/5))))
results <- data.frame()

perform_cross_validation <- function(mod, Class_1_fold, Class_0_fold, df_up) {
  # Initialize results dataframe
  results <- data.frame(
    Fold = integer(),
    Train_TP = integer(),
    Train_TN = integer(),
    Train_FP = integer(),
    Train_FN = integer(),
    Test_TP = integer(),
    Test_TN = integer(),
    Test_FP = integer(),
    Test_FN = integer(),
    AIC = numeric(),
    Train_AUC = numeric(),
    Test_AUC = numeric(),
    Cutoff_value = numeric()
  )
  
  for (i in 1:5) {
    # Split data into training and testing sets based on the fold
    train <- list()
    test <- list()
    test[[i]] <- rbind(Class_1_fold[[i]], Class_0_fold[[i]])
    
    class_1_train <- do.call(rbind, Class_1_fold[-i])
    class_0_train <- do.call(rbind, Class_0_fold[-i])
    class_1_train_repeated <- rbind(class_1_train, class_1_train, class_1_train, class_1_train)
    train[[i]] <- rbind(class_1_train_repeated, class_0_train)
    
    trainData <- train[[i]]
    testData <- test[[i]]
    
    # Fit model to the entire dataset to find the best threshold
    mod_fitcv <- glmer(mod, data = df_up, family = binomial)
    predicted_probabilities <- predict(mod_fitcv, newdata = df_up, type = "response", allow.new.levels = TRUE)
    roc_curve <- roc(df_up$Class, predicted_probabilities, plot = FALSE, print.auc = FALSE)
    best_threshold <- coords(roc_curve, "best", ret = "threshold", best.method = "youden")
    best_threshold_value <- as.numeric(best_threshold[1,1]) 
    
    # Fit model to the training data
    mod_fitcv <- glmer(mod, data = trainData, family = binomial)
    model_aic <- AIC(mod_fitcv)
    
    # Generate predicted probabilities for training and testing data
    predicted_probabilities_train <- predict(mod_fitcv, newdata = trainData, type = "response", allow.new.levels = TRUE)
    predicted_probabilities_test  <- predict(mod_fitcv, newdata = testData, type = "response", allow.new.levels = TRUE)
    
    # Calculate ROC curves and AUC values
    roc_curve_train <- roc(trainData$Class, predicted_probabilities_train, plot = TRUE, print.auc = TRUE)
    auc_value_train <- as.numeric(roc_curve_train$auc)
    
    roc_curve_test <- roc(testData$Class, predicted_probabilities_test, plot = TRUE, print.auc = TRUE)
    auc_value_test <- as.numeric(roc_curve_test$auc)
    
    # Apply threshold to generate binary predictions
    binary_predictions_train <- ifelse(predicted_probabilities_train > best_threshold_value, 1, 0)
    binary_predictions_test  <- ifelse(predicted_probabilities_test > best_threshold_value, 1, 0)
    
    # Calculate confusion matrix components for training data
    train_tp <- sum(trainData$Class == 1 & binary_predictions_train == 1)
    train_tn <- sum(trainData$Class == 0 & binary_predictions_train == 0)
    train_fp <- sum(trainData$Class == 0 & binary_predictions_train == 1)
    train_fn <- sum(trainData$Class == 1 & binary_predictions_train == 0)
    
    # Calculate confusion matrix components for testing data
    test_tp <- sum(testData$Class == 1 & binary_predictions_test == 1)
    test_tn <- sum(testData$Class == 0 & binary_predictions_test == 0)
    test_fp <- sum(testData$Class == 0 & binary_predictions_test == 1)
    test_fn <- sum(testData$Class == 1 & binary_predictions_test == 0)
    
    # Append results to the dataframe
    results <- rbind(results, data.frame(
      Fold = i,
      Train_TP = train_tp,
      Train_TN = train_tn,
      Train_FP = train_fp,
      Train_FN = train_fn,
      Test_TP = test_tp,
      Test_TN = test_tn,
      Test_FP = test_fp,
      Test_FN = test_fn,
      AIC = model_aic,
      Train_AUC = auc_value_train,
      Test_AUC = auc_value_test,
      Cutoff_value = best_threshold_value
    ))
  }
  
  # Return results
  return(results)
}

mod1 <- Class ~ 1 + (1|id) + age_group + Obese +log_pm25
mod2 <- Class ~ 1 + (1|id) + age_group + Obese +air_temp_mean 
mod3 <- Class ~ 1 + (1|id) + age_group + Obese +co2_telaire_mean
mod4 <- Class ~ 1 + (1|id) + age_group + Obese +black_globe_temp_mean
mod5 <- Class ~ 1 + (1|id) + age_group + Obese +op_temp_mean
mod6 <- Class ~ 1 + (1|id) + age_group + Obese +relative_humidity_mean
mod7 <- Class ~ 1 + (1|id) + age_group + Obese +wall_temp_mean
mod8 <- Class ~ 1 + (1|id) + age_group + Obese +wetbulb_mean
mod9 <- Class ~ 1 + (1|id) + age_group + Obese +dewpoint_MX_mean
mod_lasso1 <- Class ~ 1 + (1|id) + age_group + Obese
mod_lasso2 <- Class ~ 1 + (1|id) +age_group + Obese + log_pm25 + relative_humidity_mean + dewpoint_MX_mean
mod_forward <- Class ~ 1 + (1|id) + age_group + Obese + log_pm25 + relative_humidity_mean 
mod_backward1 <- Class ~ 1 + (1|id) + age_group + Obese + log_pm25  + co2_telaire_mean +wetbulb_mean  + dewpoint_MX_mean # stepwise back1
mod_backward2 <- Class ~ 1 + (1|id) + age_group + Obese + co2_telaire_mean +wetbulb_mean  + dewpoint_MX_mean# stepwise back2


perform_cross_validation(mod=mod1, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod2, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod3, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod4, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod5, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod6, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod7, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod8, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod9, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod_lasso1, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod_lasso2, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod_forward, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod_backward1, Class_1_fold, Class_0_fold, df_up)
perform_cross_validation(mod=mod_backward2, Class_1_fold, Class_0_fold, df_up)

