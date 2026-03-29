{{ config(materialized='table') }}

select 
    Weather,
    Year,
    sum(Bike_count) as Total_rents
from 
    {{ ref('int_bike_counts_enriched') }}
group by 1, 2