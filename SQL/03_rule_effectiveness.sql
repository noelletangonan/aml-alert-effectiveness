-- AML RULE ANALYSIS - RULE EFFECTIVENESS

-- 1. RULE EFFECTIVENESS SUMMARY
SELECT
    r.rule_name,
    COUNT(*) AS total_alerts,
    SUM(CASE WHEN a.is_laundering = 1 THEN 1 ELSE 0 END) AS true_positives,
    SUM(CASE WHEN a.is_laundering = 0 THEN 1 ELSE 0 END) AS false_positives,
    ROUND(
        100.0 *
        SUM(CASE WHEN a.is_laundering = 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS false_positive_rate
FROM alerts a
JOIN monitoring_rules r
    ON a.rule_id = r.rule_id
GROUP BY r.rule_name
ORDER BY false_positive_rate DESC;


-- 2. ALERT YIELD BY RULE

SELECT
    r.rule_name,
    COUNT(*) AS total_alerts,
    SUM(CASE WHEN a.is_laundering = 1 THEN 1 ELSE 0 END) AS true_positives,
    ROUND(
        100.0 *
        SUM(CASE WHEN a.is_laundering = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS alert_yield
FROM alerts a
JOIN monitoring_rules r
    ON a.rule_id = r.rule_id
GROUP BY r.rule_name
ORDER BY alert_yield DESC;


-- 3. ESTIMATED ANALYST WORKLOAD

SELECT
    r.rule_name,
    COUNT(*) AS total_alerts,

    COUNT(*) * 1.0 AS estimated_review_hours,

    SUM(
        CASE
            WHEN a.is_laundering = 0 THEN 1
            ELSE 0
        END
    ) AS false_positive_alerts,

    SUM(
        CASE
            WHEN a.is_laundering = 0 THEN 1
            ELSE 0
        END
    ) * 1.0 AS estimated_false_positive_hours

FROM alerts a
JOIN monitoring_rules r
    ON a.rule_id = r.rule_id
GROUP BY r.rule_name
ORDER BY estimated_false_positive_hours DESC;


-- 4. ALERTS PER TRUE POSITIVE

SELECT
    r.rule_name,
    COUNT(*) AS total_alerts,
    SUM(CASE WHEN a.is_laundering = 1 THEN 1 ELSE 0 END) AS true_positives,

    ROUND(
        COUNT(*)::NUMERIC /
        NULLIF(
            SUM(CASE WHEN a.is_laundering = 1 THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS alerts_per_true_positive

FROM alerts a
JOIN monitoring_rules r
    ON a.rule_id = r.rule_id
GROUP BY r.rule_name
ORDER BY alerts_per_true_positive DESC;