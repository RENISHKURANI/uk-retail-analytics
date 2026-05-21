import pandas as pd
from sqlalchemy import create_engine
import urllib

# --- Step 1: Read both Excel sheets ---
file_path = r"C:\Users\renis\Downloads\retail-data\online_retail_II.xlsx"

print("Reading Excel sheets...")
df_2009 = pd.read_excel(file_path, sheet_name="Year 2009-2010")
df_2010 = pd.read_excel(file_path, sheet_name="Year 2010-2011")

# --- Step 2: Combine into one dataframe ---
df = pd.concat([df_2009, df_2010], ignore_index=True)
print(f"Total rows: {len(df):,}")
print(df.head())

# --- Step 3: Connect to SQL Server ---
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=RetailAnalytics;"
    "Trusted_Connection=yes;"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# --- Step 4: Write to SQL table ---
print("Loading to SQL Server...")
df.to_sql("RawTransactions", engine, if_exists="replace", index=False, chunksize=1000)
print("Done.")