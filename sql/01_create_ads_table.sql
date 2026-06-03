-- 01_create_ads_table.sql
-- Purpose: Load raw Facebook ads data and create base table
-- Dependencies: data/raw/Facebook_ads_KAG.csv

CREATE TABLE IF NOT EXISTS ads_raw AS
SELECT 
  ad_id,
  xyz_campaign_id,
  fb_campaign_id,
  age,
  gender,
  interest,
  Impressions,
  Clicks,
  Spent,
  Total_Conversion,
  Approved_Conversion
FROM read_csv_auto('data/raw/Facebook_ads_KAG.csv');

-- Add data quality checks
ALTER TABLE ads_raw ADD CONSTRAINT check_impressions CHECK (Impressions >= 0);
ALTER TABLE ads_raw ADD CONSTRAINT check_clicks CHECK (Clicks >= 0);
ALTER TABLE ads_raw ADD CONSTRAINT check_conversions CHECK (Total_Conversion >= 0);
ALTER TABLE ads_raw ADD CONSTRAINT check_approved CHECK (Approved_Conversion >= 0);
ALTER TABLE ads_raw ADD CONSTRAINT check_spent CHECK (Spent >= 0);
