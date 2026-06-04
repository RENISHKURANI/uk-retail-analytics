/*
  03-rfm-segmentation.sql
  Q3: Segment customers into Champions / Loyal / At Risk / Lost based on
      Recency, Frequency, and Monetary value.

  Approach:
    - CTE 1: aggregate R, F, M per customer
    - CTE 2: NTILE(4) to quartile-rank each dimension (4 = best)
    - Final SELECT: CASE WHEN ladder applying segment names
    - Bottom query: summary roll-up by segment

  Snapshot date hardcoded as 2011-12-09 (max InvoiceDate in dataset).
*/
WITH 
customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF(DAY, MAX(InvoiceDate), '2011-12-09') AS recency_days,
        COUNT(DISTINCT Invoice) AS frequency,
        SUM(LineRevenue) AS monetary
    FROM dbo.Transactions
    WHERE IsReturn = 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
segmented AS (
    SELECT
        CustomerID,
        monetary,
        CASE
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score = 1 THEN 'New Customers'
            WHEN r_score = 2 AND f_score >= 2 THEN 'At Risk'
            WHEN r_score = 1 AND m_score >= 3 THEN 'Cannot Lose Them'
            WHEN r_score = 1 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) AS customer_count,
    CAST(SUM(monetary) AS DECIMAL(12,2)) AS segment_revenue,
    CAST(AVG(monetary) AS DECIMAL(10,2)) AS avg_revenue_per_customer
FROM segmented
GROUP BY segment
ORDER BY segment_revenue DESC;