# Simulate budget reallocation from low to high efficiency segments
# Output: Impact analysis on CPA, conversion lift, and spending recommendations

library(tidyverse)
library(dplyr)

# Load data
ads_data <- read_csv("data/processed/ads_modeling_table.csv")

cat("=== Budget Reallocation Simulator ===\n")

# Segment performance summary
segment_performance <- ads_data %>%
  group_by(interest, age, gender) %>%
  summarise(
    Total_Spend = sum(Spent),
    Total_Conversions = sum(Approved_Conversion),
    Avg_CPA = mean(cpa),
    Segment_Size = n(),
    .groups = "drop"
  ) %>%
  filter(Total_Conversions >= 2) %>%
  mutate(
    efficiency_quartile = ntile(Avg_CPA, 4),
    efficiency_tier = case_when(
      efficiency_quartile == 1 ~ "HIGH",
      efficiency_quartile == 2 ~ "MEDIUM-HIGH",
      efficiency_quartile == 3 ~ "MEDIUM-LOW",
      efficiency_quartile == 4 ~ "LOW"
    )
  )

cat("\n--- Current Spending by Efficiency Tier ---\n")
tier_summary <- segment_performance %>%
  group_by(efficiency_tier) %>%
  summarise(
    Total_Spend = sum(Total_Spend),
    Total_Conversions = sum(Total_Conversions),
    Avg_CPA = mean(Avg_CPA),
    Num_Segments = n(),
    .groups = "drop"
  )
print(tier_summary)

# Simulate budget reallocation
# Move 25% from LOW efficiency to HIGH efficiency
reallocation_scenario <- segment_performance %>%
  mutate(
    budget_shift = case_when(
      efficiency_tier == "LOW" ~ -Total_Spend * 0.25,
      efficiency_tier == "HIGH" ~ 0,  # Will be calculated
      TRUE ~ 0
    )
  )

# Calculate available budget to reallocate
budget_from_low <- reallocation_scenario %>%
  filter(efficiency_tier == "LOW") %>%
  pull(budget_shift) %>%
  abs() %>%
  sum()

# Distribute to high efficiency
high_segments <- reallocation_scenario %>%
  filter(efficiency_tier == "HIGH")

if (nrow(high_segments) > 0) {
  budget_per_high_segment <- budget_from_low / nrow(high_segments)
  
  reallocation_scenario <- reallocation_scenario %>%
    mutate(
      budget_shift = case_when(
        efficiency_tier == "HIGH" ~ budget_per_high_segment,
        TRUE ~ budget_shift
      ),
      new_spend = Total_Spend + budget_shift,
      new_spend = pmax(new_spend, 0)  # No negative spend
    )
}

cat("\n--- Reallocation Scenario: Impact ---\n")
cat("Budget to reallocate from LOW tier:", round(budget_from_low, 2), "\n")

# Calculate projected impact
scenario_summary <- reallocation_scenario %>%
  group_by(efficiency_tier) %>%
  summarise(
    Current_Spend = sum(Total_Spend),
    New_Spend = sum(new_spend),
    Change_Pct = ((sum(new_spend) - sum(Total_Spend)) / sum(Total_Spend)) * 100,
    Total_Conversions = sum(Total_Conversions),
    Avg_CPA = mean(Avg_CPA),
    .groups = "drop"
  )
print(scenario_summary)

# Estimate impact
cat("\n--- Projected Impact ---\n")
total_current <- sum(reallocation_scenario$Total_Spend)
total_new <- sum(reallocation_scenario$new_spend)
current_cpa <- total_current / sum(reallocation_scenario$Total_Conversions)
new_cpa <- current_cpa * 0.95  # Assume 5% CPA improvement

cat("Total Current Spend:", round(total_current, 2), "\n")
cat("Total New Spend:", round(total_new, 2), "\n")
cat("Current Overall CPA:", round(current_cpa, 2), "\n")
cat("Projected CPA (5% improvement):", round(new_cpa, 2), "\n")
cat("CPA Improvement:", round((current_cpa - new_cpa), 2), "\n")

# Save reallocation recommendations
write_csv(reallocation_scenario, "data/processed/budget_reallocation_recommendations.csv")
cat("\nBudget recommendations saved.\n")

# Visualize budget shift
budget_plot <- reallocation_scenario %>%
  group_by(efficiency_tier) %>%
  summarise(
    Current = sum(Total_Spend),
    Proposed = sum(new_spend),
    .groups = "drop"
  ) %>%
  pivot_longer(-efficiency_tier, names_to = "Scenario", values_to = "Spend") %>%
  ggplot(aes(x = efficiency_tier, y = Spend, fill = Scenario)) +
  geom_col(position = "dodge") +
  labs(
    title = "Budget Reallocation: Current vs Proposed",
    x = "Efficiency Tier",
    y = "Total Spend ($)",
    fill = "Scenario"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

ggsave("visuals/budget_reallocation_simulation.png", budget_plot, width = 10, height = 6)
cat("Saved: visuals/budget_reallocation_simulation.png\n")

cat("\nBudget simulation completed.\n")
