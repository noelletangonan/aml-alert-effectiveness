# AML Alert Effectiveness & Rule Tuning Analysis

## Overview

This project analyses the effectiveness of simulated AML transaction monitoring rules using SQL and Power BI.

The objective was to identify rules generating high volumes of false-positive alerts, estimate the resulting analyst workload, and test whether rule thresholds could be adjusted to reduce unnecessary reviews without materially reducing detection coverage.

The analysis was built using the synthetic SAML-D transaction monitoring dataset and PostgreSQL, with Power BI used to present the findings.


## Business Problem

Transaction monitoring teams can generate large volumes of alerts that require manual analyst review.

If monitoring rules are too broad, analysts may spend significant time reviewing legitimate activity while only a small proportion of alerts result in meaningful detections.

This project focuses on three questions:

1. Which monitoring rules generate the highest false-positive workload?
2. Which rules provide the lowest alert yield?
3. Can rule thresholds be adjusted to reduce analyst workload while retaining suspicious detections?


## Tools Used

- PostgreSQL
- SQL
- Power BI
- DAX


## Dataset

The project uses the synthetic SAML-D AML transaction dataset.

The dataset contains approximately:

- 9.5 million transactions
- 292,000+ sender accounts
- 652,000+ receiver accounts
- 9,873 laundering-labelled transactions
- Multiple payment types and AML typologies

The laundering-labelled transactions represent approximately 0.10% of the overall transaction population.


## Monitoring Rules

Four simulated transaction monitoring rules were created:

1. High-Value Cross-Border
2. High-Value Cash Deposit
3. High-Value Cash Withdrawal
4. High Daily Transaction Velocity

Rule thresholds were chosen based on transaction patterns found during the initial data analysis.


## Rule Effectiveness

| Rule | Total Alerts | True Positives | False Positives | False Positive Rate | Alert Yield | Alerts per True Positive |
| High Daily Transaction Velocity | 13,062 | 5 | 13,057 | 99.96% | 0.04% | 2,612 |
| High-Value Cash Deposit | 11,386 | 312 | 11,074 | 97.26% | 2.74% | 36 |
| High-Value Cash Withdrawal | 14,299 | 65 | 14,234 | 99.55% | 0.45% | 220 |
| High-Value Cross-Border | 47,178 | 221 | 46,957 | 99.53% | 0.47% | 213 |

The analysis showed that all four rules generated substantial false-positive workload.

The High Daily Transaction Velocity rule was particularly inefficient, requiring more than 2,600 alerts per true-positive detection.

The High-Value Cross-Border rule generated the largest analyst workload.


## Rule Tuning

The High-Value Cross-Border rule was tested using a higher threshold.

| Metric | Current Rule | Tested Rule |
|---|---:|---:|
| Threshold | 23,500 | 30,000 |
| Alerts | 47,178 | 25,924 |
| True Positives | 221 | 177 |
| False Positives | 46,957 | 25,747 |

Increasing the threshold:

- Reduced alert volume by 45.05%
- Retained 80.09% of true-positive detections
- Reduced estimated review workload by 21,254 hours
- Reduced estimated false-positive review workload by 21,210 hours

However, 44 true-positive detections were lost.


## Recommendation

Threshold-only tuning is not recommended.

Increasing the cross-border threshold substantially reduced workload, but also reduced detection coverage by around 20%.

A stronger approach would be to retain the existing threshold while testing additional behavioural or risk indicators such as:

- Transaction frequency
- Multiple beneficiaries
- Repeated cross-border activity
- Currency differences
- Changes from normal account behaviour


## Dashboard

### Executive Overview

![Executive Overview](<Executive Overview.PNG>)

### Rule Effectiveness

![Rule Effectiveness](<Rule Effectiveness.PNG>)

### Rule Tuning

![Rule Tuning](<Rule Tuning.PNG>)


## Limitations

- The project uses synthetic AML data.
- The monitoring rules were created for this analysis and are not real bank rules.
- Analyst workload is estimated using 1 hour per alert.
- Some parts of the dataset showed unrealistic patterns, especially cash deposits.
- Real AML rule tuning would need more customer and behavioural data.
- Any real rule changes would need further testing and approval.

