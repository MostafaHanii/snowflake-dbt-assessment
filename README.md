# **Snowflake dbt Assessment: TPC-H Data Pipeline (snowflake\_tpch\_demo)**

This repository contains a dbt (data build tool) project designed to transform raw TPC-H sample data, sourced from Snowflake, into curated Silver and Gold layer tables following a Medallion Architecture pattern.

The project demonstrates core data engineering skills including dbt setup, SQL transformation development, data quality testing, and version control integration with GitHub.

## **1\. Project Overview**

The pipeline transforms read-only source data into two new analytical tables, housed in a dedicated writable database in Snowflake:

| Layer | Model | Description | Materialization |
| :---- | :---- | :---- | :---- |
| **Bronze** | tpch\_sf1 Sources | Raw, external tables (customer, orders, lineitem). | N/A (External) |
| **Silver** | stg\_orders | Staging layer. Joins raw orders and customer data, adds derived fields like order\_year, and includes data quality checks. | Table |
| **Gold** | customer\_revenue | Final analytical table. Aggregates total calculated revenue for every customer, ready for reporting/BI consumption. | Table |

## **2\. Environment Setup & Prerequisites**

To run this project, you need:

1. **Snowflake Account:** A Snowflake account (e.g., free trial) with ACCOUNTADMIN or sufficient privileges to create databases, schemas, and warehouses.  
2. **dbt-Snowflake Adapter:** Python and the dbt CLI installed locally.

### **2.1. Snowflake Configuration**

Before running dbt, ensure the following are set up in your Snowflake account:

* **Warehouse:** A running Virtual Warehouse (e.g., DEV\_WH) configured for auto-suspend.  
* **Target Database/Schema:** A writable database (ANALYTICS\_DB) and schema (ANALYTICS\_DEV) where dbt will build the transformed models.  
* **Source Access:** The SNOWFLAKE\_SAMPLE\_DATA database must be visible and queryable by your dbt user role.

### **2.2. dbt Profile (profiles.yml)**

The dbt project is configured to use a profile named snowflake\_tpch\_demo. You must update your local \~/.dbt/profiles.yml with your Snowflake credentials:

snowflake\_tpch\_demo:  
  target: dev  
  outputs:  
    dev:  
      type: snowflake  
      account: \[YOUR\_SNOWFLAKE\_ACCOUNT\_IDENTIFIER\]   
      role: SYSADMIN                 \# Or a dedicated ETL role  
      username: \[YOUR\_USERNAME\]  
      password: \[YOUR\_PASSWORD\]  
      warehouse: DEV\_WH              \# Must match your Snowflake warehouse name  
      database: ANALYTICS\_DB         \# Writable database for model output  
      schema: ANALYTICS\_DEV          \# Schema for model output  
      threads: 4

## **3\. How to Run the Project**

Navigate to the root directory of the project in your terminal:

### **3.1. Verify Connection**

Use the debug command to confirm dbt can connect to Snowflake using your profile:

dbt debug

### **3.2. Build Models**

Run the transformations to create the stg\_orders and customer\_revenue tables in your target Snowflake schema.

dbt run

### **3.3. Run Tests**

Execute the data quality checks (unique and not\_null constraints) defined in the project's YAML files:

dbt test

### **3.4. Generate Documentation**

Generate the dbt documentation website, which provides lineage graphs and detailed column descriptions.

dbt docs generate  
dbt docs serve \# To view documentation in your browser

## **4\. Model Descriptions (Bronze → Gold)**

### **sources.yml**

Defines the starting point of the pipeline, abstracting the raw Snowflake tables (customer, orders, lineitem) under the source name tpch\_sf1.

### **stg\_orders (Silver Layer)**

This model joins orders and customer on o\_custkey/c\_custkey.

* **Key Transformations:** Adds customer\_name and derives order\_year from o\_orderdate.  
* **Data Quality:** Tested for unique and not\_null on the o\_orderkey column.

### **customer\_revenue (Gold Layer)**

This model calculates the total lifetime revenue for each customer.

* **Key Logic:** Joins orders and lineitem and applies the TPC-H revenue formula: SUM(l\_extendedprice \* (1 \- l\_discount)).  
* **Aggregation:** Grouped by c\_custkey and customer\_name.  
* **Data Quality:** Tested for not\_null on the primary key, c\_custkey.