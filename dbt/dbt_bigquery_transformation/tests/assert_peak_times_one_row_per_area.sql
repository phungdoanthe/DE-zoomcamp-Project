-- Fails if any functional area appears more than once in peak times report
select
    Functional_area,
    count(*) as row_count
from {{ ref('rpt_peak_times_by_area') }}
group by 1
having count(*) > 1