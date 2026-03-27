{{
  config(
    materialized='incremental',
    unique_key='MonitorID',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'  )
}}

select 
    Weather,
    Year,
    sum(Bike_count)
from 
    {{ ref('int_bike_counts_enriched') }}
group by 1, 2