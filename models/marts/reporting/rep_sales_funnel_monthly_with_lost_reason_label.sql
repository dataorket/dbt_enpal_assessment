
{{ config(materialized='table') }}

with base as (
    select * from {{ ref('rep_sales_funnel_monthly') }}
),
-- Aggregate lost reasons by month, kpi_name, funnel_step
lost_reasons as (
    select
        date_trunc('month', dc.change_timestamp)::date as month,
        fct.kpi_name,
        fct.funnel_step,
        option_obj.value->>'label' as lost_reason_label,
        count(distinct dc.deal_id) as deals_with_reason
    from {{ ref('stg_deal_changes') }} dc
    join {{ ref('stg_fields') }} f
        on dc.field_key = 'lost_reason' and f.field_id = 23
    cross join lateral jsonb_array_elements(f.options) as option_obj(value)
    join {{ ref('fct_deal_stage_history') }} fct
        on dc.deal_id = fct.deal_id
        and date_trunc('month', dc.change_timestamp)::date = date_trunc('month', fct.change_time)::date
    where dc.new_value = option_obj.value->>'id'
    group by 1,2,3,4
),
final as (
    select
        b.*,
        lr.lost_reason_label,
        lr.deals_with_reason
    from base b
    left join lost_reasons lr
        on b.month = lr.month
        and b.kpi_name = lr.kpi_name
        and b.funnel_step = lr.funnel_step
)
select * from final
