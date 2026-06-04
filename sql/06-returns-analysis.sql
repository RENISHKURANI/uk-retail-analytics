WITH product_stats AS (
    SELECT
        StockCode,
        Description,
        SUM(CASE WHEN IsReturn = 0 THEN LineRevenue ELSE 0 END) AS gross_revenue,
        SUM(CASE WHEN IsReturn = 1 THEN ABS(LineRevenue) ELSE 0 END) AS returned_value,
        SUM(CASE WHEN IsReturn = 0 THEN Quantity ELSE 0 END) AS units_sold,
        SUM(CASE WHEN IsReturn = 1 THEN ABS(Quantity) ELSE 0 END) AS units_returned
    FROM dbo.Transactions
    GROUP BY StockCode, Description
)
SELECT TOP 20
    StockCode,
    Description,
    CAST(gross_revenue AS DECIMAL(12,2)) AS gross_revenue,
    CAST(returned_value AS DECIMAL(12,2)) AS returned_value,
    units_sold,
    units_returned,
    CAST(
        100.0 * returned_value / NULLIF(gross_revenue, 0)
    AS DECIMAL(10,2)) AS return_rate_pct
FROM product_stats
WHERE gross_revenue > 1000  -- only meaningful products, ignore tiny noise
ORDER BY return_rate_pct DESC;