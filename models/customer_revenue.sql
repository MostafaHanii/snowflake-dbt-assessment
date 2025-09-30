{{config(materialized='table')}}
select customers.c_custkey,
customers.c_name,
sum(lineitem.l_extendedprice*(1-lineitem.l_discount)) as total_revenue
from {{source('tpch_sf1','lineitem')}} lineitem
inner join {{source('tpch_sf1','orders')}} orders
on lineitem.l_orderkey = orders.o_orderkey
inner join {{source('tpch_sf1','customer')}} customers
on orders.o_custkey = customers.c_custkey
group by 1,2