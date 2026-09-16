"""
ETL pipeline for the DataCo Supply Chain dataset.

Source: DataCo Smart Supply Chain Dataset (Constante, Silva & Pereira, 2019)
         180,519 order-item level records, Jan 2015 - Jan 2018.

What this script does:
1. Loads the raw CSV (latin-1 encoded, 53 columns).
2. Drops columns that are unusable or unsafe to publish:
   - Product Description (100% NULL in source)
   - Product Image (URL only, not analytically useful)
   - Customer Email, Customer Password, Customer Fname/Lname, Customer Street
     -> dropped for data-privacy reasons before this is pushed to a public
        GitHub repo. Customer Id is kept so customer-level analysis (RFM,
        segmentation) still works without exposing PII.
3. Standardises column names (snake_case) and parses date columns.
4. Removes the 1 duplicate order_item_id present in the source (documented
   data-quality issue also found by other public analyses of this dataset).
5. Engineers a few analysis-ready features:
   - shipping_delay_days = days_for_shipping_real - days_for_shipment_scheduled
   - order_month (YYYY-MM) for trend analysis
6. Writes the cleaned dataset to data/cleaned_supply_chain.csv and loads it
   into a portable SQLite database (data/supply_chain.db) for the SQL layer.
"""
import pandas as pd
import sqlite3
import os

RAW_PATH = "/home/claude/project/repo/data/raw/DataCoSupplyChainDataset.csv"
OUT_DIR = "/home/claude/project/repo/data"
CLEAN_CSV = os.path.join(OUT_DIR, "cleaned_supply_chain.csv")
DB_PATH = os.path.join(OUT_DIR, "supply_chain.db")

os.makedirs(OUT_DIR, exist_ok=True)

print("Loading raw data...")
df = pd.read_csv(RAW_PATH, encoding="latin1")
print(f"Raw shape: {df.shape}")

# --- 1. Drop unusable / unsafe columns ---
drop_cols = [
    "Product Description", "Product Image",
    "Customer Email", "Customer Password", "Customer Fname", "Customer Lname",
    "Customer Street", "Customer Zipcode", "Order Zipcode",
]
df = df.drop(columns=[c for c in drop_cols if c in df.columns])

# --- 2. Standardise column names ---
def to_snake(col):
    col = col.replace("(", "").replace(")", "")
    col = col.strip().lower().replace(" ", "_").replace("-", "_")
    return col

df.columns = [to_snake(c) for c in df.columns]

# --- 3. Parse dates ---
df["order_date"] = pd.to_datetime(df["order_date_dateorders"], errors="coerce")
df["shipping_date"] = pd.to_datetime(df["shipping_date_dateorders"], errors="coerce")
df = df.drop(columns=["order_date_dateorders", "shipping_date_dateorders"])

# --- 4. Deduplicate on order_item_id ---
before = len(df)
df = df.drop_duplicates(subset=["order_item_id"], keep="last")
after = len(df)
print(f"Deduplication: {before} -> {after} rows ({before - after} duplicate(s) removed)")

# --- 5. Feature engineering ---
df["shipping_delay_days"] = df["days_for_shipping_real"] - df["days_for_shipment_scheduled"]
df["order_month"] = df["order_date"].dt.to_period("M").astype(str)

# --- 6. Save cleaned CSV ---
df.to_csv(CLEAN_CSV, index=False)
print(f"Cleaned CSV saved: {CLEAN_CSV} ({df.shape[0]} rows, {df.shape[1]} cols)")

# --- 7. Load into SQLite for the SQL layer ---
if os.path.exists(DB_PATH):
    os.remove(DB_PATH)
conn = sqlite3.connect(DB_PATH)
df.to_sql("orders", conn, index=False, if_exists="replace")
conn.execute("CREATE INDEX idx_order_region ON orders(order_region);")
conn.execute("CREATE INDEX idx_shipping_mode ON orders(shipping_mode);")
conn.execute("CREATE INDEX idx_order_month ON orders(order_month);")
conn.execute("CREATE INDEX idx_customer_id ON orders(customer_id);")
conn.commit()
conn.close()
print(f"SQLite DB written: {DB_PATH}")

print("\nData quality summary:")
print(f"- Late delivery risk rate: {df['late_delivery_risk'].mean():.1%}")
print(f"- Unique customers: {df['customer_id'].nunique()}")
print(f"- Unique products: {df['product_card_id'].nunique()}")
print(f"- Date range: {df['order_date'].min().date()} to {df['order_date'].max().date()}")
