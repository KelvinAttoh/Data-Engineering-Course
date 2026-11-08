# Data WareHouse & Mart Build: Production ETL Pipeline

An end-to-end data engineering pipeline that transforms raw CSV files form Google Cloud Storage into a normalized start schema data warehouse, then builds analytical data marts.

![Data Pipeline Architecture](../Images/1_2_Project2_Data_Pipeline.png)

## Executive Summary
- **Pipeline scope:** Build a complete **ETL pipeline** from raw CSVs to star schema warehouse to analytical marts.
- **Data modeling:** Designed a **star schema** with fact tables, dimensions, and bridge tables for many-to-many relationships
- **ETL development:** Implemented **extract**, **transform**, **load** processes with idempotent operations and data quality checks
- **Mart architecture:** Created **specialized data marts** (flat, skills, priority) with additive measure and incremental update patterns

## Problem & Context
**Challenge:** Data teams need a single source of truth system-a data warehouse-to enable consistent, relaible analysis, across the organization. Additionally, specialized data marts are required to optimized resources by pre-aggregating data for specific business use cases, reducing query complexity  and improving performance for common analytical patterns.

**Soluton:** End-to-end ETL pipeline that extracts CSVs from Cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and create specialized data marts optimized for specific use cases(flat queries, skill demand analysis, priority role tracking)

## Tech Stack
- **Databases:** DuckDB (file base OLAP database with GCS integration via `httpfs`)
- **Language:** SQL (DDL for schema design, DML for data loading and transformation)
- **Data Model:** Star schema (fact + dimension + bridge tables)
- **Development:** VS Code for SQL editing + Terminal for DuckDB CLI execution
- **Automation:** Master SQL script for pipeline orchestration
- **Version Control:** Git/GitHub for version popeline scripts
- **Storage:** Google CLoud Storage for source CSV files

## Pipeline Architecture
![Data Pipeline Architetcure](../Images/1_2_Project2_Data_Pipeline.png)

The pipelien transforms job postings CSVs from Google Cloud Storage into normalized star schema data warehouse, then build specialized analytical data marts. BI tools (Excel, PowerBI, Tableau, Python) consume form both warehouse and marts.

### Data Warehouse
The data warehouse implements a star schema with `company_dim`, `skills_dim`, `job_postings_fact` and `skills_job_dim` tables.

![Data Warehouse Schema](../Images/1_2_Data_Warehouse.png)

- **SQL Files:** 
    - ![`01_create_tables_dw.sql`](./01_create_tables_dw.sql) - Defines star schema with four core tables
    - ![`02_load_schema_dw.sql`](./02_load_schema_dw.sql) - Extracts CSV files from Google CLoud Storage and loads into warehouse tables
- **Purposes:** Star Schema serving as single source of truth for analytical queries
- **Grain:** One row per job_posting in the fact table (`job_postings_fact`)


### Flat Mart
![Flat Mart Schema](../Images/1_2_Flat_Mart.png)

- **SQL Files:** [`03_creat_flat_mart.sql`](./03_create_flat_mart.sql) - Builds denormlaized table with all dimensions joined
- **Purposes:** Denormlaized table for quick ad-hoc queries
- **Grain:** One row per job posting with all dimension joined

### Skills Mart
Time-series skill demand analysis with additive measures.

![Skills Mart Schema](../Images/1_2_Skills_Mart.png)

- **SQL Files:** [`04_create_skills_mart.sql`](./04_create_skills_mart.sql) - Builds time-series skill demand mart
- **Purposes:** Time-series analysis of skill deman over time with additive measures
- **Grain:** `skill_id` + `month_start_date` + `job_title_short`
- **Key Features:** All measures are additive (counts/sum) for safe re-aggregation


### Priority Mart
Priority role tracking with incremental updates using `MERGE` operations

![Priority Mart Schema](../Images/1_2_Priority_Mart.png)

- **SQL Files:**
    - [`05_create_priority_mart.sql`](./05_create_priority_mart.sql) - Initial build of Priority roles and jobs snapshot
    - [`06_update_priority_mart.sql`](./06_update_priority_mart.sql) - **Incremental updates using MERGE** upsert pattern
- **Purposes:** Track Priority roles and jobs snapshot with incremental update capabilities
- **Grain:** One row per job posting with priority level assignment
- **Key Features:** **MERGE operatons with incremenetal updates-demeonstrates production ready upsert patterns (`INSERT`, `DELETE`, `UPDATE` in single statement)


## Data Engineering Skills Demonstarted

### ETL Pipeline Development
- **Extract:** Direct CSV files loading from Google Cloud Storage using DuckDB's `httpfs` extension
- **Transform:** Data normalization, type conversion (`CAST`, `DATE_TRUNC`) and quality filtering
- **Load:** Idempotent table creation with `DROP TABLE IF EXISTS` patterns
- **Incremental Updates:** `MERGE` operations for upsert patterns (`INSERT`, `UPDATE`, `DELETE` in single statement)
- **Orchestration:** Master SQL script (`build_dw_mart.sql`) for automation pipeline execution


### Dimensional Modeling

- **Star Schema Design:** Fact table (`job_postings_fact`) with dimension tables (`company_dim`, `skills_dim`)
- **Bridge Tables:** Many-to-many relationships handling (`skills_job_dim`, `bridge_company_locations`, `bridge_job_title`)
- **Grain Definitions:** Proper fact table granularity (skill + month, company + title + location + month)
- **Additive Measures:** Counts and sums that can be safely re-aggregated at any level
- **Surrogate Keys:** Sequential ID generation using CTEs with self joins


### SQL Advanced Techniques

- **DDL Operations:** `CREATE TABLES`, `DROP TABLE`, `CREATE SCHEMA` for schema management
- **DML Operations:** `INSERT INTO ... SELECT` with explicit columns mapping from CSV sources
- **MERGE Operations:** Incremental updates using `MERGE INTO` with `WHEN MATCHED`, `WHEN NOT MATCHED` and `WHEN NOT MATCHED BY SOURCE` clauses for production-ready upsert patterns
- **CTEs:** For complex transformations and boolean flag conversions
- **Date Functions:** `DATE_TRUNC('month')`, `EXTRACT('quarter)` for temporal dimension creation
- **String Functions:** `STRING_AGG` for concatenation, `REPLACE` for data cleaning
- **Boolean Logic:** `CASE WHEN` conversions for aggregating flags (remote, health insurance and no degree)



### Data Quality & Production Practices

- **Idempotency:** All scripts rerunnable without side effects
- **Data Validation:** Verification queries at each pipleine step to ensure data integrity
- **Type Safety:** Proper data type definitions (`VARCHAR`, `INTEGER`, `DOUBLE`, `BOOLEAN`, `TIMESTAMP`)
- **Schema Organization:** Separate Schemas (`flat_mart`, `skills_mart`, `priority_mart`)
- **Error Handling:** Structured script execution with clear error message and progress reporting
