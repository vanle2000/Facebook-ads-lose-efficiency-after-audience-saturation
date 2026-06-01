# Meta Ads Lose Efficiency After Audience Saturation: High-Spend Campaigns Drive Clicks but Not Proportional Purchases

Meta advertisers are spending more to increase reach, but not all spend converts efficiently. High-spend ad segments can generate more clicks without producing proportional approved conversions. This project builds an end-to-end SQL + R machine learning workflow to identify low-efficiency advertising segments, evaluate campaign performance, and simulate budget reallocation strategies that improve conversion efficiency without increasing total spend.


## Problem

Paid advertising teams need to decide where to allocate budget across campaigns, audience groups, and interest segments. A campaign segment may generate impressions and clicks, but still fail to produce approved conversions. This creates wasted spend and lowers return on ad budget.

This project answers:

> Which campaign-audience segments are likely to underperform, and how can budget be reallocated toward higher-conversion segments?

---

## Key Objectives

- Build a reproducible SQL + R data pipeline from raw ad campaign data
- Engineer campaign efficiency metrics including CTR, CPC, CPM, CPA, ROAS, and conversion rate
- Use statistical testing to evaluate whether performance differs across audience segments
- Train regression and classification models to predict approved conversions and low-efficiency segments
- Evaluate models using RMSE, MAE, ROC-AUC, precision, recall, and cross-validation
- Build a budget reallocation simulator to estimate conversion lift and CPA reduction
- Create a Shiny dashboard for business-facing campaign monitoring and recommendations
- Design an A/B test to validate whether model-guided budget allocation improves performance

I used SQL for data transformation, R for statistical analysis and machine learning, and Shiny for dashboarding. It predicts low-efficiency ad segments, evaluates model performance, and translates model outputs into business recommendations through a budget reallocation simulator.

---

## Dataset

The dataset contains Facebook advertising campaign records with campaign identifiers, audience attributes, engagement metrics, spend, and conversion outcomes.

Main fields include:

| Field | Description |
|---|---|
| `ad_id` | Unique ad identifier |
| `xyz_campaign_id` | Campaign ID |
| `fb_campaign_id` | Facebook campaign tracking ID |
| `age` | Audience age group |
| `gender` | Audience gender |
| `interest` | Audience interest segment |
| `Impressions` | Number of times the ad was shown |
| `Clicks` | Number of clicks |
| `Spent` | Amount spent on the ad |
| `Total_Conversion` | Number of users who enquired after seeing the ad |
| `Approved_Conversion` | Number of users who purchased after seeing the ad |

---

## Tech Stack

| Area | Tools |
|---|---|
| Data transformation | SQL, DuckDB |
| Analysis | R, tidyverse, dplyr |
| Machine learning | tidymodels, XGBoost, random forest, logistic regression |
| Model evaluation | yardstick, rsample |
| Visualization | ggplot2, plotly |
| Dashboard | Shiny |
| Reporting | Quarto / R Markdown |
| Reproducibility | renv, Makefile |
| Version control | Git, GitHub |

---

## Project Architecture

```text
ad-budget-optimization/
│
├── README.md
├── renv.lock
├── Makefile
├── .gitignore
│
├── data/
│   ├── raw/
│   │   └── Facebook_ads_KAG.csv
│   └── processed/
│       └── ads_modeling_table.csv
│
├── sql/
│   ├── 01_create_ads_table.sql
│   ├── 02_campaign_metrics.sql
│   ├── 03_segment_efficiency.sql
│   └── 04_budget_reallocation_candidates.sql
│
├── R/
│   ├── 01_clean_data.R
│   ├── 02_feature_engineering.R
│   ├── 03_sql_pipeline.R
│   ├── 04_eda.R
│   ├── 05_inference_tests.R
│   ├── 06_train_models.R
│   ├── 07_evaluate_models.R
│   ├── 08_error_analysis.R
│   ├── 09_budget_simulator.R
│   └── 10_ab_test_design.R
│
├── dashboard/
│   └── app.R
│
├── visuals/
│   ├── spend_vs_conversions.png
│   ├── segment_efficiency.png
│   ├── model_performance.png
│   └── budget_reallocation_simulation.png
│
├── reports/
│   ├── executive_summary.md
│   ├── final_case_study.qmd
│   ├── experiment_design.md
│   └── model_card.md
│
└── tests/
    └── test_feature_engineering.R/
