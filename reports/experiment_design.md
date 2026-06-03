# reports/experiment_design.md
# A/B Test Design: Budget Reallocation Validation

## Study Overview

**Objective**: Validate that model-guided budget reallocation improves campaign performance metrics

**Study Type**: Randomized Controlled Trial (RCT)

**Primary Metric**: Cost Per Approved Conversion (CPA)

**Secondary Metrics**: Conversion Rate, CTR, ROAS

## Hypotheses

- **H₀ (Null)**: Budget reallocation does NOT improve CPA
- **Hₐ (Alternative)**: Budget reallocation IMPROVES (reduces) CPA

**Significance Level (α)**: 0.05  
**Statistical Power (1-β)**: 0.80 (80%)

## Study Design

### Duration
- **Total Duration**: 4 weeks
- **Warm-up Period**: 1 week (data collection without analysis)
- **Main Study Period**: 3 weeks

### Randomization
- **Randomization Unit**: Ad segment (age, gender, interest combinations)
- **Allocation Ratio**: 50/50 Control:Treatment
- **Stratification**: By historical CPA quartile

### Treatment Definition
- **Control Group**: Current budget allocation
- **Treatment Group**: Model-optimized budget allocation
  - Reduce budget: Low-efficiency segments (bottom quartile)
  - Increase budget: High-efficiency segments (top quartile)

## Sample Size Calculation

### Inputs
- **Baseline CPA**: $XXX
- **Expected Effect Size**: 5% CPA reduction
- **Standard Deviation**: Historical σ
- **α (two-sided)**: 0.05 → Z = 1.96
- **β**: 0.20 → Z = 0.84

### Formula
```
n = 2 × [(Z_α + Z_β)² × σ²] / (effect size)²
```

### Result
- **Sample Size per Group**: XXX segments
- **Total Sample Size**: XXX segments
- **Minimum Power Achieved**: 80%

## Exclusion Criteria
- Segments with fewer than 5 conversions (historically)
- Ad groups with <$50 historical spend
- Segments with insufficient historical data

## Data Collection

### Metrics to Track
1. **Primary**
   - Cost Per Approved Conversion (CPA)
   - Total Approved Conversions

2. **Secondary**
   - Conversion Rate (Approved/Inquired)
   - Click-Through Rate (CTR)
   - Cost Per Click (CPC)
   - Return on Ad Spend (ROAS)

3. **Diagnostic**
   - Impressions (reach consistency check)
   - Clicks (engagement check)
   - Spend (allocation verification)
   - Total Conversions (inquiry volume)

### Data Quality Checks
- Daily spend reconciliation with Meta Ads Manager
- Missing data identification and handling
- Outlier detection (e.g., >3σ from mean)

## Analysis Plan

### Primary Analysis
- Two-sample t-test comparing CPA between Control and Treatment
- Calculation of 95% Confidence Interval for CPA difference
- Cohen's d for effect size quantification

### Secondary Analysis
- Intent-to-Treat (ITT) analysis
- Per-Protocol (PP) analysis
- Subgroup analyses by demographic tier

### Sensitivity Analysis
- Impact of different effect size assumptions
- Robustness to outlier exclusion
- Bootstrap confidence intervals

## Statistical Power

| Effect Size | n per group | Power |
|------------|------------|-------|
| 3% (small) | XXX | 60% |
| 5% (medium) | XXX | 80% |
| 8% (large) | XXX | 95% |

## Success Criteria

**Primary Success**: Significant CPA reduction (p < 0.05) in Treatment group

**Secondary Success**: 
- Conversion rate improvement (p < 0.10)
- No significant negative impact on impressions or reach

## Timeline

| Week | Activity |
|------|----------|
| Week 1 | Test setup, randomization, data pipeline setup |
| Week 1-4 | Active data collection |
| Week 5 | Data validation and final analysis |
| Week 6 | Report generation and recommendations |

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Insufficient power | Extend study if sample size goals not met |
| External confounds | Monitor competitor activity and market trends |
| Technical issues | Daily data validation and alert system |
| Segment contamination | Strict randomization and allocation adherence |

## Reporting

### Deliverables
1. Primary analysis report with 95% CI
2. Secondary analysis report with subgroup results
3. Data quality report and exclusion log
4. Executive summary with recommendations
5. Detailed statistical appendix

### Timeline for Reporting
- Preliminary results: End of Week 5
- Final report: End of Week 6
