/*
  01-revenue-trend.sql
  Q1: What is monthly gross revenue across both years, and how is it
      changing year-over-year?

  Approach:
    - Aggregate Transactions by calendar month (gross sales only, excluding returns)
    - Use LAG(revenue, 12) window function to fetch same-month-last-year value
    - Compute YoY % change with NULLIF guard against divide-by-zero
*/

WITH monthly AS (
    SELECT
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS month_start,
        SUM(LineRevenue) AS revenue,
        COUNT(DISTINCT Invoice) AS order_count
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
)
SELECT
    month_start,
    revenue,
    order_count,
    LAG(revenue, 12) OVER (ORDER BY month_start) AS revenue_same_month_last_year,
    CAST(
        100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month_start))
              / NULLIF(LAG(revenue, 12) OVER (ORDER BY month_start), 0)
    AS DECIMAL(10,2)) AS yoy_pct_change
FROM monthly
ORDER BY month_start;