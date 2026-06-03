-- 03_segment_efficiency.sql
-- Purpose: Identify low-efficiency audience segments
-- Segments: age, gender, interest combinations

CREATE TABLE IF NOT EXISTS segment_efficiency AS
SELECT 
  age,
  gender,
  interest,
  COUNT(DISTINCT ad_id) as num_ads,
  SUM(Impressions) as total_impressions,
  SUM(Clicks) as total_clicks,
  SUM(Spent) as total_spend,
  SUM(Approved_Conversion) as approved_conversions,
  
  CASE 
    WHEN SUM(Impressions) > 0 THEN ROUND(CAST(SUM(Clicks) AS FLOAT) / SUM(Impressions), 4)
    ELSE 0 
  END as segment_ctr,
  
  CASE 
    WHEN SUM(Clicks) > 0 THEN ROUND(SUM(Spent) / SUM(Clicks), 2)
    ELSE 0 
  END as segment_cpc,
  
  CASE 
    WHEN SUM(Approved_Conversion) > 0 THEN ROUND(SUM(Spent) / SUM(Approved_Conversion), 2)
    ELSE 0 
  END as segment_cpa
    
FROM ads_raw
GROUP BY age, gender, interest
HAVING SUM(Spent) > 100; -- Only consider segments with meaningful spend

-- Flag low-efficiency segments (high CPA, low conversion rate)
CREATE TABLE IF NOT EXISTS low_efficiency_segments AS
SELECT *,
  CASE 
    WHEN segment_cpa > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY segment_cpa) FROM segment_efficiency)
    THEN 1 ELSE 0 
  END as is_low_efficiency_flag
FROM segment_efficiency;
