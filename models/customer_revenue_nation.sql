{{ config(
    materialized='table'
) }}

SELECT
    n.n_name AS customer_nation,
    SUM(cr.total_revenue) AS total_revenue_by_nation,
    COUNT(DISTINCT cr.C_CUSTKEY) AS unique_customers_in_nation

FROM {{ ref('customer_revenue') }} cr
INNER JOIN {{ source('tpch_sf1', 'customer') }} c
    ON cr.C_CUSTKEY = c.c_custkey
INNER JOIN {{ source('tpch_sf1', 'nation') }} n
    ON c.c_nationkey = n.n_nationkey

GROUP BY 1
ORDER BY total_revenue_by_nation DESC
