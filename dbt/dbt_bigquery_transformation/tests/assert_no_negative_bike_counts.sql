-- Fails if any negative counts exist in the intermediate model
select
    MonitorID,
    Bike_count
from {{ ref('int_bike_counts_enriched') }}
where Bike_count < 0