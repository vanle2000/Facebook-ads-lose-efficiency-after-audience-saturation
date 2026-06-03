# 05_inference_tests.R
# Purpose: Statistical testing to evaluate performance differences across segments
# Tests: ANOVA, t-tests, Chi-square for categorical associations

library(tidyverse)
library(dplyr)

# Load data
ads_data <- read_csv("data/processed/ads_modeling_table.csv")

cat("=== Statistical Inference Tests ===\n")

# 1. ANOVA: Does CPA differ by age group?
cat("\n--- ANOVA: CPA by Age Group ---\n")
anova_age <- aov(cpa ~ age, data = ads_data)
print(summary(anova_age))

# 2. ANOVA: Does Conversion Rate differ by gender?
cat("\n--- ANOVA: Conversion Rate by Gender ---\n")
anova_gender <- aov(conversion_rate ~ gender, data = ads_data)
print(summary(anova_gender))

# 3. Correlation analysis
cat("\n--- Correlation Analysis ---\n")
numeric_cols <- ads_data %>% select(Impressions, Clicks, Spent, Total_Conversion, 
                                      Approved_Conversion, ctr, cpc, cpa, conversion_rate)
corr_matrix <- cor(numeric_cols, use = "complete.obs")
print(round(corr_matrix, 3))

# 4. Chi-square: Association between age and high/low conversion
ads_data <- ads_data %>%
  mutate(high_conversion = ifelse(conversion_rate > median(conversion_rate, na.rm = TRUE), 1, 0))

cat("\n--- Chi-Square Test: Age vs Conversion ---\n")
contingency_table <- table(ads_data$age, ads_data$high_conversion)
chi_test <- chisq.test(contingency_table)
print(chi_test)

# 5. Segment performance ranking
cat("\n--- Top 10 Lowest CPA Segments ---\n")
top_performers <- ads_data %>%
  group_by(interest, age, gender) %>%
  summarise(
    Count = n(),
    Total_Conversions = sum(Approved_Conversion),
    Avg_CPA = mean(cpa),
    .groups = "drop"
  ) %>%
  filter(Total_Conversions >= 5) %>%
  arrange(Avg_CPA) %>%
  head(10)
print(top_performers)

cat("\n--- Top 10 Highest CPA Segments (Low Efficiency) ---\n")
bottom_performers <- ads_data %>%
  group_by(interest, age, gender) %>%
  summarise(
    Count = n(),
    Total_Conversions = sum(Approved_Conversion),
    Avg_CPA = mean(cpa),
    .groups = "drop"
  ) %>%
  filter(Total_Conversions >= 5) %>%
  arrange(desc(Avg_CPA)) %>%
  head(10)
print(bottom_performers)

cat("\nInference tests completed.\n")
