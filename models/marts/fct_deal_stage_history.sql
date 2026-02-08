{{
    config(
        materialized='table'
    )
}}

with deal_history as (
    select * from {{ ref('int_deal_stage_history') }}
),

stages as (
    select * from {{ ref('dim_stages') }}
)

select
    dh.deal_id,
    dh.stage_id,
    dh.stage_name,
    s.funnel_step,
    s.kpi_name,
    dh.stage_entry_timestamp as change_time,
    dh.stage_entry_num
from deal_history dh
left join stages s on dh.stage_id = s.stage_id
