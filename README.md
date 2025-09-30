Snowflake dbt Assessment: TPC-H Data Pipeline (snowflake_tpch_demo)
This repository contains a dbt (data build tool) project designed to transform raw TPC-H sample data, sourced from Snowflake, into curated Silver and Gold layer tables following a Medallion Architecture pattern.

The project demonstrates core data engineering skills including dbt setup, SQL transformation development, data quality testing, and version control integration with GitHub.

1. Project Overview
The pipeline transforms read-only source data into two new analytical tables, housed in a dedicated writable database in Snowflake:

Layer

Model

Description

Materialization

Bronze

tpch_sf1 Sources

Raw, external tables (customer, orders, lineitem).

N/A (External)

Silver

stg_orders

Staging layer. Joins raw orders and customer data, adds derived fields like order_year, and includes data quality checks.

Table

Gold

customer_revenue

Final analytical table. Aggregates total calculated revenue for every customer, ready for reporting/BI consumption.

Table

2. Environment Setup & Prerequisites
To run this project, you need:

Snowflake Account: A Snowflake account (e.g., free trial) with ACCOUNTADMIN or sufficient privileges to create databases, schemas, and warehouses.

dbt-Snowflake Adapter: Python and the dbt CLI installed locally.

2.1. Snowflake Configuration
Before running dbt, ensure the following are set up in your Snowflake account:

Warehouse: A running Virtual Warehouse (e.g., DEV_WH) configured for auto-suspend.

Target Database/Schema: A writable database (ANALYTICS_DB) and schema (ANALYTICS_DEV) where dbt will build the transformed models.

Source Access: The SNOWFLAKE_SAMPLE_DATA database must be visible and queryable by your dbt user role.

2.2. dbt Profile (profiles.yml)
The dbt project is configured to use a profile named snowflake_tpch_demo. You must update your local ~/.dbt/profiles.yml with your Snowflake credentials:

snowflake_tpch_demo:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: [YOUR_SNOWFLAKE_ACCOUNT_IDENTIFIER] 
      role: SYSADMIN                 # Or a dedicated ETL role
      username: [YOUR_USERNAME]
      password: [YOUR_PASSWORD]
      warehouse: DEV_WH              # Must match your Snowflake warehouse name
      database: ANALYTICS_DB         # Writable database for model output
      schema: ANALYTICS_DEV          # Schema for model output
      threads: 4


3. How to Run the Project
Navigate to the root directory of the project in your terminal:

3.1. Verify Connection
Use the debug command to confirm dbt can connect to Snowflake using your profile:

dbt debug


3.2. Build Models
Run the transformations to create the stg_orders and customer_revenue tables in your target Snowflake schema.

dbt run


3.3. Run Tests
Execute the data quality checks (unique and not_null constraints) defined in the project's YAML files:

dbt test


3.4. Generate Documentation
Generate the dbt documentation website, which provides lineage graphs and detailed column descriptions.

dbt docs generate
dbt docs serve # To view documentation in your browser


4. Model Descriptions (Bronze → Gold)
sources.yml
Defines the starting point of the pipeline, abstracting the raw Snowflake tables (customer, orders, lineitem) under the source name tpch_sf1.

stg_orders (Silver Layer)
This model joins orders and customer on o_custkey/c_custkey.

Key Transformations: Adds customer_name and derives order_year from o_orderdate.

Data Quality: Tested for unique and not_null on the o_orderkey column.

customer_revenue (Gold Layer)
This model calculates the total lifetime revenue for each customer.

Key Logic: Joins orders and lineitem and applies the TPC-H revenue formula: SUM(l_extendedprice * (1 - l_discount)).

Aggregation: Grouped by c_custkey and customer_name.

Data Quality: Tested for not_null on the primary key, c_custkey.