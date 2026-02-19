-- Test: All completed activities should have a non-null due_timestamp

select *
from {{ ref('fct_activities') }}
where is_completed = true and activity_at is null
