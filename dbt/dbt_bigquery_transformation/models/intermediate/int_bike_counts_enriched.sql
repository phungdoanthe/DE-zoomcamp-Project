{{ config(materialized='table') }}

with bike_counts as (
    select * from {{ ref('stg_london_bike_counts') }}
),

m_location as (
    select * from {{ ref('monitoring_location') }}
),

cleaned_and_enriched as (
    select
        {{ dbt_utils.generate_surrogate_key(['bc.SiteID', 'bc.date', 'bc.Time']) }} as MonitorID,
        bc.SiteID as SiteID,
        bc.date as Date,
        bc.year as Year,
        bc.Weather as Weather,
        bc.Time as Time,
        bc.Mode as Mode,
        bc.bike_count as Bike_count,
        CURRENT_TIMESTAMP() as updateDate,

        l.location_description as Location_desc,
        l.borough as Borough,
        l.functional_area_for_monitoring as Functional_area,
        
    from bike_counts as bc
    join m_location as l
    on bc.SiteID = l.site_id
)

select * from cleaned_and_enriched

qualify row_number() over(
    partition by SiteID, Date, Time
    order by Date, Time
) = 1