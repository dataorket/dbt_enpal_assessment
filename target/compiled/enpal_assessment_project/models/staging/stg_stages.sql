

with source as (
    select * from "postgres"."public"."stages"
),

renamed as (
    select
        stage_id,
        stage_name
    from source
)

select * from renamed