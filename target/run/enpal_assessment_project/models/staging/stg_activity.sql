
  create view "postgres"."public_pipedrive_analytics"."stg_activity__dbt_tmp"
    
    
  as (
    

with source as (
    select * from "postgres"."public"."activity"
),

renamed as (
    select
        -- rename and transform columns here
        activity_id,
        type as activity_type_key,
        assigned_to_user as user_id,
        deal_id,
        -- convert 'True'/'False' strings to boolean
        case 
            when done = 'True' then true
            when done = 'False' then false
            else null
        end as is_completed,
        cast(due_to as timestamp) as due_timestamp
    from source
)

select * from renamed
  );