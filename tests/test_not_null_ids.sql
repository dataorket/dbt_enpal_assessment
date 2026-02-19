-- Test: Ensure critical ID columns are not null
-- Applies to: dim_users, fct_activities, fct_deal_stage_history

select 'dim_users' as table_name, user_id as id
from {{ ref('dim_users') }}
where user_id is null

union all

select 'fct_activities' as table_name, activity_id as id
from {{ ref('fct_activities') }}
where activity_id is null

union all

select 'fct_deal_stage_history' as table_name, deal_id as id
from {{ ref('fct_deal_stage_history') }}
where deal_id is null
