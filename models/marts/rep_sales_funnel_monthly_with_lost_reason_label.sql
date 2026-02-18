-- marts/rep_sales_funnel_monthly_with_lost_reason_label.sql
-- Monthly sales funnel report with lost reason label (parsed from stg_fields.options)

with base as (
    select * from {{ ref('rep_sales_funnel_monthly') }}
),
deal_changes as (
    select * from {{ ref('stg_deal_changes') }}
),
fields as (
    select * from {{ ref('stg_fields') }}
),
-- Join deal_changes to fields to get the options JSON
joined as (
    select
        dc.deal_id,
        dc.field_key,
        dc.new_value as option_id,
        f.options
    from deal_changes dc
    left join fields f
        on dc.field_key = f.field_id
),
-- Parse the JSON to extract the label for the option_id
exploded as (
    select
        j.deal_id,
        j.field_key,
        j.option_id,
        option_obj.value:label::string as lost_reason_label
    from joined j,
    lateral flatten(input => j.options) as option_obj
    where option_obj.value:id::string = j.option_id
)
select
    b.*,
    e.lost_reason_label
from base b
left join exploded e
    on b.deal_id = e.deal_id
