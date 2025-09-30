{{config(materialized='table')}}
select 
orders.o_custkey,
customers.c_name,
orders.o_orderkey,
orders.o_orderstatus,
orders.o_totalprice,
orders.o_orderdate,
orders.o_orderpriority,
orders.o_clerk,
orders.o_shippriority,
orders.o_comment,
(year(orders.o_orderdate)) as order_year

from {{source('tpch_sf1','orders')}} orders 
inner join {{source('tpch_sf1','customer')}} customers
on orders.o_custkey = customers.c_custkey