import psycopg2

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "loan_default_db",  
    "user": "postgres",
    "password": "xxxxxxxx",
}

DATA_FILE = "C:\Users\chowd\Downloads\statlog+german+credit+data\german.data" 
                         


SEX_MAP = {"A91": "male", "A92": "female", "A93": "male", "A94": "male", "A95": "female"}
MARITAL_MAP = {
    "A91": "divorced/separated", "A92": "divorced/separated/married",
    "A93": "single", "A94": "married/widowed", "A95": "single",
}
JOB_MAP = {
    "A171": "unemployed/unskilled non-resident", "A172": "unskilled resident",
    "A173": "skilled employee/official", "A174": "management/self-employed/highly qualified",
}
HOUSING_MAP = {"A151": "rent", "A152": "own", "A153": "for free"}
CHECKING_MAP = {"A11": "< 0 DM", "A12": "0-200 DM", "A13": ">= 200 DM", "A14": "no checking account"}
CREDIT_HISTORY_MAP = {
    "A30": "no credits taken/all paid back duly", "A31": "all credits at this bank paid back duly",
    "A32": "existing credits paid back duly till now", "A33": "delay in paying off in the past",
    "A34": "critical account/other credits existing",
}
PURPOSE_MAP = {
    "A40": "car (new)", "A41": "car (used)", "A42": "furniture/equipment",
    "A43": "radio/television", "A44": "domestic appliances", "A45": "repairs",
    "A46": "education", "A47": "vacation", "A48": "retraining", "A49": "business",
    "A410": "other",
}
SAVINGS_MAP = {
    "A61": "< 100 DM", "A62": "100-500 DM", "A63": "500-1000 DM",
    "A64": ">= 1000 DM", "A65": "unknown/none",
}
EMPLOYMENT_MAP = {
    "A71": "unemployed", "A72": "< 1 year", "A73": "1-4 years",
    "A74": "4-7 years", "A75": ">= 7 years",
}
OTHER_DEBTORS_MAP = {"A101": "none", "A102": "co-applicant", "A103": "guarantor"}
PROPERTY_MAP = {
    "A121": "real estate", "A122": "building society savings/life insurance",
    "A123": "car or other", "A124": "unknown/none",
}
OTHER_INSTALLMENT_MAP = {"A141": "bank", "A142": "stores", "A143": "none"}
RISK_MAP = {"1": "good", "2": "bad"}


def parse_row(line):
    fields = line.split()
    if len(fields) != 21:
        raise ValueError(f"Expected 21 fields, got {len(fields)}: {line}")
    return fields


def main():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    with open(DATA_FILE, "r") as f:
        rows_loaded = 0
        for line in f:
            line = line.strip()
            if not line:
                continue

            (checking_status, duration, credit_history, purpose, credit_amount,
             savings_status, employment_since, installment_rate, personal_status_sex,
             other_debtors, residence_since, property_, age, other_installment_plans,
             housing, existing_credits, job, num_dependents, telephone,
             foreign_worker, risk_code) = parse_row(line)

       
            cur.execute(
                """
                INSERT INTO customers
                    (age, sex, marital_status, job, housing, residence_since,
                     num_dependents, has_telephone, is_foreign_worker)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING customer_id
                """,
                (
                    int(age),
                    SEX_MAP[personal_status_sex],
                    MARITAL_MAP[personal_status_sex],
                    JOB_MAP[job],
                    HOUSING_MAP[housing],
                    int(residence_since),
                    int(num_dependents),
                    telephone == "A192",
                    foreign_worker == "A201",
                ),
            )
            customer_id = cur.fetchone()[0]

           
            cur.execute(
                """
                INSERT INTO loans
                    (customer_id, checking_status, duration_months, credit_history, purpose,
                     credit_amount, savings_status, employment_since, installment_rate_pct,
                     other_debtors, property, other_installment_plans, existing_credits_count, risk)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    customer_id,
                    CHECKING_MAP[checking_status],
                    int(duration),
                    CREDIT_HISTORY_MAP[credit_history],
                    PURPOSE_MAP.get(purpose, "other"),
                    float(credit_amount),
                    SAVINGS_MAP[savings_status],
                    EMPLOYMENT_MAP[employment_since],
                    int(installment_rate),
                    OTHER_DEBTORS_MAP[other_debtors],
                    PROPERTY_MAP[property_],
                    OTHER_INSTALLMENT_MAP[other_installment_plans],
                    int(existing_credits),
                    RISK_MAP[risk_code],
                ),
            )
            rows_loaded += 1

    conn.commit()
    cur.close()
    conn.close()
    print(f"Loaded {rows_loaded} customers and {rows_loaded} loans.")


if __name__ == "__main__":
    main()