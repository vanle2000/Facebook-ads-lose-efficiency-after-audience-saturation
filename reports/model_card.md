# reports/model_card.md
# Model Card: Campaign Efficiency Prediction Models

## Model Overview

**Project**: Meta Ads Efficiency Analysis  
**Model Version**: 1.0  
**Last Updated**: 2024  
**Model Type**: Supervised Learning (Regression & Classification)

---

## Regression Model: Approved Conversions Prediction

### Objective
Predict the number of approved conversions for a given ad segment based on engagement and efficiency metrics.

### Model Specifications
- **Algorithm**: Random Forest Regression
- **Framework**: tidymodels (R)
- **Training Data Size**: ~XXX observations
- **Features**: 13 (Impressions, Clicks, CTR, CPC, CPA, Conversion Rate, Efficiency Score, Budget Efficiency, etc.)
- **Target Variable**: Approved_Conversion (count)

### Performance Metrics
- **RMSE** (Root Mean Squared Error): XX
- **MAE** (Mean Absolute Error): XX
- **R² Score**: XX

### Cross-Validation Results
- **5-Fold CV RMSE**: XX ± XX
- **5-Fold CV MAE**: XX ± XX

### Feature Importance (Top 5)
1. Conversion_Rate: XX%
2. Efficiency_Score: XX%
3. CTR: XX%
4. CPA: XX%
5. Clicks: XX%

---

## Classification Model: Low-Efficiency Segment Detection

### Objective
Classify segments as low-efficiency (CPA > median) to identify budget reallocation candidates.

### Model Specifications
- **Algorithm**: Random Forest Classification
- **Framework**: tidymodels (R)
- **Training Data Size**: ~XXX observations
- **Features**: 5 (CPA, Conversion_Rate, Efficiency_Score, CPC, CPM)
- **Target Variable**: low_efficiency (binary: 0=efficient, 1=inefficient)
- **Class Balance**: ~50/50

### Performance Metrics
- **Accuracy**: XX%
- **Precision**: XX%
- **Recall**: XX%
- **F1-Score**: XX%
- **ROC-AUC**: XX%

### Confusion Matrix
```
Predicted     0    1
Actual 0    XXX   XX
       1     XX  XXX
```

### Threshold Tuning
- **Current Threshold**: 0.5
- **Recommended Threshold**: 0.5 (balanced for recall/precision)

---

## Data Characteristics

### Training Data Distribution
- **Time Period**: [Date Range]
- **Geographic Coverage**: [Region/All]
- **Campaign Types**: [Types]
- **Demographic Coverage**: All age/gender combinations

### Data Quality
- **Missing Values**: < 1% (handled via imputation)
- **Outliers**: Detected and analyzed
- **Class Imbalance**: None significant

### Data Splits
- **Training**: 80% (XXX samples)
- **Testing**: 20% (XXX samples)
- **Validation**: 5-fold CV

---

## Model Limitations

1. **Temporal Dependency**: Model trained on specific time period; seasonal patterns not captured
2. **External Factors**: Market conditions, competitor activity not included
3. **Causality**: Model captures associations, not causal relationships
4. **Segment Size**: Minimum ~5 historical conversions required
5. **Generalization**: Model performance may vary for new audience combinations

---

## Ethical Considerations

### Fairness
- **Demographic Bias**: Model performance checked across age/gender groups
- **Disparate Impact**: No intentional discrimination in budget allocation

### Transparency
- Model decisions are explainable through feature importance
- Regular audits recommended for fairness

### Accountability
- Model owners: [Team Name]
- Review frequency: Quarterly
- Escalation process for model failures: [Process]

---

## Deployment Specifications

### Production Environment
- **Framework**: R + Shiny
- **Inference Frequency**: Daily (batch predictions)
- **Latency Requirement**: <1 hour

### Monitoring
- **Prediction Drift**: Compare current predictions to baseline
- **Data Drift**: Monitor input feature distributions
- **Performance Degradation**: Track prediction accuracy

### Retraining Schedule
- **Frequency**: Quarterly or upon significant drift detection
- **Retraining Data**: Last 6 months of data
- **Validation**: Test on held-out validation set before deployment

---

## Model History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial model development |

---

## Contact & Questions
- **Model Owner**: [Team Name]
- **Questions/Concerns**: [Contact Info]
