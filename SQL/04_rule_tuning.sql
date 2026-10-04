WITH current_rule AS (
    SELECT
        COUNT(*) AS total_alerts,
        SUM(is_laundering) AS true_positives,
        COUNT(*) - SUM(is_laundering) AS false_positives
    FROM transactions
    WHERE payment_type = 'Cross-border'
      AND amount >= 23500
),

tuned_rule AS (
    SELECT
        COUNT(*) AS total_alerts,
        SUM(is_laundering) AS true_positives,
        COUNT(*) - SUM(is_laundering) AS false_positives
    FROM transactions
    WHERE payment_type = 'Cross-border'
      AND amount >= 30000
)

SELECT
    'High-Value Cross-Border' AS rule_name,

    23500 AS current_threshold,
    30000 AS proposed_threshold,

    c.total_alerts AS current_alerts,
    t.total_alerts AS tuned_alerts,

    ROUND(
        100.0 * (c.total_alerts - t.total_alerts)
        / c.total_alerts,
        2
    ) AS alert_reduction_pct,

    c.true_positives AS current_true_positives,
    t.true_positives AS tuned_true_positives,

    ROUND(
        100.0 * t.true_positives
        / NULLIF(c.true_positives, 0),
        2
    ) AS true_positive_retention_pct,

    c.false_positives AS current_false_positives,
    t.false_positives AS tuned_false_positives,

    c.total_alerts - t.total_alerts
        AS estimated_review_hours_saved,

    c.false_positives - t.false_positives
        AS estimated_false_positive_hours_saved

FROM current_rule c
CROSS JOIN tuned_rule t;