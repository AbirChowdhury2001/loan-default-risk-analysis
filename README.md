# Loan Default Risk Analysis

A SQL + Python + Power BI project analyzing credit risk patterns across 1,000 loan applications, built from raw data to a fully interactive dashboard.

## Business Problem

Lenders need to understand which borrower and loan characteristics are associated with default, both to price risk appropriately and to flag high-risk applications for closer review. This project builds a normalized database of loan applications and their outcomes, then analyzes what actually predicts default in this portfolio.

## Data Source

[Statlog (German Credit Data)](https://archive.ics.uci.edu/dataset/144/statlog+german+credit+data) — UCI Machine Learning Repository. 1,000 loan applications with 20 attributes each and a binary outcome label (good/bad credit risk).

## Tech Stack

- **PostgreSQL** — schema design and data storage
- **Python** (psycopg2) — ETL script to parse and load the raw dataset
- **SQL** — analytical queries
- **Power BI** — interactive dashboard

## Schema

Two normalized tables, split to separate "who the applicant is" from "what they applied for":

- **`customers`** — age, sex, marital status, job category, housing, residence duration, dependents, phone, foreign worker status
- **`loans`** — checking account status, credit history, purpose, amount, duration, savings status, employment length, installment burden, property, existing credits, and the risk outcome (good/bad)

See `schema.sql` for full table definitions and load logic.

## Key Findings

1. Credit history didn't behave the way I expected. People with "no credits taken / all paid back duly" actually had the highest default rate at 62.5%, while people with a "critical account" on record had the lowest at 17.1%. My guess is that anyone with a critical account already went through extra scrutiny to even get approved, so that group ends up safer by the time they show up in this data.

![Default rate by credit history](dashboard/default_rate_by_credit_history.png)

2. Checking account status shows a similar pattern. Being overdrawn (< 0 DM) has the highest default rate at 49.3%, which makes sense. But having no checking account at all comes out lowest at 11.7%, which I wasn't expecting. It might just mean these applicants were already screened some other way before the loan got approved.

![Default rate by checking status](dashboard/default_rate_by_checking_status.png)

3. Loan purpose actually lines up with intuition. Education loans (44.0%) and the "other" category (41.7%) default the most, while retraining (11.1%) and used car loans (16.5%) default the least. Loans tied to something concrete or structured seem to hold up better than loans for vaguer purposes.

![Default rate by purpose](dashboard/default_rate_by_purpose.png)

4. Loan amount and duration don't predict much on their own. Plotting credit amount against duration and coloring by outcome shows good and bad loans mixed together pretty evenly across the whole chart. There's a slight lean toward bigger/longer loans being riskier, but it's not a clean cutoff.

![Loan amount vs duration, colored by risk](dashboard/scatter_amount_vs_duration.png)

5. Installment burden barely moves the needle. Average installment rate (on the dataset's 1-4 scale, not an actual percent) is 3.1 for bad loans and 2.9 for good loans. That's close enough that I wouldn't call it a useful predictor by itself.

![Average installment rate by risk](dashboard/avg_installment_rate_by_risk.png)

## Note on Fair Lending

The dataset includes attributes like sex, marital status, and foreign worker status. These were intentionally excluded from the "actionable insights" above — real lenders are legally restricted from using protected characteristics in credit decisions, so this analysis focuses on financial and behavioral variables (credit history, checking status, loan purpose, installment burden) instead.

## Dashboard

Built in Power BI with three core measures (`Total Loans`, `Bad Loans`, `Default Rate`), KPI cards, and charts breaking down default rate by credit history, checking status, purpose, and installment burden, plus a scatter plot of loan size vs. duration. The full interactive file is in `dashboard/`.

