/*
  00-clean-data.sql
  Builds dbo.Transactions from dbo.RawTransactions.

  Cleaning rules:
    - Exclude rows with NULL Customer ID (anonymous, can't segment)
    - Exclude rows with Price <= 0 (data errors)
    - Exclude rows with NULL Description (system adjustments)
    - Exclude Quantity = 0
    - Keep negative Quantities (returns) but flag them via IsReturn
  Derived columns:
    - LineRevenue = Quantity * Price
    - IsReturn = 1 if Quantity < 0 else 0
*/

IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;

SELECT
    Invoice, StockCode, Description, Quantity, InvoiceDate, Price,
    [Customer ID] AS CustomerID, Country,
    Quantity * Price AS LineRevenue,
    CASE WHEN Quantity < 0 THEN 1 ELSE 0 END AS IsReturn
INTO dbo.Transactions
FROM dbo.RawTransactions
WHERE [Customer ID] IS NOT NULL
  AND Price > 0
  AND Description IS NOT NULL
  AND Quantity <> 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Transactions_Date' AND object_id = OBJECT_ID('dbo.Transactions'))
    CREATE INDEX IX_Transactions_Date ON dbo.Transactions(InvoiceDate);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Transactions_Customer' AND object_id = OBJECT_ID('dbo.Transactions'))
    CREATE INDEX IX_Transactions_Customer ON dbo.Transactions(CustomerID);