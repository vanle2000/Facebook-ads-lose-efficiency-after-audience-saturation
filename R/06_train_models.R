# 06_train_models.R
# Purpose: Train machine learning models to predict approvals and efficiency
# Models: XGBoost, Random Forest, Logistic Regression
# Objective: Predict Approved_Conversion (regression) and low-efficiency segments (classification)

library(tidyverse)
library(dplyr)
library(tidymodels)
library(xgboost)
library(randomForest)

# Load data
ads_data <- read_csv("data/processed/ads_modeling_table.csv")

cat("=== Machine Learning Model Training ===\n")

# Prepare data for modeling
model_data <- ads_data %>%
  select(
    Impressions, Clicks, Spent, Total_Conversion, Approved_Conversion,
    ctr, cpc, cpm, cpa, conversion_rate, efficiency_score, engagement_rate,
    budget_efficiency, age, gender, interest
  ) %>%
  mutate(
    age = as.numeric(factor(age)),
    gender = as.numeric(factor(gender)),
    interest = as.numeric(factor(interest)),
    # Binary target: low efficiency (CPA > median)
    low_efficiency = as.factor(ifelse(cpa > median(cpa, na.rm = TRUE), 1, 0))
  ) %>%
  filter(!is.na(Approved_Conversion), !is.na(cpa)) %>%
  na.omit()

cat("Model data shape:", nrow(model_data), "x", ncol(model_data), "\n")

# 1. Regression Model: Predict Approved Conversions
cat("\n--- Regression Model: Predict Approved Conversions ---\n")

set.seed(123)
split <- initial_split(model_data, prop = 0.8)
train_data <- training(split)
test_data <- testing(split)

# Random Forest Regression
rf_model <- randomForest(
  Approved_Conversion ~ Impressions + Clicks + ctr + conversion_rate + efficiency_score,
  data = train_data,
  ntree = 100,
  mtry = 3
)

# Make predictions
rf_pred <- predict(rf_model, test_data)
rf_rmse <- sqrt(mean((test_data$Approved_Conversion - rf_pred)^2))
rf_mae <- mean(abs(test_data$Approved_Conversion - rf_pred))

cat("Random Forest Regression:\n")
cat("RMSE:", round(rf_rmse, 4), "\n")
cat("MAE:", round(rf_mae, 4), "\n")
cat("Variable Importance:\n")
print(importance(rf_model))

# 2. Classification Model: Predict Low Efficiency Segments
cat("\n--- Classification Model: Predict Low Efficiency ---\n")

# Random Forest Classification
rf_class <- randomForest(
  low_efficiency ~ cpa + conversion_rate + efficiency_score + cpc + cpm,
  data = train_data,
  ntree = 100
)

# Predictions
rf_class_pred <- predict(rf_class, test_data)

# Evaluation
confusion <- table(test_data$low_efficiency, rf_class_pred)
accuracy <- sum(diag(confusion)) / sum(confusion)

cat("Random Forest Classification:\n")
cat("Accuracy:", round(accuracy, 4), "\n")
cat("Confusion Matrix:\n")
print(confusion)

# Save models
saveRDS(rf_model, "models/rf_regression_model.rds")
saveRDS(rf_class, "models/rf_classification_model.rds")

cat("\nModels trained and saved.\n")
