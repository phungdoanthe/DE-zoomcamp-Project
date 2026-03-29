SELECT
    SiteID,
    DATE(Date) AS date,
    EXTRACT(YEAR FROM Date) AS year,
    Weather,
    Time,
    Mode,
    SAFE_CAST(Count AS INT64) AS bike_count
FROM {{ source('raw', 'london_bike_counts') }}