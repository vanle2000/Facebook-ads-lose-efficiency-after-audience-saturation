# budget_analysis.R
# Facebook Ads Budget Reallocation Analysis
# Analyze low-efficiency segments and calculate conversion lift potential

library(tidyverse)
library(dplyr)

cat("\n")
cat("================================================================================\n")
cat("🎯 Facebook Ads Budget Reallocation Analysis\n")
cat("================================================================================\n")
cat("\n")

# ============================================================================
# STEP 1: LOAD AND CLEAN DATA
# ============================================================================
cat("📥 STEP 1: Loading and Cleaning Data\n")
cat(strrep("-", 80), "\n")

tryCatch({
  ads_data <- read_csv("data/raw/Facebook_ads_KAG.csv")
  cat(sprintf("✅ Loaded %d records from data/raw/Facebook_ads_KAG.csv\n", nrow(ads_data)))
  cat(sprintf("✅ Columns: %s\n", paste(colnames(ads_data), collapse = ", ")))
}, error = function(e) {
  cat(sprintf("❌ Error loading data: %s\n", e$message))
  quit()
})

# Basic cleaning
ads_clean <- ads_data %>%
  distinct() %>%
  filter(Impressions > 0, Spent > 0)

cat(sprintf("✅ After cleaning: %d records\n", nrow(ads_clean)))
cat(sprintf("✅ Rows removed: %d\n", nrow(ads_data) - nrow(ads_clean)))
cat("\n")

# ============================================================================
# STEP 2: FEATURE ENGINEERING
# ============================================================================
cat("🔧 STEP 2: Engineering Campaign Metrics\n")
cat(strrep("-", 80), "\n")

ads_clean <- ads_clean %>%
  mutate(
    ctr = Clicks / Impressions,
    cpc = Spent / Clicks,
    cpm = (Spent / Impressions) * 1000,
    conversion_rate = Approved_Conversion / pmax(Total_Conversion, 1),
    cpa = ifelse(Approved_Conversion > 0, Spent / Approved_Conversion, max(Spent)),
    efficiency_score = 1 / (1 + cpa)
  )

cat("✅ Features engineered:\n")
cat("   • CTR (Click-Through Rate)\n")
cat("   • CPC (Cost Per Click)\n")
cat("   • CPM (Cost Per 1000 Impressions)\n")
cat("   • Conversion Rate\n")
cat("   • CPA (Cost Per Approved Conversion)\n")
cat("   • Efficiency Score\n")
cat("\n")

# Save cleaned data
write_csv(ads_clean, "data/processed/ads_modeling_table.csv")
cat("💾 Saved to: data/processed/ads_modeling_table.csv\n")
cat("\n")

# ============================================================================
# STEP 3: SEGMENT EFFICIENCY ANALYSIS
# ============================================================================
cat("📊 STEP 3: Segment Efficiency Analysis\n")
cat(strrep("-", 80), "\n")

