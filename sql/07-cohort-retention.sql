/*
  07-cohort-retention.sql
  Q7: For each acquisition cohort, what % of customers return month-by-month?

  Approach:
    - CTE 1: Tag each customer's first-ever purchase month via MIN() OVER (PARTITION BY)
    - CTE 2: Compute months elapsed since cohort start for each customer-month
    - CTE 3: Count active customers per (cohort, month)
    - CTE 4: Extract cohort size at month 0
    - Final SELECT: Divide to get retention % per cohort per month
*/
WITH
-- Step 1: For every transaction, attach the customer's first-ever purchase month
customer_first_month AS (
    SELECT
        CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS purchase_month,
        MIN(DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)) 
            OVER (PARTITION BY CustomerID) AS cohort_month
    FROM dbo.Transactions
    WHERE IsReturn = 0
),
-- Step 2: Calculate "months since cohort" for each customer-month combination
cohort_data AS (
    SELECT DISTINCT
        cohort_month,
        purchase_month,
        DATEDIFF(MONTH, cohort_month, purchase_month) AS months_since_cohort,
        CustomerID
    FROM customer_first_month
),
-- Step 3: Count active customers per cohort per month
cohort_counts AS (
    SELECT
        cohort_month,
        months_since_cohort,
        COUNT(DISTINCT CustomerID) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, months_since_cohort
),
-- Step 4: Get cohort size (active customers in month 0)
cohort_sizes AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_counts
    WHERE months_since_cohort = 0
)
SELECT
    c.cohort_month,
    c.months_since_cohort,
    s.cohort_size,
    c.active_customers,
    CAST(
        100.0 * c.active_customers / NULLIF(s.cohort_size, 0)
    AS DECIMAL(10,2)) AS retention_pct
FROM cohort_counts c
JOIN cohort_sizes s ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.months_since_cohort;