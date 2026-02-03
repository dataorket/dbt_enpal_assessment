
  
    

  create  table "postgres"."public_pipedrive_analytics"."rep_sales_funnel_monthly__dbt_tmp"
  
  
    as
  
  (
    

with deal_stage_history as (
    select * from "postgres"."public_pipedrive_analytics"."int_deal_stage_history"
),

completed_activities as (
    select * from "postgres"."public_pipedrive_analytics"."int_completed_activities"
),

-- Map stages to funnel steps
stage_funnel as (
    select
        deal_id,
        stage_id,
        stage_name,
        stage_entry_timestamp,
        date_trunc('month', stage_entry_timestamp)::date as month,
        case 
            when stage_id = 1 then 'Step 1: Lead Generation'
            when stage_id = 2 then 'Step 2: Qualified Lead'
            when stage_id = 3 then 'Step 3: Needs Assessment'
            when stage_id = 4 then 'Step 4: Proposal/Quote Preparation'
            when stage_id = 5 then 'Step 5: Negotiation'
            when stage_id = 6 then 'Step 6: Closing'
            when stage_id = 7 then 'Step 7: Implementation/Onboarding'
            when stage_id = 8 then 'Step 8: Follow-up/Customer Success'
            when stage_id = 9 then 'Step 9: Renewal/Expansion'
        end as kpi_name,
        case 
            when stage_id = 1 then 1
            when stage_id = 2 then 2
            when stage_id = 3 then 3
            when stage_id = 4 then 4
            when stage_id = 5 then 5
            when stage_id = 6 then 6
            when stage_id = 7 then 7
            when stage_id = 8 then 8
            when stage_id = 9 then 9
        end as funnel_step
    from deal_stage_history
),

-- Map completed activities to funnel steps (sub-steps)
activity_funnel as (
    select
        deal_id,
        activity_type_name,
        due_timestamp,
        date_trunc('month', due_timestamp)::date as month,
        case 
            when activity_type_key = 'meeting' and activity_type_name = 'Sales Call 1' then 'Step 2.1: Sales Call 1'
            when activity_type_key = 'sc_2' and activity_type_name = 'Sales Call 2' then 'Step 3.1: Sales Call 2'
        end as kpi_name,
        case 
            when activity_type_key = 'meeting' and activity_type_name = 'Sales Call 1' then 2.1
            when activity_type_key = 'sc_2' and activity_type_name = 'Sales Call 2' then 3.1
        end as funnel_step
    from completed_activities
    where activity_type_key in ('meeting', 'sc_2')
    and activity_type_name in ('Sales Call 1', 'Sales Call 2')
),

-- Union stage and activity funnel
combined_funnel as (
    select
        month,
        kpi_name,
        funnel_step,
        deal_id
    from stage_funnel
    where kpi_name is not null
    
    union all
    
    select
        month,
        kpi_name,
        funnel_step,
        deal_id
    from activity_funnel
    where kpi_name is not null
),

-- Aggregate by month and funnel step
final as (
    select
        month,
        kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from combined_funnel
    group by month, kpi_name, funnel_step
)

select * from final
order by month, funnel_step
  );
  