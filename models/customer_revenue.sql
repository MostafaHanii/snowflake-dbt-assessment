{{ config(
    materialized='table'
) }}

SELECT
    c.c_custkey AS c_custkey, 
    c.c_name AS c_name,
    
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
    
FROM {{ ref('stg_orders') }} stg
INNER JOIN {{ source('tpch_sf1', 'lineitem') }} l
    ON stg.o_orderkey = l.l_orderkey
INNER JOIN {{ source('tpch_sf1','customer') }} c
    ON stg.o_custkey = c.c_custkey
    
GROUP BY 1, 2
ORDER BY total_revenue DESC
