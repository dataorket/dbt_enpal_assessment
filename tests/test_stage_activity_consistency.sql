{{ config(enabled=false) }}
-- Test: Ensure stage-based steps have more deals than activity-based sub-steps
-- Why: Sub-steps (2.1, 3.1) should logically have <= deals than parent steps (2, 3)

with stage_counts as (
    select
        month,
        funnel_step,
        deals_count,
        case 
            when funnel_step = 2.0 then 'Stage 2'
            when funnel_step = 2.1 then 'Stage 2.1 (substep)'
            when funnel_step = 3.0 then 'Stage 3'
            when funnel_step = 3.1 then 'Stage 3.1 (substep)'
        end as stage_group
    from {{ ref('rep_sales_funnel_monthly') }}
    where funnel_step in (2.0, 2.1, 3.0, 3.1)
),

comparisons as (
    select
        s2.month,
        s2.deals_count as stage_2_count,
        s21.deals_count as stage_21_count,
        s3.deals_count as stage_3_count,
        s31.deals_count as stage_31_count
    from (select * from stage_counts where funnel_step = 2.0) s2
    left join (select * from stage_counts where funnel_step = 2.1) s21 
        on s2.month = s21.month
    left join (select * from stage_counts where funnel_step = 3.0) s3 
        on s2.month = s3.month
    left join (select * from stage_counts where funnel_step = 3.1) s31 
        on s2.month = s31.month
)

-- Flag cases where sub-step has MORE deals than parent stage (data quality issue)
select
    month,
    stage_2_count,
    stage_21_count,
    stage_3_count,
    stage_31_count,
    case 
        when stage_21_count > stage_2_count then 'Step 2.1 exceeds Step 2'
        when stage_31_count > stage_3_count then 'Step 3.1 exceeds Step 3'
    end as issue
from comparisons
where stage_21_count > stage_2_count 
   or stage_31_count > stage_3_count
