{{
    config(
        materialized='table'
    )
}}

with users as (
    select * from {{ ref('stg_users') }}
)

select
    user_id,
    user_name,
    user_email,
    true as is_active
from users
