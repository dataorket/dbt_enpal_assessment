
  create view "postgres"."public_pipedrive_analytics"."stg_deal_changes__dbt_tmp"
    
    
  as (
    

with source as (
    select * from "postgres"."public"."deal_changes"
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
  );