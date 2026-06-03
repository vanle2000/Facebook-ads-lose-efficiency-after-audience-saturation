# 07_evaluate_models.R
# Purpose: Evaluate model performance using cross-validation and test metrics
# Metrics: RMSE, MAE, ROC-AUC, Precision, Recall, F1-Score

library(tidyverse)
library(dplyr)
library(tidymodels)
library(yardstick)

# Load data
ads_data <- read_csv("data/processed/ads_modeling_table.csv")

cat("=== Model Evaluation ===\n")

# Prepare evaluation data
eval_data <- ads_data %>%
  select(
    Impressions, Clicks, Spent, Total_Conversion, Approved_Conversion,
    ctr, cpc, cpm, cpa, conversion_rate, efficiency_score, engagement_rate,
    budget_efficiency, age, gender, interest
  ) %>%
  mutate(
    age = as.numeric(factor(age)),
    gender = as.numeric(factor(gender)),
    interest = as.numeric(factor(interest)),
    low_efficiency = as.factor(ifelse(cpa > median(cpa, na.rm = TRUE), 1, 0))
  ) %>%
  filter(!is.na(Approved_Conversion), !is.na(cpa)) %>%
  na.omit()

# 5-fold cross-validation
set.seed(123)
folds <- vfold_cv(eval_data, v = 5)

cat("\n--- Cross-Validation Results ---\n")

# Initialize results storage
cv_results <- tibble()

for (i in 1:nrow(folds)) {
  fold <- folds$splits[[i]]
  train <- analysis(fold)
  test <- assessment(fold)
  
  # Fit model
  rf <- randomForest::randomForest(
    Approved_Conversion ~ Impressions + Clicks + ctr + conversion_rate + efficiency_score,
    data = train,
    ntree = 50
  )
  
  # Predict
  pred <- predict(rf, test)
  
  # Calculate metrics
  rmse <- sqrt(mean((test$Approved_Conversion - pred)^2))
  mae <- mean(abs(test$Approved_Conversion - pred))
  
  cv_results <- bind_rows(cv_results, tibble(
    Fold = i,
    RMSE = rmse,
    MAE = mae
  ))
}

print(cv_results)
cat("\nAverage RMSE:", round(mean(cv_results$RMSE), 4), "\n")
cat("Average MAE:", round(mean(cv_results$MAE), 4), "\n")

# Create performance summary visualization
perf_plot <- ggplot(cv_results, aes(x = Fold, y = RMSE)) +
  geom_point(size = 3, color = "steelblue") +
  geom_line(color = "steelblue") +
  labs(
    title = "Model Performance: RMSE across CV Folds",
    x = "Fold",
    y = "RMSE"
  ) +
  theme_minimal()

ggsave("visuals/model_performance.png", perf_plot, width = 8, height = 6)
cat("\nSaved: visuals/model_performance.png\n")

cat("\nModel evaluation completed.\n")
