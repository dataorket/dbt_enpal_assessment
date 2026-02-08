-- Test: Ensure deals_count is never negative
-- Why: Negative counts indicate data quality issues or logic errors

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from {{ ref('rep_sales_funnel_monthly') }}
where deals_count < 0
