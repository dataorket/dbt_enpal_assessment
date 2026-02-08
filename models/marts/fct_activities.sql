{{
    config(
        materialized='table'
    )
}}

with activities as (
    select * from {{ ref('int_completed_activities') }}
)

select
    activity_id,
    deal_id,
    activity_type_key,
    case
        when activity_type_key = 'meeting' then 'Step 2.1: Sales Call 1'
        when activity_type_key = 'sc_2' then 'Step 3.1: Sales Call 2'
        else activity_type_name
    end as kpi_name,
    case
        when activity_type_key = 'meeting' then 2.1
        when activity_type_key = 'sc_2' then 3.1
    end as funnel_step,
    due_timestamp as activity_at,
    is_completed,
    user_id
from activities
where activity_type_key in ('meeting', 'sc_2')
