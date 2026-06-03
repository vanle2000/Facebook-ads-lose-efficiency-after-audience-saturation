# tests/test_feature_engineering.R
# Purpose: Unit tests for feature engineering functions
# Framework: testthat (testing framework)

library(testthat)
library(tidyverse)
library(dplyr)

# Load source script
source("../R/02_feature_engineering.R")

context("Feature Engineering Tests")

# Test 1: CTR calculation
test_that("CTR calculation is correct", {
  test_data <- tibble(
    Impressions = c(1000, 500, 2000),
    Clicks = c(50, 25, 100)
  )
  
  expected_ctr <- c(0.05, 0.05, 0.05)
  actual_ctr <- test_data$Clicks / test_data$Impressions
  
  expect_equal(actual_ctr, expected_ctr)
})

# Test 2: CPC calculation
test_that("CPC calculation is correct", {
  test_data <- tibble(
    Clicks = c(50, 100, 200),
    Spent = c(500, 1000, 1600)
  )
  
  expected_cpc <- c(10, 10, 8)
  actual_cpc <- test_data$Spent / test_data$Clicks
  
  expect_equal(actual_cpc, expected_cpc)
})

# Test 3: CPA calculation
test_that("CPA calculation handles zero conversions", {
  test_data <- tibble(
    Spent = c(100, 200, 300),
    Approved_Conversion = c(1, 2, 0)
  )
  
  cpa <- ifelse(test_data$Approved_Conversion > 0, 
                test_data$Spent / test_data$Approved_Conversion, 
                Inf)
  
  expect_equal(cpa[1], 100)
  expect_equal(cpa[2], 100)
  expect_true(is.infinite(cpa[3]))
})

# Test 4: Conversion rate calculation
test_that("Conversion rate is between 0 and 1", {
  test_data <- tibble(
    Approved_Conversion = c(10, 5, 20),
    Total_Conversion = c(100, 50, 200)
  )
  
  conversion_rate <- test_data$Approved_Conversion / test_data$Total_Conversion
  
  expect_true(all(conversion_rate >= 0 & conversion_rate <= 1))
  expect_equal(conversion_rate[1], 0.1)
})

# Test 5: Engagement rate is non-negative
test_that("Engagement rate is non-negative", {
  test_data <- tibble(
    Clicks = c(50, 100, 75),
    Total_Conversion = c(10, 20, 15),
    Impressions = c(1000, 2000, 1500)
  )
  
  engagement_rate <- (test_data$Clicks + test_data$Total_Conversion) / test_data$Impressions
  
  expect_true(all(engagement_rate >= 0))
})

# Test 6: Feature dimensions
test_that("Feature engineering produces expected columns", {
  test_data <- tibble(
    ad_id = 1:5,
    Impressions = c(100, 200, 150, 300, 250),
    Clicks = c(5, 10, 8, 15, 12),
    Spent = c(50, 100, 80, 150, 120),
    Total_Conversion = c(1, 2, 1.5, 3, 2.5),
    Approved_Conversion = c(0, 1, 1, 2, 1)
  )
  
  expected_features <- c("ctr", "cpc", "cpm", "cpa", "conversion_rate")
  
  expect_true(all(expected_features %in% colnames(test_data)))
})

# Test 7: No negative efficiency scores
test_that("Efficiency score is non-negative", {
  test_data <- tibble(
    cpa = c(50, 100, 75, 200, 30)
  )
  
  efficiency_score <- 1 / (1 + test_data$cpa)
  
  expect_true(all(efficiency_score >= 0 & efficiency_score <= 1))
})

# Test 8: Budget efficiency ratio
test_that("Budget efficiency ratio calculation is correct", {
  test_data <- tibble(
    Clicks = c(50, 100, 75),
    Approved_Conversion = c(10, 20, 15),
    Spent = c(500, 1000, 750)
  )
  
  budget_efficiency <- (test_data$Clicks + test_data$Approved_Conversion) / test_data$Spent
  
  expect_equal(budget_efficiency[1], 0.12)
  expect_equal(budget_efficiency[2], 0.12)
  expect_equal(budget_efficiency[3], 0.12)
})

# Test 9: Data type validation
test_that("Feature columns have correct data types", {
  test_data <- tibble(
    ctr = c(0.05, 0.10, 0.08),
    cpc = c(10.5, 12.3, 9.8),
    cpa = c(100, 150, 120)
  )
  
  expect_true(is.numeric(test_data$ctr))
  expect_true(is.numeric(test_data$cpc))
  expect_true(is.numeric(test_data$cpa))
})

# Test 10: Aggregate performance
test_that("Campaign aggregation produces correct totals", {
  test_data <- tibble(
    xyz_campaign_id = c(1, 1, 1, 2, 2),
    Spent = c(100, 150, 200, 300, 400),
    Approved_Conversion = c(2, 3, 2, 5, 6)
  )
  
  campaign_totals <- test_data %>%
    group_by(xyz_campaign_id) %>%
    summarise(
      total_spend = sum(Spent),
      total_conversions = sum(Approved_Conversion)
    )
  
  expect_equal(campaign_totals$total_spend[1], 450)
  expect_equal(campaign_totals$total_spend[2], 700)
  expect_equal(campaign_totals$total_conversions[1], 7)
  expect_equal(campaign_totals$total_conversions[2], 11)
})

cat("\n=== All feature engineering tests completed ===\n")
