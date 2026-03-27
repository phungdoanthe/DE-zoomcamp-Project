-- Fails if the surrogate key has collisions (sanity check on the generate_surrogate_key logic)
select
    MonitorID,
    count(*) as cnt
from {{ ref('int_bike_counts_enriched') }}
group by 1
having count(*) > 1