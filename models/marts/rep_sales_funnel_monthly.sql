{{
    config(
        materialized='table'
    )
}}

-- Stage-based funnel steps from fact table
with stage_events as (
    select
        date_trunc('month', change_time)::date as month,
        kpi_name,
        funnel_step,
        deal_id
    from {{ ref('fct_deal_stage_history') }}
),

-- Activity-based sub-steps from fact table
activity_events as (
    select
        date_trunc('month', activity_at)::date as month,
        kpi_name,
        funnel_step,
        deal_id
    from {{ ref('fct_activities') }}
    where funnel_step is not null
),

-- Union all funnel events
all_events as (
    select * from stage_events
    union all
    select * from activity_events
),

-- Aggregate by month and step
final as (
    select
        month,
        kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from all_events
    group by 1, 2, 3
)

select * from final
order by month, funnel_step
