/*
  02-top-products.sql
  Q2: Which 10 products drive the most revenue, and what % of total
      revenue do they represent?

  Approach:
    - CTE aggregates revenue, units, and order presence per product
    - SUM(total_revenue) OVER () computes grand total as a window function,
      letting us express each product as a % of the whole on the same row.
*/

WITH product_revenue AS (
    SELECT
        StockCode,
        Description,
        SUM(LineRevenue) AS total_revenue,
        SUM(Quantity) AS total_units_sold,
        COUNT(DISTINCT Invoice) AS orders_appeared_in
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY StockCode, Description
)
SELECT TOP 10
    StockCode,
    Description,
    total_revenue,
    total_units_sold,
    orders_appeared_in,
    CAST(
        100.0 * total_revenue / SUM(total_revenue) OVER ()
    AS DECIMAL(10,2)) AS pct_of_total_revenue
FROM product_revenue
ORDER BY total_revenue DESC;