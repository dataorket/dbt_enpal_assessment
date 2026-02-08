{{ config(enabled=false) }}
-- Test: Ensure funnel shows logical progression (step N >= step N+1)
-- Why: Later stages should have <= deals than earlier stages (funnel narrowing)

with funnel_by_month as (
    select
        month,
        max(case when funnel_step = 1.0 then deals_count end) as step_1,
        max(case when funnel_step = 2.0 then deals_count end) as step_2,
        max(case when funnel_step = 3.0 then deals_count end) as step_3,
        max(case when funnel_step = 4.0 then deals_count end) as step_4,
        max(case when funnel_step = 5.0 then deals_count end) as step_5,
        max(case when funnel_step = 6.0 then deals_count end) as step_6
    from {{ ref('rep_sales_funnel_monthly') }}
    where funnel_step in (1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
    group by month
)

-- Check if funnel is progressively narrowing
select
    month,
    step_1,
    step_2,
    step_3,
    step_4,
    step_5,
    step_6,
    case
        when step_2 > step_1 then 'Step 2 > Step 1'
        when step_3 > step_2 then 'Step 3 > Step 2'
        when step_4 > step_3 then 'Step 4 > Step 3'
        when step_5 > step_4 then 'Step 5 > Step 4'
        when step_6 > step_5 then 'Step 6 > Step 5'
    end as funnel_violation
from funnel_by_month
where step_2 > step_1
   or step_3 > step_2
   or step_4 > step_3
   or step_5 > step_4
   or step_6 > step_5
