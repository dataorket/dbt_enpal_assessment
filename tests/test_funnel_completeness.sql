{{ config(enabled=false) }}
-- Test: Ensure all expected funnel steps exist for each month
-- Why: Missing steps indicate incomplete funnel tracking

with expected_steps as (
    select unnest(array[1.0, 2.0, 2.1, 3.0, 3.1, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]) as funnel_step
),

actual_steps as (
    select distinct 
        month,
        funnel_step
    from {{ ref('rep_sales_funnel_monthly') }}
),

months as (
    select distinct month
    from {{ ref('rep_sales_funnel_monthly') }}
),

expected_combinations as (
    select 
        m.month,
        e.funnel_step
    from months m
    cross join expected_steps e
),

missing_steps as (
    select 
        ec.month,
        ec.funnel_step
    from expected_combinations ec
    left join actual_steps a
        on ec.month = a.month 
        and ec.funnel_step = a.funnel_step
    where a.funnel_step is null
)

-- This test will show which month/step combinations are missing
-- Note: Some steps may legitimately be missing (e.g., no deals reached that stage)
-- But we want to be aware of them
select * from missing_steps
where funnel_step in (1.0, 2.0)  -- Only fail if early stages are missing (critical issue)
