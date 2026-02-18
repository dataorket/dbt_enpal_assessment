-- models/intermediate/int_deal_changes_with_labels.sql
-- Enriches deal_changes with option labels from stg_fields (e.g., lost reason)

with deal_changes as (
    select * from {{ ref('stg_deal_changes') }}
),
fields as (
    select * from {{ ref('stg_fields') }}
)

select
    dc.*,
    f.field_name as option_field_name,
    f.options as option_labels
from deal_changes dc
left join fields f
    on dc.field_key = f.field_id::varchar
