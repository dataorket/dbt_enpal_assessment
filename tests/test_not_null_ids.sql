-- Test: Ensure critical ID columns are not null
-- Applies to: dim_users, fct_activities, fct_deal_stage_history


select {{ test_failure_message('test_not_null_ids', 'Null user_id found in dim_users') }} as error_message, user_id as id
from {{ ref('dim_users') }}
where user_id is null


union all

select {{ test_failure_message('test_not_null_ids', 'Null activity_id found in fct_activities') }} as error_message, activity_id as id
from {{ ref('fct_activities') }}
where activity_id is null


union all

select {{ test_failure_message('test_not_null_ids', 'Null deal_id found in fct_deal_stage_history') }} as error_message, deal_id as id
from {{ ref('fct_deal_stage_history') }}
where deal_id is null
