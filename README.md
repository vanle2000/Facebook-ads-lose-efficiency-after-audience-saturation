# Meta Ads Lose Efficiency After Audience Saturation: High-Spend Campaigns Drive Clicks but Not Proportional Purchases

Meta advertisers are spending more to increase reach, but not all spend converts efficiently. Build an analytics and modeling system that identifies which ad segments are likely to produce approved conversions and where budget should be reallocated.


## Main question:

Which audience segments and campaign conditions produce profitable conversions, and where does ad spend become inefficient?

## Project structure
│
├── README.md
├── requirements.R
├── renv.lock
├── data/
│   ├── raw/
│   └── processed/
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_campaign_metrics.sql
│   └── 03_segment_efficiency.sql
├── R/
│   ├── 01_clean_data.R
│   ├── 02_feature_engineering.R
│   ├── 03_eda.R
│   ├── 04_inference_tests.R
│   ├── 05_model_training.R
│   └── 06_model_evaluation.R
├── reports/
│   └── final_case_study.md
├── visuals/
└── dashboard/
