-- 04_budget_reallocation_candidates.sql
-- Purpose: Identify high-efficiency segments to reallocate budget to
-- Strategy: Shift budget from low-efficiency to high-efficiency segments

CREATE TABLE IF NOT EXISTS budget_reallocation_candidates AS
WITH efficiency_stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY segment_cpa) as q1_cpa,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY segment_cpa) as q3_cpa,
    AVG(segment_cpa) as avg_cpa
  FROM segment_efficiency
)
SELECT 
  age,
  gender,
  interest,
  segment_cpa,
  total_spend,
  approved_conversions,
  CASE 
    WHEN segment_cpa <= (SELECT q1_cpa FROM efficiency_stats) THEN 'HIGH_EFFICIENCY'
    WHEN segment_cpa >= (SELECT q3_cpa FROM efficiency_stats) THEN 'LOW_EFFICIENCY'
    ELSE 'MEDIUM_EFFICIENCY'
  END as efficiency_tier,
  CASE 
    WHEN segment_cpa >= (SELECT q3_cpa FROM efficiency_stats) 
    THEN ROUND(total_spend * 0.25, 2) -- Reduce low-efficiency by 25%
    ELSE 0 
  END as budget_to_reallocate
FROM segment_efficiency
ORDER BY segment_cpa ASC;
