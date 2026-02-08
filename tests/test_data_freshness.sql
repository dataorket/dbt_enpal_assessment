-- Test: Ensure data is recent (within last 24 months)
-- Why: Stale data indicates pipeline isn't running or data isn't being updated

with date_check as (
    select
        max(month) as latest_month,
        current_date - interval '24 months' as cutoff_date
    from {{ ref('rep_sales_funnel_monthly') }}
)

select
    latest_month,
    cutoff_date,
    case 
        when latest_month < cutoff_date then 'Data is stale (older than 24 months)'
        else 'OK'
    end as status
from date_check
where latest_month < cutoff_date
