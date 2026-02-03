{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('postgres_public', 'deal_changes') }}
),

renamed as (
    select
        deal_id,
        cast(change_time as timestamp) as change_timestamp,
        changed_field_key as field_key,
        new_value
    from source
)

select * from renamed
