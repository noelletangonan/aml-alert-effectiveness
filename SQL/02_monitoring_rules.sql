-- AML RULE ANALYSIS - MONITORING RULES


-- 1. HIGH-VALUE CROSS-BORDER
SELECT
    transaction_id,
    sender_account,
    receiver_account,
    transaction_date,
    amount,
    payment_type,
    is_laundering
FROM transactions
WHERE payment_type = 'Cross-border'
  AND amount >= 23500;


-- 2. HIGH-VALUE CASH DEPOSIT
SELECT
    transaction_id,
    sender_account,
    receiver_account,
    transaction_date,
    amount,
    payment_type,
    is_laundering
FROM transactions
WHERE payment_type = 'Cash Deposit'
  AND amount >= 5200;


-- 3. HIGH-VALUE CASH WITHDRAWAL
SELECT
    transaction_id,
    sender_account,
    receiver_account,
    transaction_date,
    amount,
    payment_type,
    is_laundering
FROM transactions
WHERE payment_type = 'Cash Withdrawal'
  AND amount >= 315;


-- 4. HIGH DAILY TRANSACTION VELOCITY
SELECT
    sender_account,
    transaction_date,
    COUNT(*) AS daily_transaction_count,
    COUNT(DISTINCT receiver_account) AS unique_receivers,
    ROUND(SUM(amount), 2) AS daily_total_amount,
    MAX(is_laundering) AS contains_laundering
FROM transactions
GROUP BY
    sender_account,
    transaction_date
HAVING COUNT(*) >= 20
ORDER BY daily_transaction_count DESC;


-- MONITORING RULE REFERENCE TABLE

CREATE TABLE IF NOT EXISTS monitoring_rules (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100),
    rule_description TEXT
);


-- ALERT TABLE

CREATE TABLE IF NOT EXISTS alerts (
    alert_id BIGSERIAL PRIMARY KEY,
    rule_id INT NOT NULL,
    transaction_id BIGINT,
    sender_account BIGINT,
    alert_date DATE,
    transaction_count INT,
    total_amount NUMERIC(18, 2),
    is_laundering SMALLINT,
    CONSTRAINT fk_rule
        FOREIGN KEY (rule_id)
        REFERENCES monitoring_rules(rule_id)
);