DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id         SERIAL PRIMARY KEY,
    age                  INT,
    sex                  VARCHAR(10),
    marital_status       VARCHAR(30),
    job                  VARCHAR(60),
    housing              VARCHAR(20),
    residence_since      INT,          
    num_dependents       INT,
    has_telephone        BOOLEAN,
    is_foreign_worker    BOOLEAN
);

CREATE TABLE loans (
    loan_id                  SERIAL PRIMARY KEY,
    customer_id              INT REFERENCES customers(customer_id),
    checking_status          VARCHAR(60),
    duration_months          INT,
    credit_history            VARCHAR(60),
    purpose                  VARCHAR(30),
    credit_amount             NUMERIC(12,2),
    savings_status            VARCHAR(30),
    employment_since          VARCHAR(30),
    installment_rate_pct      INT,      
    other_debtors             VARCHAR(20),
    property                  VARCHAR(60),
    other_installment_plans   VARCHAR(20),
    existing_credits_count    INT,
    risk                      VARCHAR(4)  
);



