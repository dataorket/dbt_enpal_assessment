-- Test: Ensure all foreign keys in fact tables exist in their respective dimension tables
-- Example: user_id in fct_activities must exist in dim_users

select a.user_id
from {{ ref('fct_activities') }} a
left join {{ ref('dim_users') }} u on a.user_id = u.user_id
where u.user_id is null
