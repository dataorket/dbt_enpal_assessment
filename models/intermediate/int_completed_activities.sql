{{
    config(
        materialized='table'
    )
}}

with activity as (
    select * from {{ ref('stg_activity') }}
),

activity_types as (
    select * from {{ ref('stg_activity_types') }}
),

deal_changes as (
    select
        deal_id,
        change_timestamp as created_at
    from {{ ref('stg_deal_changes') }}
    where field_key = 'add_time'
),

final as (
    select
        a.activity_id,
        a.deal_id,
        a.activity_type_key,
        at.activity_type_name,
        a.user_id,
        a.is_completed,
        a.due_timestamp,
        dc.created_at as deal_created_at
    from activity a
    left join activity_types at on a.activity_type_key = at.activity_type_key
    left join deal_changes dc on a.deal_id = dc.deal_id
    where a.is_completed = true  -- Only completed activities
)

select * from final
