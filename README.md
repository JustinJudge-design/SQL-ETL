# SQL-ETL
A fully terminal-based ETL pipeline for a fictional online clothing store using PostgreSQL and SQL only. No GUI tools — just psql, CSVs, and clean code.

# 🧵 SQL-Only ETL Pipeline for Online Clothing Store

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## 📌 Overview

This project implements a full ETL (Extract, Transform, Load) pipeline for a fictional online clothing store using **PostgreSQL and SQL only**, without relying on GUI tools like pgAdmin. The pipeline runs entirely via `psql` commands and `.sql` scripts in a terminal or command-line environment.

---

## 🧰 Requirements

- PostgreSQL 14 or later installed and configured  
- `psql` command-line tool installed and added to your system's PATH environment variable  
- CSV file containing the clothing inventory data  
- Your SQL script file (e.g., `etl_pipeline.sql`)  
- A terminal or PowerShell environment (Windows)

---

## 🧾 Important Notes Before Running

- Replace **all instances** of the following placeholders with your actual data when running commands or editing scripts:

  - Table names (e.g., `staging_onlinestore`, `production_table`)  
  - Column names (e.g., `item_id`, `item_name`, etc.)  
  - File paths (e.g., `C:/Users/Justi/Downloads/clothing_tableETL.csv`)  

- The `\copy` command runs inside the `psql` client shell and **cannot be run as a plain SQL query**.

- The staging table is used to import raw data from CSV safely before transformation and loading into the production table.

---

## 📊 Database Schema

### 📥 Staging Table: `staging_onlinestore`

Used for initial raw data load from the CSV file.

```sql
CREATE TABLE IF NOT EXISTS staging_onlinestore (
    item_id          NUMERIC,
    item_name        VARCHAR(255),
    gender           VARCHAR(50),
    clothing_type    VARCHAR(100),
    brand            VARCHAR(100),
    price            NUMERIC(10,2),
    number_sold      INTEGER,
    remaining_stock  INTEGER
);
```

### 📦 Production Table: `production_table`

Stores cleaned, validated, and transformed data. Includes constraints and a generated column for total revenue.

```sql
CREATE TABLE IF NOT EXISTS production_table (
    id               SERIAL PRIMARY KEY,
    item_id          NUMERIC UNIQUE NOT NULL,
    item_name        VARCHAR(255) NOT NULL,
    gender           VARCHAR(50) NOT NULL,
    clothing_type    VARCHAR(100) NOT NULL,
    brand            VARCHAR(100) NOT NULL,
    price            MONEY NOT NULL,
    number_sold      INTEGER NOT NULL,
    remaining_stock  INTEGER NOT NULL,
    total_revenue    MONEY GENERATED ALWAYS AS (price * number_sold) STORED
);
```

---

## ⚙️ ETL Workflow (via psql CLI)

### Step-by-step script commands overview

```sql
-- STEP 1: Create staging table (run once)
CREATE TABLE IF NOT EXISTS staging_onlinestore (...); -- Use full schema above

-- STEP 2: Create production table (run once)
CREATE TABLE IF NOT EXISTS production_table (...); -- Use full schema above

-- STEP 3: Load CSV data into staging (run inside psql shell)
\copy staging_onlinestore(item_id, item_name, gender, clothing_type, brand, price, number_sold, remaining_stock)
FROM 'C:/path/to/clothing_tableETL.csv' WITH (FORMAT csv, HEADER true);

-- STEP 4: Transform and load into production table
INSERT INTO production_table (
    item_id, item_name, gender, clothing_type, brand, price, number_sold, remaining_stock
)
SELECT
    item_id, item_name, gender, clothing_type, brand, price::MONEY, number_sold, remaining_stock
FROM staging_onlinestore
ON CONFLICT (item_id) DO UPDATE
SET
    item_name = EXCLUDED.item_name,
    gender = EXCLUDED.gender,
    clothing_type = EXCLUDED.clothing_type,
    brand = EXCLUDED.brand,
    price = EXCLUDED.price,
    number_sold = EXCLUDED.number_sold,
    remaining_stock = EXCLUDED.remaining_stock;

-- STEP 5: Clear staging table after loading
TRUNCATE staging_onlinestore;
```

---

### ▶️ Running the pipeline example commands

```bash
psql -U your_postgres_username -d your_database_name
\i 'C:/path/to/etl_pipeline.sql'  -- Runs your ETL SQL script
\copy staging_onlinestore(item_id, item_name, gender, clothing_type, brand, price, number_sold, remaining_stock) FROM 'C:/Users/Justi/Downloads/clothing_tableETL.csv' WITH (FORMAT csv, HEADER true);
```

> **Note:** Replace all paths, usernames, database names, and table/column names accordingly.

---

## 📊 Example Queries to Validate Data

```sql
-- Calculate total revenue per clothing type
SELECT clothing_type, SUM(total_revenue) AS total_revenue
FROM production_table
GROUP BY clothing_type;

-- Count of items grouped by gender
SELECT gender, COUNT(*) AS item_count
FROM production_table
GROUP BY gender;
```

---

## 📁 Project File Structure

```
project-folder/
├── clothing_tableETL.csv        # Source CSV data file
├── etl_pipeline.sql             # SQL script containing ETL logic
├── run_etl.bat                  # Optional batch file to automate running ETL (Windows)
└── README.md                    # This documentation file
```

---

## 🪛 Optional Automation with Batch Script (Windows)

Create a `run_etl.bat` file to run your ETL script easily:

```bat
@echo off
REM Run ETL script using psql command-line tool
psql -U your_postgres_username -d your_database_name -f "C:/Users/Justi/Downloads/etl_pipeline.sql"
pause
```

Replace usernames, database names, and paths accordingly.

---

## 📝 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

If you have questions or want to contribute, feel free to open issues or submit pull requests!
