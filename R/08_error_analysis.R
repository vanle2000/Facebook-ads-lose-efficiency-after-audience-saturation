# 08_error_analysis.R
# Purpose: Analyze model errors and identify patterns in mispredictions
# Output: Error patterns by segment, feature importance in errors

library(tidyverse)
library(dplyr)
library(tidymodels)

# Load data and model
ads_data <- read_csv("data/processed/ads_modeling_table.csv")
model <- readRDS("models/rf_regression_model.rds")

cat("=== Error Analysis ===\n")

# Prepare data
model_data <- ads_data %>%
  select(
    Impressions, Clicks, Spent, Total_Conversion, Approved_Conversion,
    ctr, cpc, cpm, cpa, conversion_rate, efficiency_score, engagement_rate,
    budget_efficiency, age, gender, interest
  ) %>%
  mutate(
    age = as.numeric(factor(age)),
    gender = as.numeric(factor(gender)),
    interest = as.numeric(factor(interest))
  ) %>%
  filter(!is.na(Approved_Conversion), !is.na(cpa)) %>%
  na.omit()

# Generate predictions
model_data$predictions <- predict(model, model_data)
model_data$residuals <- model_data$Approved_Conversion - model_data$predictions
model_data$abs_error <- abs(model_data$residuals)
model_data$pct_error <- (model_data$abs_error / (model_data$Approved_Conversion + 1)) * 100

# Error summary
cat("\n--- Prediction Error Summary ---\n")
cat("Mean Absolute Error (MAE):", round(mean(model_data$abs_error), 4), "\n")
cat("Root Mean Squared Error (RMSE):", 
    round(sqrt(mean(model_data$residuals^2)), 4), "\n")
cat("Mean Absolute Percentage Error:", 
    round(mean(model_data$pct_error), 2), "%\n")

# Identify high-error segments
cat("\n--- Segments with Highest Prediction Errors ---\n")
high_error_segments <- model_data %>%
  group_by(interest) %>%
  summarise(
    N = n(),
    Mean_Error = mean(abs_error),
    Mean_Actual = mean(Approved_Conversion),
    Mean_Predicted = mean(predictions),
    .groups = "drop"
  ) %>%
  arrange(desc(Mean_Error)) %>%
  head(10)
print(high_error_segments)

# Error distribution by age/gender
cat("\n--- Error by Demographics ---\n")
error_by_demo <- model_data %>%
  group_by(age, gender) %>%
  summarise(
    N = n(),
    MAE = mean(abs_error),
    .groups = "drop"
  ) %>%
  arrange(desc(MAE))
print(error_by_demo)

# Visualization: Residuals
residual_plot <- ggplot(model_data, aes(x = predictions, y = residuals)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Residual Plot: Predicted vs Actual Error",
    x = "Predicted Conversions",
    y = "Residuals"
  ) +
  theme_minimal()

ggsave("visuals/residual_analysis.png", residual_plot, width = 10, height = 6)
cat("\nSaved: visuals/residual_analysis.png\n")

cat("\nError analysis completed.\n")
