WITH country_orders AS (
    SELECT
        Country,
        Invoice,
        SUM(LineRevenue) AS order_value,
        MAX(CustomerID) AS CustomerID  -- one customer per invoice
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY Country, Invoice
)
SELECT TOP 10
    Country,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(*) AS order_count,
    CAST(SUM(order_value) AS DECIMAL(12,2)) AS total_revenue,
    CAST(AVG(order_value) AS DECIMAL(10,2)) AS avg_order_value,
    CAST(
        100.0 * SUM(order_value) / SUM(SUM(order_value)) OVER ()
    AS DECIMAL(10,2)) AS pct_of_global_revenue
FROM country_orders
GROUP BY Country
ORDER BY total_revenue DESC;