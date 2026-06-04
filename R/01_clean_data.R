# Load and clean raw dataset for feature engineering

library(tidyverse)
library(dplyr)

# Load raw
ads_data <- read_csv("data/raw/Facebook_ads_KAG.csv")

# Display basic info
cat("Dataset shape:", nrow(ads_data), "rows,", ncol(ads_data), "columns\n")
cat("Column names:\n")
print(colnames(ads_data))

# Data cleaning steps
ads_clean <- ads_data %>%
  # Remove duplicates
  distinct() %>%
  
  # Handle missing values
  mutate(across(everything(), ~ifelse(is.na(.), 0, .))) %>%
  
  # Remove rows with zero impressions or spend
  filter(Impressions > 0, Spent > 0) %>%
  
  # Convert data types
  mutate(
    ad_id = as.integer(ad_id),
    xyz_campaign_id = as.integer(xyz_campaign_id),
    fb_campaign_id = as.integer(fb_campaign_id),
    age = as.factor(age),
    gender = as.factor(gender),
    interest = as.factor(interest),
    Impressions = as.integer(Impressions),
    Clicks = as.integer(Clicks),
    Spent = as.numeric(Spent),
    Total_Conversion = as.integer(Total_Conversion),
    Approved_Conversion = as.integer(Approved_Conversion)
  )

# Quality checks
cat("\n=== Data Quality Checks ===\n")
cat("Missing values:\n")
print(colSums(is.na(ads_clean)))

cat("\nBasic statistics:\n")
print(summary(ads_clean))

# Save cleaned data
write_csv(ads_clean, "data/processed/ads_clean.csv")
cat("\nCleaned data saved to data/processed/ads_clean.csv\n")
