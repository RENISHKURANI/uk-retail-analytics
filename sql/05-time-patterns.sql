SELECT
    DATENAME(WEEKDAY, InvoiceDate) AS day_name,
    DATEPART(WEEKDAY, InvoiceDate) AS day_number,
    DATEPART(HOUR, InvoiceDate) AS hour_of_day,
    COUNT(DISTINCT Invoice) AS order_count
FROM dbo.Transactions
WHERE IsReturn = 0
GROUP BY 
    DATENAME(WEEKDAY, InvoiceDate),
    DATEPART(WEEKDAY, InvoiceDate),
    DATEPART(HOUR, InvoiceDate)
ORDER BY day_number, hour_of_day;