segment_perf <- ads_clean %>%
  group_by(interest, age, gender) %>%
  summarise(
    Spent = sum(Spent, na.rm = TRUE),
    Clicks = sum(Clicks, na.rm = TRUE),
    Impressions = sum(Impressions, na.rm = TRUE),
    Approved_Conversion = sum(Approved_Conversion, na.rm = TRUE),
    Total_Conversion = sum(Total_Conversion, na.rm = TRUE),
    cpa = mean(cpa, na.rm = TRUE),
    ctr = mean(ctr, na.rm = TRUE),
    conversion_rate = mean(conversion_rate, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  filter(Approved_Conversion >= 2) %>%
  arrange(cpa)

cat(sprintf("✅ Analyzed %d segments\n", nrow(segment_perf)))
cat("\n")

# ============================================================================
# STEP 4: IDENTIFY LOW EFFICIENCY COHORTS
# ============================================================================
cat("🔍 STEP 4: Identify Budget Concentrated in Low Conversion Cohorts\n")
cat(strrep("-", 80), "\n")

# Create efficiency tiers using quartiles
quartiles <- quantile(segment_perf$cpa, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

segment_perf <- segment_perf %>%
  mutate(
    efficiency_tier = case_when(
      cpa <= quartiles[2] ~ "HIGH_EFFICIENCY",
      cpa <= quartiles[3] ~ "MEDIUM_HIGH",
      cpa <= quartiles[4] ~ "MEDIUM_LOW",
      TRUE ~ "LOW_EFFICIENCY"
    )
  )

cat("\n💰 Budget Distribution by Efficiency Tier:\n")

for (tier in c("HIGH_EFFICIENCY", "MEDIUM_HIGH", "MEDIUM_LOW", "LOW_EFFICIENCY")) {
  tier_data <- segment_perf %>% filter(efficiency_tier == tier)
  
  if (nrow(tier_data) > 0) {
    total_spend <- sum(tier_data$Spent, na.rm = TRUE)
    total_convs <- sum(tier_data$Approved_Conversion, na.rm = TRUE)
    avg_cpa <- mean(tier_data$cpa, na.rm = TRUE)
    pct_budget <- (total_spend / sum(ads_clean$Spent, na.rm = TRUE)) * 100
    
    cat(sprintf("\n   %s:\n", tier))
    cat(sprintf("   • Budget: $%.2f (%.1f%% of total)\n", total_spend, pct_budget))
    cat(sprintf("   • Conversions: %d\n", round(total_convs)))
    cat(sprintf("   • Avg CPA: $%.2f\n", avg_cpa))
    cat(sprintf("   • Num Segments: %d\n", nrow(tier_data)))
  }
}

cat("\n")

# ============================================================================
# STEP 5: BUDGET REALLOCATION SIMULATION
# ============================================================================
cat("💡 STEP 5: Budget Reallocation Scenario\n")
cat(strrep("-", 80), "\n")

# Current state
current_spend <- sum(ads_clean$Spent, na.rm = TRUE)
current_conversions <- sum(ads_clean$Approved_Conversion, na.rm = TRUE)
current_cpa <- current_spend / current_conversions
current_conversion_rate <- current_conversions / sum(ads_clean$Total_Conversion, na.rm = TRUE)

cat(sprintf("\n📈 Current State (Baseline):\n"))
cat(sprintf("   • Total Budget: $%.2f\n", current_spend))
cat(sprintf("   • Total Conversions: %d\n", round(current_conversions)))
cat(sprintf("   • Overall CPA: $%.2f\n", current_cpa))
cat(sprintf("   • Overall Conversion Rate: %.2f%%\n", current_conversion_rate * 100))

# Simulation: Move 25% budget from LOW to HIGH efficiency
low_eff_data <- segment_perf %>% filter(efficiency_tier == "LOW_EFFICIENCY")
high_eff_data <- segment_perf %>% filter(efficiency_tier == "HIGH_EFFICIENCY")

budget_from_low <- sum(low_eff_data$Spent, na.rm = TRUE) * 0.25

# Conversions analysis
low_eff_cpa <- mean(low_eff_data$cpa, na.rm = TRUE)
high_eff_cpa <- mean(high_eff_data$cpa, na.rm = TRUE)

conversions_lost_low <- budget_from_low / low_eff_cpa
conversions_gained_high <- budget_from_low / high_eff_cpa

net_conversion_change <- conversions_gained_high - conversions_lost_low
new_total_conversions <- current_conversions + net_conversion_change
new_cpa <- current_spend / new_total_conversions

conversion_lift_pct <- (net_conversion_change / current_conversions) * 100
cpa_reduction_pct <- ((current_cpa - new_cpa) / current_cpa) * 100

cat(sprintf("\n🎯 Proposed Reallocation (25%% from LOW to HIGH):\n"))
cat(sprintf("   • Budget moved: $%.2f\n", budget_from_low))
cat(sprintf("   • Conversions lost (low efficiency): %.1f\n", conversions_lost_low))
cat(sprintf("   • Conversions gained (high efficiency): %.1f\n", conversions_gained_high))
cat(sprintf("   • Net conversion change: %.1f\n", net_conversion_change))
cat(sprintf("   • Total budget: $%.2f (constant)\n", current_spend))
cat("\n")

cat(sprintf("📊 Key Metrics (Total Budget Held Constant):\n"))
cat(sprintf("   • New Total Conversions: %d\n", round(new_total_conversions)))
cat(sprintf("   • New CPA: $%.2f\n", new_cpa))
cat(sprintf("   • ✅ CONVERSION LIFT: %.2f%%\n", conversion_lift_pct))
cat(sprintf("   • ✅ CPA REDUCTION: %.2f%%\n", cpa_reduction_pct))
cat("\n")

# ============================================================================
# STEP 6: DETAILED SEGMENT ANALYSIS
# ============================================================================
cat("📋 STEP 6: Low Efficiency Segments (Top Spending)\n")
cat(strrep("-", 80), "\n")

low_eff_detail <- low_eff_data %>%
  arrange(desc(Spent)) %>%
  head(5)

for (i in 1:nrow(low_eff_detail)) {
  row <- low_eff_detail[i, ]
  cat(sprintf("\n   Interest: %s, Age: %s, Gender: %s\n", row$interest, row$age, row$gender))
  cat(sprintf("   • Spend: $%.2f\n", row$Spent))
  cat(sprintf("   • Conversions: %d\n", round(row$Approved_Conversion)))
  cat(sprintf("   • CPA: $%.2f\n", row$cpa))
  cat(sprintf("   • Conversion Rate: %.2f%%\n", row$conversion_rate * 100))
}

cat("\n\n")

cat("📋 STEP 7: High Efficiency Segments (Targets for Reallocation)\n")
cat(strrep("-", 80), "\n")

high_eff_detail <- high_eff_data %>%
  arrange(cpa) %>%
  head(5)

for (i in 1:nrow(high_eff_detail)) {
  row <- high_eff_detail[i, ]
  cat(sprintf("\n   Interest: %s, Age: %s, Gender: %s\n", row$interest, row$age, row$gender))
  cat(sprintf("   • Current Spend: $%.2f\n", row$Spent))
  cat(sprintf("   • Conversions: %d\n", round(row$Approved_Conversion)))
  cat(sprintf("   • CPA: $%.2f\n", row$cpa))
  cat(sprintf("   • Conversion Rate: %.2f%%\n", row$conversion_rate * 100))
}

cat("\n")

# ============================================================================
# STEP 8: SAVE RESULTS
# ============================================================================
cat("================================================================================\n")
cat("💾 STEP 8: Saving Results\n")
cat(strrep("-", 80), "\n")

write_csv(segment_perf, "data/processed/segment_efficiency.csv")
cat("✅ Segment analysis saved to: data/processed/segment_efficiency.csv\n")

# Save summary report
summary_data <- tibble(
  Metric = c(
    "Current Budget",
    "Current Conversions",
    "Current CPA",
    "Current Conversion Rate",
    "Proposed Budget (constant)",
    "Proposed Conversions",
    "Proposed CPA",
    "Conversion Lift %",
    "CPA Reduction %",
    "Budget Reallocated",
    "Low Eff Segments",
    "High Eff Segments"
  ),
  Value = c(
    sprintf("$%.2f", current_spend),
    round(current_conversions),
    sprintf("$%.2f", current_cpa),
    sprintf("%.2f%%", current_conversion_rate * 100),
    sprintf("$%.2f", current_spend),
    round(new_total_conversions),
    sprintf("$%.2f", new_cpa),
    sprintf("%.2f%%", conversion_lift_pct),
    sprintf("%.2f%%", cpa_reduction_pct),
    sprintf("$%.2f", budget_from_low),
    nrow(low_eff_data),
    nrow(high_eff_data)
  )
)

write_csv(summary_data, "results/budget_reallocation_summary.csv")
cat("✅ Summary report saved to: results/budget_reallocation_summary.csv\n")

# ============================================================================
# FINAL RESULTS DISPLAY
# ============================================================================
cat("\n")
cat("================================================================================\n")
cat("🎉 ANALYSIS COMPLETE - KEY FINDINGS\n")
cat("================================================================================\n")
cat("\n")

cat(sprintf("💰 Budget concentrated in LOW CONVERSION cohorts:\n"))
low_budget_pct <- (sum(low_eff_data$Spent, na.rm = TRUE) / current_spend) * 100
low_conv_pct <- (sum(low_eff_data$Approved_Conversion, na.rm = TRUE) / current_conversions) * 100

cat(sprintf("   • Low efficiency segments consume %.1f%% of budget\n", low_budget_pct))
cat(sprintf("   • But generate only %.1f%% of conversions\n", low_conv_pct))
cat("\n")

cat(sprintf("📈 WITH REALLOCATION (25%% from LOW → HIGH, budget constant):\n"))
cat(sprintf("   • ✅ Approved Conversion Lift: %.2f%%\n", conversion_lift_pct))
cat(sprintf("   • ✅ CPA Reduction: %.2f%%\n", cpa_reduction_pct))
cat(sprintf("   • ✅ Additional Conversions: %.0f\n", net_conversion_change))
cat("\n")
cat("================================================================================\n")
cat("\n")
