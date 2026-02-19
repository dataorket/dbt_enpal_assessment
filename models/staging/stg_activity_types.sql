{{
    config(
        materialized='view'
    )
}}

with source as (
    select
        id,
        name,
        active,
        type
    from {{ source('postgres_public', 'activity_types') }}
),

renamed as (
    select
        id as activity_type_id,
        name as activity_type_name,
        case 
            when lower(active) = 'yes' then true
            when lower(active) = 'no' then false
            else null
        end as is_active,
        type as activity_type_key
    from source
)

select * from renamed
