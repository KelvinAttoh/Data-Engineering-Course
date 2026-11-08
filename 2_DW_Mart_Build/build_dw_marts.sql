-- duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

-- STEP 1: DW - Create Start Schema Tables
.read 01_create_tables_dw.sql

-- STEP 2: DW - Load data from CSV files into tables
.read 02_load_schema_dw.sql

-- STEP 3: Mart - Create flat mart table
.read 03_create_flat_mart.sql

-- STEP 4: Mart - Create skills demand mart table
.read 04_create_skills_mart.sql

-- STEP 5: Mart - Create priority role mart
.read 05_create_priority_mart.sql

-- STEP 6: Mart - Update priority role mart
.read 06_update_priority_mart.sql