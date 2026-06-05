WITH
customer_revenue AS (
    SELECT
        CustomerID,
        SUM(LineRevenue) AS total_revenue
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        total_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        COUNT(*) OVER () AS total_customers,
        SUM(total_revenue) OVER () AS grand_total
    FROM customer_revenue
),
cumulative AS (
    SELECT
        CustomerID,
        total_revenue,
        revenue_rank,
        total_customers,
        grand_total,
        SUM(total_revenue) OVER (ORDER BY revenue_rank) AS cumulative_revenue,
        CAST(100.0 * revenue_rank / total_customers AS DECIMAL(10,2)) AS pct_of_customers,
        CAST(
            100.0 * SUM(total_revenue) OVER (ORDER BY revenue_rank) / grand_total
        AS DECIMAL(10,2)) AS pct_of_revenue
    FROM ranked
)
SELECT TOP 100
    revenue_rank,
    CustomerID,
    CAST(total_revenue AS DECIMAL(12,2)) AS total_revenue,
    pct_of_customers,
    pct_of_revenue
FROM cumulative
ORDER BY revenue_rank;

WITH
customer_revenue AS (
    SELECT CustomerID, SUM(LineRevenue) AS total_revenue
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rnk,
        total_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        COUNT(*) OVER () AS total_customers
    FROM customer_revenue
),
cumulative AS (
    SELECT
        rnk,
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY rnk) AS cumulative_revenue,
        grand_total,
        total_customers
    FROM ranked
)
SELECT
    'Top 10%' AS tier,
    CAST(100.0 * MAX(cumulative_revenue) / MAX(grand_total) AS DECIMAL(10,2)) AS pct_of_revenue
FROM cumulative WHERE rnk <= total_customers * 0.10
UNION ALL
SELECT 'Top 20%',
    CAST(100.0 * MAX(cumulative_revenue) / MAX(grand_total) AS DECIMAL(10,2))
FROM cumulative WHERE rnk <= total_customers * 0.20
UNION ALL
SELECT 'Top 50%',
    CAST(100.0 * MAX(cumulative_revenue) / MAX(grand_total) AS DECIMAL(10,2))
FROM cumulative WHERE rnk <= total_customers * 0.50;