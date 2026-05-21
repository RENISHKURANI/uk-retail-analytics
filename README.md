# UK Retail Sales Analytics

> Junior analyst portfolio project — analysing 1M+ rows of UK e-commerce data using SQL Server and Power BI to surface trends in revenue, customer behaviour, and operational patterns.

**Status:** In progress (Day 1 of 4 complete).

## Dataset

UCI Online Retail II — UK online retail transactions, Dec 2009 – Dec 2011.
- Raw rows: ~1,067,000
- After cleaning: ~805,000 (excluded NULL CustomerIDs, zero/negative prices, NULL descriptions)
- Source: https://archive.ics.uci.edu/dataset/502/online+retail+ii

## Tech Stack

- **Database:** Microsoft SQL Server Express + SSMS
- **ETL:** Python 3.12 (pandas, openpyxl, SQLAlchemy, pyodbc)
- **Analysis:** T-SQL with CTEs and window functions
- **Visualisation:** Power BI Desktop (coming Day 3–4)

## Progress

### Day 1 (complete)
- [x] Loaded both years of Excel data into SQL Server (~1.07M rows)
- [x] Cleaned and shaped into `dbo.Transactions` with derived columns and indexes
- [x] Q1 — Monthly revenue trend with year-over-year % change
- [x] Q2 — Top 10 products by revenue with % of total

### Day 2 (planned)
- [ ] Q3 — RFM customer segmentation
- [ ] Q4 — Country-level performance
- [ ] Q5 — Time-of-day and day-of-week purchase patterns
- [ ] Q6 — Returns analysis

### Day 3 (planned)
- [ ] Q7 — Customer cohort retention
- [ ] Q8 — Pareto check on customer concentration
- [ ] Power BI Page 1: Executive Overview

### Day 4 (planned)
- [ ] Power BI Page 2: Customer Insights
- [ ] Power BI Page 3: Operational Patterns
- [ ] Final README with screenshots, architecture diagram, reflection

## Repo Structure
uk-retail-analytics/
├── notebooks/
│   └── 01-load-data.py        # ETL from Excel into SQL Server
├── sql/
│   ├── 00-clean-data.sql      # Builds dbo.Transactions
│   ├── 01-revenue-trend.sql   # Q1
│   └── 02-top-products.sql    # Q2
└── powerbi/                    # Dashboards (Day 3-4)

## How to Reproduce

1. Download `online_retail_II.xlsx` from the UCI link above
2. Save to `C:\Users\renis\Downloads\retail-data\`
3. Create an empty SQL Server database called `RetailAnalytics`
4. Run `python notebooks/01-load-data.py` to populate `RawTransactions`
5. Run `sql/00-clean-data.sql` in SSMS to build `Transactions`
6. Run any `sql/0X-*.sql` to reproduce that analysis