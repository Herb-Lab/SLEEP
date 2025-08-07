#1. Data preparation-----
osa_df <- read_excel("Data.xlsx", sheet = "sheet1") # The data that support the findings of this study are available on request from the corresponding author

#2. Model I-----
Model_I_1 <- glm(Class ~ age_group + Obese + log_pm25, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_1)
get_or_ci(Model_I_1)
Model_I_2 <- glm(Class ~ age_group + Obese + wetbulb_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_2)
get_or_ci(Model_I_2)
Model_I_3 <- glm(Class ~ age_group + Obese + wall_temp_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_3)
get_or_ci(Model_I_3)
Model_I_4 <- glm(Class ~ age_group + Obese + black_globe_temp_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_4)
get_or_ci(Model_I_4)
Model_I_5 <- glm(Class ~ age_group + Obese + air_temp_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_5)
get_or_ci(Model_I_5)
Model_I_6 <- glm(Class ~ age_group + Obese + relative_humidity_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_6)
get_or_ci(Model_I_6)
Model_I_7 <- glm(Class ~ age_group + Obese + dewpoint_MX_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_7)
get_or_ci(Model_I_7)
Model_I_8 <- glm(Class ~ age_group + Obese + op_temp_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_8)
get_or_ci(Model_I_8)
Model_I_9 <- glm(Class ~ age_group + Obese + co2_telaire_mean, data=osa_df, family = binomial(link = "logit"))
summary(Model_I_9)
get_or_ci(Model_I_9)
#3. Model II Lasso-----
X <- as.matrix(osa_df[, !(names(osa_df) %in% c( "Class", "age_group", "Obese"))])
y <- osa_df$Class
cv.lasso <- cv.glmnet(X, y, alpha = 1, family = "binomial")
plot(cv.lasso)
best.lambda <- cv.lasso$lambda.min
print(best.lambda)# 
#refit lasso with selected lambda
lasso.model <- glmnet(X, y, alpha=1, lambda=best.lambda)
coef(lasso.model)
## lasso-----
model_lasso <- glm(Class ~ age_group + Obese +  log_pm25 + air_temp_mean + co2_telaire_mean, 
                   data=osa_df, family = binomial(link = "logit"))
summary(model_lasso)
get_or_ci(model_lasso)

#4. Model III stepwise-----
model_full <- glm(Class ~ log_pm25 + wetbulb_mean + wall_temp_mean + 
                    black_globe_temp_mean + air_temp_mean + relative_humidity_mean + 
                    dewpoint_MX_mean + co2_telaire_mean+ op_temp_mean,
                  data=osa_df, family = binomial(link = "logit"))
model_null <- glm(Class ~ 1, data=osa_df, family = binomial(link = "logit"))

## forward-----
stepwise_model <- step(model_null, scope = list(lower = model_null, upper = model_full), 
                       direction = "forward")

model_stepwise_forward <- glm(Class ~ age_group + Obese + log_pm25 + air_temp_mean,
                              data=osa_df, family = binomial(link = "logit"))
summary(model_stepwise_forward)

## backward-----
stepwise_model <- step(model_full, direction = "backward")

model_stepwise_backward <- glm(Class ~ age_group + Obese + log_pm25 + air_temp_mean,
                               data=osa_df, family = binomial(link = "logit"))
summary(model_stepwise_backward )

#5. Cross validation----
## data partition-----
Class_1 <- subset(osa_df, osa_df$Class==1)
Class_0 <- subset(osa_df, osa_df$Class==0)
Class_1_fold <- split(Class_1, sample(rep(1:3, each = ceiling(nrow(Class_1)/3))))
Class_0_fold <- split(Class_0, sample(rep(1:3, each = ceiling(nrow(Class_0)/3))))
results <- data.frame()

## define the model formula-----
#single
mod <- Class ~ age_group + Obese + dewpoint_MX_mean
#mod <- Class ~ age_group + Obese +  log_pm25 + air_temp_mean + co2_telaire_mean #lasso
#mod <- Class ~ age_group + Obese + log_pm25 + air_temp_mean # forward and backward

## confusion matrix-----
for (i in 1:3) {
  train <- list()
  test <- list()
  test[[i]] <- rbind(Class_1_fold[[i]], Class_0_fold[[i]])
  train[[i]] <- rbind(do.call(rbind, Class_1_fold[-i]), do.call(rbind, Class_0_fold[-i]))
  
  trainData <- train[[i]]
  testData <- test[[i]]
  
  #get the cutoff
  model <-glm(mod, data = osa_df, family = binomial(link = "logit"))
  predicted_probabilities <- predict(model, newdata = osa_df, type = "response")
  roc_curve <- roc(osa_df$Class, predicted_probabilities, plot = TRUE, print.auc = TRUE)
  best_threshold <- coords(roc_curve, "best", ret = "threshold", best.method = "youden")
  #best_threshold_value <- 0.5#
  best_threshold_value <- as.numeric(best_threshold[1,1]) 
  # Fit the model
  mod_fitcv <- glm(mod, data = trainData, family = binomial(link = "logit"))
  
  # Calculate AIC of the model
  model_aic <- AIC(mod_fitcv)
  
  # Generate predicted probabilities for the training and testing data
  predicted_probabilities_train <- predict(mod_fitcv, newdata = trainData, type = "response")
  predicted_probabilities_test <- predict(mod_fitcv, newdata = testData, type = "response")
  
  # Calculate the ROC curve and AUC for the training data
  roc_curve_train <- roc(trainData$Class, predicted_probabilities_train, plot = TRUE, print.auc = TRUE)
  auc_value_train <- as.numeric(roc_curve_train$auc)
  
  # Calculate the ROC curve and AUC for the testing data
  roc_curve_test <- roc(testData$Class, predicted_probabilities_test, plot = TRUE, print.auc = TRUE)
  auc_value_test <- as.numeric(roc_curve_test$auc)
  
  # Apply the custom threshold to training and testing data
  binary_predictions_train <- ifelse(predicted_probabilities_train > best_threshold_value, 1, 0)
  binary_predictions_test <- ifelse(predicted_probabilities_test > best_threshold_value, 1, 0)
  
  # Calculate the confusion matrix for training data
  conf_matrix_train <- confusionMatrix(as.factor(binary_predictions_train), as.factor(trainData$Class), positive = "1")
  
  # Calculate the confusion matrix for testing data
  conf_matrix_test <- confusionMatrix(as.factor(binary_predictions_test), as.factor(testData$Class), positive = "1")
  
  # Calculate the confusion matrix values for training data
  train_tp <- sum(trainData$Class == 1 & binary_predictions_train == 1)  # True Positives
  train_tn <- sum(trainData$Class == 0 & binary_predictions_train == 0)  # True Negatives
  train_fp <- sum(trainData$Class == 0 & binary_predictions_train == 1)  # False Positives
  train_fn <- sum(trainData$Class == 1 & binary_predictions_train == 0)  # False Negatives
  
  # Calculate the confusion matrix values for testing data
  test_tp <- sum(testData$Class == 1 & binary_predictions_test == 1)  # True Positives
  test_tn <- sum(testData$Class == 0 & binary_predictions_test == 0)  # True Negatives
  test_fp <- sum(testData$Class == 0 & binary_predictions_test == 1)  # False Positives
  test_fn <- sum(testData$Class == 1 & binary_predictions_test == 0)  # False Negatives
  
  # Store the results in the dataframe
  results <- rbind(results, data.frame(Fold = i,
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
                                       Cutoff_value = best_threshold_value))
}
# Print the results
print(results)

