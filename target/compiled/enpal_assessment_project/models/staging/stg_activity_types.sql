

with source as (
    select * from "postgres"."public"."activity_types"
),

renamed as (
    select
        id as activity_type_id,
        name as activity_type_name,
        case 
            when active = 'Yes' then true
            when active = 'No' then false
            else null
        end as is_active,
        type as activity_type_key
    from source
)

select * from renamed