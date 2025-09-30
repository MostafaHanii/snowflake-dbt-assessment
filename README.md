# **Snowflake dbt Assessment: TPC-H Data Modeling**

This repository contains a complete dbt (data build tool) project designed to transform raw TPC-H benchmark data into a structured analytics layer within Snowflake. The project adheres to best practices, implementing a **Medallion Architecture** (Staging, Silver, Gold layers) and fully documenting and testing all models.

## **1\. Project Overview and Architecture**

The pipeline transforms raw TPC-H data from the SNOWFLAKE\_SAMPLE\_DATA source into high-value analytical marts (Gold layer) for BI consumption.

### **Data Flow & Lineage**

| Layer | Model Name | Materialization | Key Transformation / Purpose |
| :---- | :---- | :---- | :---- |
| **Silver** | stg\_orders | table | Cleanses and combines raw orders and customer data. Establishes primary and foreign keys. |
| **Gold** | customer\_revenue | table | Calculates **Lifetime Total Revenue** per customer. References stg\_orders to demonstrate lineage. |
| **Gold** | customer\_revenue\_by\_nation | table | Segments total revenue by customer's nation, joining the core customer\_revenue model. |
| **Gold** | fct\_orders\_yearly | table | Aggregates key metrics (revenue, order count) to the **annual level** for trend analysis. |

## **2\. Environment Setup & Prerequisites**

### **Prerequisites**

* Snowflake Account (with permissions to create DBs/Schemas)  
* dbt Cloud or dbt CLI with the dbt-snowflake adapter  
* GitHub Repository for version control

### **dbt Profile (profiles.yml)**

The project uses the snowflake\_tpch\_demo profile. Ensure your local \~/.dbt/profiles.yml is configured with the correct Snowflake connection details:

snowflake\_tpch\_demo:  
  target: dev  
  outputs:  
    dev:  
      type: snowflake  
      account: \[YOUR\_SNOWFLAKE\_ACCOUNT\_IDENTIFIER\]   
      role: SYSADMIN  
      username: \[YOUR\_USERNAME\]  
      password: \[YOUR\_PASSWORD\]  
      warehouse: DEV\_WH  
      database: ANALYTICS\_DB  
      schema: ANALYTICS\_DEV  
      threads: 4

## **3\. How to Run the Project**

Navigate to the root directory of the project in your terminal:

### **3.1. Build Models**

Run the transformations to create all Silver and Gold layer tables in your target Snowflake schema.

dbt run

### **3.2. Run Tests**

Execute all data quality checks. This project includes standard tests (unique, not\_null) and advanced **Referential Integrity** tests.

dbt test

### **3.3. Generate Documentation**

Generate the documentation site to visualize lineage and column details.

dbt docs generate  
dbt docs serve \# To view documentation in your browser

## **4\. Data Quality & Testing Highlights**

All models and sources include extensive documentation. Data quality is enforced using:

* **Referential Integrity:** The Silver layer (stg\_orders) uses a relationships test to verify that every o\_custkey links back to a valid customer in the raw source table.  
* **Case Sensitivity Fix:** The Gold layer model tests are configured in schema.yml to specifically use **UPPERCASE** column names (e.g., C\_CUSTKEY) to successfully pass dbt tests against Snowflake's default case-sensitive storage behavior.

## **5\. Operationalization (dbt Cloud)**

The project is configured for continuous operation by connecting the GitHub repository to dbt Cloud, where a **Daily Production Build** job is scheduled to run both dbt run and dbt test commands automatically.