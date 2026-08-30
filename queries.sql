-- 1. Default rate by credit history
SELECT
    credit_history,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
GROUP BY credit_history
ORDER BY default_rate_pct DESC;


-- 2. Default rate by checking account status

SELECT
    checking_status,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
GROUP BY checking_status
ORDER BY default_rate_pct DESC;


-- 3. Default rate by loan purpose

SELECT
    purpose,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
GROUP BY purpose
ORDER BY default_rate_pct DESC;


-- 4. Default rate by job category

SELECT
    customers.job,
    ROUND(100 * AVG(CASE WHEN loans.risk = 'bad' THEN 1.0 ELSE 0.0 END), 1) AS default_rate_pct
FROM loans
JOIN customers ON loans.customer_id = customers.customer_id
GROUP BY customers.job
ORDER BY default_rate_pct DESC;


-- 5. Default rate by number of existing credits at the bank

SELECT
    existing_credits_count,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
GROUP BY existing_credits_count
ORDER BY existing_credits_count;


-- 6. Average credit amount and duration: good vs bad risk --> Do larger or longer loans default more?
SELECT
    risk,
    ROUND(AVG(credit_amount), 2) AS avg_credit_amount,
    ROUND(AVG(duration_months), 1) AS avg_duration_months
FROM loans
GROUP BY risk;


-- 7. Average installment burden (% of disposable income): good vs bad risk --> Does a higher share of income going to loan payments predict default?
SELECT
    risk,
    ROUND(AVG(installment_rate_pct), 2) AS avg_installment_rate_pct
FROM loans
GROUP BY risk;


-- 8. Default rate by age bracket
SELECT
    CASE
        WHEN customers.age < 25 THEN 'under 25'
        WHEN customers.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN customers.age BETWEEN 35 AND 49 THEN '35-49'
        ELSE '50+'
    END AS age_bracket,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loans.risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN loans.risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
JOIN customers ON loans.customer_id = customers.customer_id
GROUP BY age_bracket
ORDER BY default_rate_pct DESC;


-- 9. Two-way breakdown: checking status x credit history
SELECT
    checking_status,
    credit_history,
    COUNT(*) AS total_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct
FROM loans
GROUP BY checking_status, credit_history
ORDER BY default_rate_pct DESC;


-- 10. Overall portfolio summary
SELECT
    COUNT(*) AS total_loans,
    SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(100.0 * SUM(CASE WHEN risk = 'bad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS default_rate_pct,
    ROUND(AVG(credit_amount), 2) AS avg_credit_amount
FROM loans;