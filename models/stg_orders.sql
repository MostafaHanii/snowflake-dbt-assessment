{{ config(
    materialized='table'
) }}

SELECT 
    orders.o_custkey,
    customers.c_name,
    orders.o_orderkey,
    orders.o_orderstatus,
    orders.o_orderdate,
    orders.o_orderpriority,
    orders.o_clerk,
    orders.o_shippriority,
    orders.o_comment,
    orders.o_totalprice AS total_price,
    EXTRACT(YEAR FROM orders.o_orderdate) AS order_year

FROM {{ source('tpch_sf1','orders') }} orders 
INNER JOIN {{ source('tpch_sf1','customer') }} customers
    ON orders.o_custkey = customers.c_custkey
