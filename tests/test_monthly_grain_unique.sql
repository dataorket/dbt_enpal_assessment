-- Test: Ensure grain is unique (no duplicate month + funnel_step combinations)
-- Why: Duplicates indicate logic error in aggregation

select
    month,
    funnel_step,
    count(*) as row_count
from {{ ref('rep_sales_funnel_monthly') }}
group by month, funnel_step
having count(*) > 1
