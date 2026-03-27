select distinct
    bc.SiteID
from {{ ref('stg_london_bike_counts') }} bc
left join {{ ref('monitoring_location') }} l
    on bc.SiteID = l.SiteID
where l.SiteID is null