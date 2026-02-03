

with deal_stages as (
    select
        deal_id,
        field_key,
        new_value as stage_id,
        change_timestamp,
        row_number() over (partition by deal_id, new_value order by change_timestamp) as stage_entry_num
    from "postgres"."public_pipedrive_analytics"."stg_deal_changes"
    where field_key = 'stage_id'
),

deal_creation as (
    select
        deal_id,
        change_timestamp as created_at
    from "postgres"."public_pipedrive_analytics"."stg_deal_changes"
    where field_key = 'add_time'
),

stages as (
    select * from "postgres"."public_pipedrive_analytics"."stg_stages"
),

final as (
    select
        ds.deal_id,
        cast(ds.stage_id as integer) as stage_id,
        s.stage_name,
        ds.change_timestamp as stage_entry_timestamp,
        dc.created_at as deal_created_at,
        ds.stage_entry_num
    from deal_stages ds
    left join stages s on cast(ds.stage_id as integer) = s.stage_id
    left join deal_creation dc on ds.deal_id = dc.deal_id
    where ds.stage_entry_num = 1  -- Only first entry to each stage
)

select * from final