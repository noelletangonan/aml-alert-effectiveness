-- AML RULE ANALYSIS - DATA VALIDATION


-- 1. Total transaction count
SELECT
    COUNT(*) AS total_transactions
FROM transactions;


-- 2. Laundering label distribution
SELECT
    is_laundering,
    COUNT(*) AS transaction_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        4
    ) AS percentage
FROM transactions
GROUP BY is_laundering
ORDER BY is_laundering;


-- 3. Transaction date range
SELECT
    MIN(transaction_date) AS earliest_transaction,
    MAX(transaction_date) AS latest_transaction
FROM transactions;


-- 4. Null checks
SELECT
    COUNT(*) FILTER (WHERE transaction_time IS NULL) AS null_time,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS null_date,
    COUNT(*) FILTER (WHERE sender_account IS NULL) AS null_sender_account,
    COUNT(*) FILTER (WHERE receiver_account IS NULL) AS null_receiver_account,
    COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS null_payment_type,
    COUNT(*) FILTER (WHERE is_laundering IS NULL) AS null_laundering_label
FROM transactions;


-- 5. Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_type
ORDER BY transaction_count DESC;


-- 6. Laundering type distribution
SELECT
    laundering_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY laundering_type
ORDER BY transaction_count DESC;


-- 7. Unique accounts
SELECT
    COUNT(DISTINCT sender_account) AS unique_sender_accounts,
    COUNT(DISTINCT receiver_account) AS unique_receiver_accounts
FROM transactions;


-- 8. Transaction amount summary
SELECT
    ROUND(MIN(amount), 2) AS minimum_amount,
    ROUND(AVG(amount), 2) AS average_amount,
    ROUND(MAX(amount), 2) AS maximum_amount
FROM transactions;


-- 9. Amount percentiles
SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY amount) AS median_amount,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) AS p75_amount,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY amount) AS p90_amount,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS p95_amount,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) AS p99_amount
FROM transactions;


-- 10. Compare amounts for normal vs laundering transactions
SELECT
    is_laundering,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount), 2) AS average_amount,
    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY amount)::NUMERIC,
        2
    ) AS median_amount,
    ROUND(MAX(amount), 2) AS maximum_amount
FROM transactions
GROUP BY is_laundering
ORDER BY is_laundering;


-- 11. Laundering rate by payment type
SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(is_laundering) AS laundering_transactions,
    ROUND(
        100.0 * SUM(is_laundering) / COUNT(*),
        4
    ) AS laundering_rate
FROM transactions
GROUP BY payment_type
ORDER BY laundering_rate DESC;


-- 12. Domestic vs cross-border bank-location activity
SELECT
    CASE
        WHEN sender_bank_location = receiver_bank_location
            THEN 'Domestic'
        ELSE 'Cross-border'
    END AS transaction_scope,
    COUNT(*) AS total_transactions,
    SUM(is_laundering) AS laundering_transactions,
    ROUND(
        100.0 * SUM(is_laundering) / COUNT(*),
        4
    ) AS laundering_rate
FROM transactions
GROUP BY transaction_scope
ORDER BY laundering_rate DESC;


-- 13. Amount percentiles by payment type
SELECT
    payment_type,
    COUNT(*) AS transaction_count,
    
    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY amount)::NUMERIC,
        2
    ) AS median_amount,

    ROUND(
        PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY amount)::NUMERIC,
        2
    ) AS p90_amount,

    ROUND(
        PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY amount)::NUMERIC,
        2
    ) AS p95_amount,

    ROUND(
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY amount)::NUMERIC,
        2
    ) AS p99_amount

FROM transactions
GROUP BY payment_type
ORDER BY payment_type;


-- 14. How active are sender accounts?
SELECT
    sender_account,
    COUNT(*) AS transaction_count,
    COUNT(DISTINCT receiver_account) AS unique_receivers,
    ROUND(SUM(amount), 2) AS total_sent
FROM transactions
GROUP BY sender_account
ORDER BY transaction_count DESC
LIMIT 20;


-- 15. Sender activity per day
SELECT
    sender_account,
    transaction_date,
    COUNT(*) AS daily_transaction_count,
    COUNT(DISTINCT receiver_account) AS unique_receivers,
    ROUND(SUM(amount), 2) AS daily_total_amount
FROM transactions
GROUP BY
    sender_account,
    transaction_date
ORDER BY daily_transaction_count DESC
LIMIT 20;


-- 16. Laundering typologies
SELECT
    laundering_type,
    COUNT(*) AS laundering_transactions
FROM transactions
WHERE is_laundering = 1
GROUP BY laundering_type
ORDER BY laundering_transactions DESC;