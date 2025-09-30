{{ config(
    materialized='table'
) }}

SELECT
    stg.order_year,
    COUNT(stg.o_orderkey) AS total_orders,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS yearly_total_revenue,
    SUM(l.l_quantity) AS yearly_total_quantity_sold

FROM {{ ref('stg_orders') }} stg
INNER JOIN {{ source('tpch_sf1', 'lineitem') }} l
    ON stg.o_orderkey = l.l_orderkey
    
GROUP BY 1
ORDER BY order_year DESC
