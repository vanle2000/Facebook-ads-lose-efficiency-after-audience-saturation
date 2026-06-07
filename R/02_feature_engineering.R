# Engineer efficiency metrics and campaign features for modeling 

library(tidyverse)
library(dplyr)

# Load cleaned data
ads_clean <- read_csv("data/processed/ads_clean.csv")

# Engineer campaign efficiency metrics
ads_featured <- ads_clean %>%
  group_by(xyz_campaign_id) %>%
  mutate(
    campaign_total_spend = sum(Spent, na.rm = TRUE),
    campaign_total_impressions = sum(Impressions, na.rm = TRUE),
    campaign_total_clicks = sum(Clicks, na.rm = TRUE),
    campaign_total_conversions = sum(Approved_Conversion, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  
  # Ad-level efficiency metrics
  mutate(
    # Click-Through Rate (CTR)
    ctr = ifelse(Impressions > 0, Clicks / Impressions, 0),
    
    # Cost Per Click (CPC)
    cpc = ifelse(Clicks > 0, Spent / Clicks, 0),
    
    # Cost Per Mille (CPM) - cost per 1000 impressions
    cpm = ifelse(Impressions > 0, (Spent / Impressions) * 1000, 0),
    
    # Cost Per Approved Conversion (CPA)
    cpa = ifelse(Approved_Conversion > 0, Spent / Approved_Conversion, Inf),
    
    # Conversion Rate
    conversion_rate = ifelse(Total_Conversion > 0, Approved_Conversion / Total_Conversion, 0),
    
    # Efficiency score
    efficiency_score = ifelse(is.finite(cpa), 1 / (1 + cpa), 0),
    
    # Return on Ad Spend (ROAS)
    roas = ifelse(Spent > 0, (Approved_Conversion * Spent) / Spent, 0),
    
    # Engagement rate
    engagement_rate = (Clicks + Total_Conversion) / Impressions,
    
    # Budget efficiency ratio
    budget_efficiency = ifelse(Spent > 0, (Clicks + Approved_Conversion) / Spent, 0)
  ) %>%
  
  # Replace infinite values with practical max
  mutate(
    cpa = ifelse(is.infinite(cpa), max(cpa[is.finite(cpa)]), cpa)
  )

# Display feature engineering summary
cat("=== Feature Engineering Summary ===\n")
cat("New features created:\n")
cat("- CTR (Click-Through Rate)\n")
cat("- CPC (Cost Per Click)\n")
cat("- CPM (Cost Per Mille)\n")
cat("- CPA (Cost Per Approved Conversion)\n")
cat("- Conversion Rate\n")
cat("- Efficiency Score\n")
cat("- ROAS (Return on Ad Spend)\n")
cat("- Engagement Rate\n")
cat("- Budget Efficiency Ratio\n")

# Save featured dataset into 'ads_modeling_table.csv'
write_csv(ads_featured, "data/processed/ads_modeling_table.csv")
cat("\nFeatured dataset saved to data/processed/ads_modeling_table.csv\n")
