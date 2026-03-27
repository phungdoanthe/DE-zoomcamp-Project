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

        l."Location description" as Location_desc,
        l.Borough as Borough,
        l."Functional area for monitoring" as Functional_area,
        
    from bike_counts as bc
    join m_location as l
    on bc.SiteID = l.SiteID
)

select * from cleaned_and_enriched

quality row_number() over(
    parition by SiteID, Date, Time
    order by Date, Time
) = 1