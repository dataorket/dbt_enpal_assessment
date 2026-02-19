{{
    config(
        materialized='view'
    )
}}

with source as (

    select
        activity_id,
        type,
        assigned_to_user,
        deal_id,
        done,
        due_to
    from {{ source('postgres_public', 'activity') }}

),

renamed as (

    select
        activity_id,
        type as activity_type_key,
        assigned_to_user as user_id,
        deal_id,

        case 
              when done = true then true
              when done = false then false
              else null
        end as is_completed,

        cast(due_to as timestamp) as due_timestamp

    from source

)

select * from renamed
