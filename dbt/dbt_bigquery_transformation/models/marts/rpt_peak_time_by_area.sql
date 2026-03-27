{{
  config(
    materialized='incremental',
    unique_key='MonitorID',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'  )
}}

with total_rents_by_func_time as (
    select
        Functional_area,
        Time,
        sum(Bike_count) as Total_rents
    from {{ ref('int_bike_counts_enriched') }}
    group by 1, 2
),

top_renting_by_area as (
    select 
        *,
        max(Total_rents) over (partition by Functional_area, Time) as max_rents
    from 
        total_rents_by_func_time
)

select 
    Functional_area,
    Time,
    Total_rents
from 
    top_renting_by_area
where Total_rents = max_rents