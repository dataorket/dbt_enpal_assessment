{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('postgres_public', 'users') }}
),

renamed as (
    select
        id as user_id,
        name as user_name,
        email as user_email,
        cast(modified as timestamp) as modified_timestamp
    from source
)

select * from renamed
