{{
    config(
        materialized='table'
    )
}}

with stages as (
    select * from {{ ref('stg_stages') }}
)

select
    stage_id,
    stage_name,
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
    cast(stage_id as numeric) as funnel_step
from stages
