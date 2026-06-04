# I want to design an A/B test to validate model-guided budget allocation
# Expected output: Test design, power analysis, sample size calculation, hypothesis

library(tidyverse)
library(dplyr)

cat("=== A/B Test Design for Budget Reallocation ===\n") 

# load data
ads_data <- read_csv("data/processed/ads_modeling_table.csv")

# Calculate baseline metrics
baseline <- ads_data %>%
  summarise(
    baseline_cpa = mean(cpa, na.rm = TRUE),
    baseline_conversion_rate = mean(conversion_rate, na.rm = TRUE),
    baseline_cpc = mean(cpc, na.rm = TRUE),
    baseline_approval_rate = sum(Approved_Conversion) / sum(Total_Conversion),
    sd_cpa = sd(cpa, na.rm = TRUE)
  )

cat("\n=== Baseline Metrics ===\n")
print(baseline)

# Test design
cat("\n=== Test Design ===\n")
cat("Study Type: Randomized Controlled Trial (RCT)\n")
cat("Duration: 4 weeks\n")
cat("Allocation: 50% Control, 50% Treatment\n")
cat("Randomization Unit: Ad segment (age, gender, interest)\n")

# Primary hypothesis H0 
cat("\n=== Hypotheses ===\n")
cat("H0 (Null): Budget allocation does NOT improve CPA\n")
cat("Ha (Alternative): Budget allocation IMPROVES (reduces) CPA\n")
cat("Significance Level: α = 0.05\n")
cat("Power: 80%\n")

# Effect size and power analysis
effect_size_percent <- 0.05  # 5% improvement target
effect_size <- baseline$baseline_cpa * effect_size_percent

cat("\n=== Effect Size ===\n")
cat("Baseline CPA:", round(baseline$baseline_cpa, 2), "\n")
cat("Target CPA Reduction:", round(effect_size, 2), "\n")
cat("Target CPA:", round(baseline$baseline_cpa - effect_size, 2), "\n")

# Sample size calculation 
# Use two-sample t-test: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 / delta^2
z_alpha <- 1.96  # 0.05 two-sided
z_beta <- 0.84   
sd <- baseline$sd_cpa

sample_size_per_group <- ceiling(2 * ((z_alpha + z_beta)^2) * (sd^2) / (effect_size^2))

cat("\n=== Sample Size Calculation ===\n")
cat("Sample size per group:", sample_size_per_group, "\n")
cat("Total sample size:", sample_size_per_group * 2, "\n")

# Secondary metrics
cat("\n=== Secondary Metrics ===\n")
cat("1. Conversion Rate: Increase approved conversions\n")
cat("2. Cost Per Click: Monitor changes in CPC\n")
cat("3. Impressions/Reach: Track reach consistency\n")
cat("4. Return on Ad Spend (ROAS): Calculate overall ROI\n")
cat("5. Budget Efficiency Score: Model-derived efficiency metric\n")

# Test execution timeline
cat("\n=== Test Timeline ===\n")
cat("Week 1: Test setup and randomization\n")
cat("Week 1-4: Data collection\n")
cat("Week 5: Data analysis and reporting\n")

# Assumptions
cat("\n=== Key Assumptions ===\n")
cat("1. Segments are independent (no cross-segment contamination)\n")
cat("2. Test duration is sufficient to observe effect\n")
cat("3. Seasonal effects are minimal\n")
cat("4. External factors (market, competitors) remain stable\n")

# Create test design summary
test_design_summary <- tibble(
  Metric = c("Baseline CPA", "Target CPA Reduction %", "Expected New CPA", 
             "Sample Size per Group", "Total Sample Size", "Test Duration (weeks)",
             "Significance Level", "Statistical Power"),
  Value = c(
    round(baseline$baseline_cpa, 2),
    "5%",
    round(baseline$baseline_cpa - effect_size, 2),
    sample_size_per_group,
    sample_size_per_group * 2,
    4,
    "0.05",
    "0.80"
  )
)

# Save test design
write_csv(test_design_summary, "data/processed/ab_test_design_summary.csv")
cat("\n\nTest design summary saved.\n")
