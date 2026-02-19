-- Test: Ensure primary keys are unique
-- Applies to: dim_users, fct_activities

select user_id, count(*)
from {{ ref('dim_users') }}
group by user_id
having count(*) > 1

union all

select activity_id, count(*)
from {{ ref('fct_activities') }}
group by activity_id
having count(*) > 1
