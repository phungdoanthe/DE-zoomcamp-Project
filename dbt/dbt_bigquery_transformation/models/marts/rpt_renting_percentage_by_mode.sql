{{
  config(
    materialized='incremental',
    unique_key='MonitorID',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'  )
}}

with rents_by_mode as (
    select 
        Mode,
        sum(Bike_count) as Total_rents,
    from {{ ref('int_bike_counts_enriched') }}
    group by 1
)

select 
    Mode,
    Total_rents,
    Total_rents * 100.0 / sum(Total_rents) over () as percentage
from rents_by_mode
