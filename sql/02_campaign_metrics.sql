-- 02_campaign_metrics.sql
-- Purpose: Calculate campaign-level performance metrics
-- Metrics: CTR, CPC, CPM, CPA, ROAS, conversion_rate

CREATE TABLE IF NOT EXISTS campaign_metrics AS
SELECT 
  xyz_campaign_id,
  fb_campaign_id,
  COUNT(DISTINCT ad_id) as num_ads,
  SUM(Impressions) as total_impressions,
  SUM(Clicks) as total_clicks,
  SUM(Spent) as total_spend,
  SUM(Total_Conversion) as total_conversion_inquiries,
  SUM(Approved_Conversion) as total_approved_conversions,
  
  -- Performance Metrics
  CASE 
    WHEN SUM(Impressions) > 0 THEN ROUND(CAST(SUM(Clicks) AS FLOAT) / SUM(Impressions), 4)
    ELSE 0 
  END as ctr, -- Click-Through Rate
  
  CASE 
    WHEN SUM(Clicks) > 0 THEN ROUND(SUM(Spent) / SUM(Clicks), 2)
    ELSE 0 
  END as cpc, -- Cost-Per-Click
  
  CASE 
    WHEN SUM(Impressions) > 0 THEN ROUND(SUM(Spent) / (SUM(Impressions) / 1000.0), 2)
    ELSE 0 
  END as cpm, -- Cost-Per-Mille (thousand impressions)
  
  CASE 
    WHEN SUM(Approved_Conversion) > 0 THEN ROUND(SUM(Spent) / SUM(Approved_Conversion), 2)
    ELSE 0 
  END as cpa, -- Cost-Per-Approved-Conversion
  
  CASE 
    WHEN SUM(Total_Conversion) > 0 THEN ROUND(CAST(SUM(Approved_Conversion) AS FLOAT) / SUM(Total_Conversion), 4)
    ELSE 0 
  END as conversion_rate -- Approved/Total Conversions
  
FROM ads_raw
GROUP BY xyz_campaign_id, fb_campaign_id;
