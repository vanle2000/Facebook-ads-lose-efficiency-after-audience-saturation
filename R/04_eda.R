# Exploratory Data Analysis 

library(tidyverse)
library(ggplot2)

ads_data <- read_csv("data/processed/ads_modeling_table.csv")

# 1. Summary statistics
cat("\n--- Overall Metrics ---\n")
summary_stats <- ads_data %>%
  summarise(
    Total_Spend = sum(Spent, na.rm = TRUE),
    Total_Impressions = sum(Impressions, na.rm = TRUE),
    Total_Clicks = sum(Clicks, na.rm = TRUE),
    Total_Conversions = sum(Approved_Conversion, na.rm = TRUE),
    Avg_CTR = mean(ctr, na.rm = TRUE),
    Avg_CPC = mean(cpc, na.rm = TRUE),
    Avg_CPA = mean(cpa, na.rm = TRUE),
    Overall_Conversion_Rate = sum(Approved_Conversion) / sum(Total_Conversion)
  )
print(summary_stats)

# 2. Performance by demographic
cat("\n--- Performance by Age Group ---\n")
by_age <- ads_data %>%
  group_by(age) %>%
  summarise(
    Ads = n(),
    Spend = sum(Spent),
    Conversions = sum(Approved_Conversion),
    CPA = sum(Spent) / sum(Approved_Conversion),
    CTR = sum(Clicks) / sum(Impressions),
    .groups = "drop"
  )
print(by_age)

# 3. Visualization Spend vs Conversions by Campaign
plot_spend_conversions <- ggplot(ads_data, aes(x = Spent, y = Approved_Conversion, color = age)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~gender) +
  labs(
    title = "Spend vs Approved Conversions by Demographics",
    x = "Spend ($)",
    y = "Approved Conversions",
    color = "Age Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("visuals/spend_vs_conversions.png", plot_spend_conversions, width = 12, height = 8)
cat("Saved: visuals/spend_vs_conversions.png\n")

# 4. Visualization Segment Efficiency
plot_efficiency <- ads_data %>%
  group_by(interest) %>%
  summarise(
    Avg_CPA = mean(cpa),
    Total_Conversions = sum(Approved_Conversion),
    .groups = "drop"
  ) %>%
  arrange(desc(Avg_CPA)) %>%
  head(15) %>%
  ggplot(aes(x = reorder(interest, Avg_CPA), y = Avg_CPA, fill = Total_Conversions)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Segment Efficiency: Top 15 Interests by CPA",
    x = "Interest",
    y = "Cost Per Approved Conversion",
    fill = "Conversions"
  ) +
  theme_minimal()

ggsave("visuals/segment_efficiency.png", plot_efficiency, width = 10, height = 8)
cat("Saved: visuals/segment_efficiency.png\n")
