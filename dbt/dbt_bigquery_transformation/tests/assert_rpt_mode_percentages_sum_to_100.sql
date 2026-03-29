-- Fails if percentages don't add up to 100 (within rounding tolerance)
select
    sum(Percentage) as total_pct
from {{ ref('rpt_counts_by_mode') }}
having abs(sum(Percentage) - 100.0) > 0.01