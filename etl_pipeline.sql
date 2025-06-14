-- psql commands 1:\i 'C:/path/to/etl_pipeline.sql' **Please note: replace \i 'C:/path/to/etl_pipeline.sql' with path to ETL pipeline script***
--psql command: 2: \copy staging_onlinestore(item_id, item_name, gender, clothing_type, brand, price, number_sold, remaining_stock)
FROM 'C:/Users/Justi/Downloads/clothing_tableETL.csv' WITH (FORMAT csv, HEADER true);
--***NOTE: REPLACE YOUR TABLE AND COLUMN NAMES AS NEEDED ALSO REPLACE: 'C:/path/to/clothing_tableETL.csv' with path to .CSV Spreadsheet
-- STEP 1: Create the staging table
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

-- STEP 2: Create the production table with constraints
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

-- STEP 3: Load CSV into staging (run this in psql shell manually due to \copy)
-- \copy staging_onlinestore(item_id, item_name, gender, clothing_type, brand, price, number_sold, remaining_stock)
-- FROM 'C:/path/to/clothing_tableETL.csv' WITH (FORMAT csv, HEADER true);

-- STEP 4: Transform and load into production
INSERT INTO production_table (
    item_id,
    item_name,
    gender,
    clothing_type,
    brand,
    price,
    number_sold,
    remaining_stock
)
SELECT
    item_id,
    item_name,
    gender,
    clothing_type,
    brand,
    price::MONEY,
    number_sold,
    remaining_stock
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

-- STEP 5: Clear staging table
TRUNCATE staging_onlinestore;
