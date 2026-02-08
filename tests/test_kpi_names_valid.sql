-- Test: Ensure all KPI names match expected format
-- Why: Typos or incorrect mappings should be caught

with expected_kpis as (
    select unnest(array[
        'Step 1: Lead Generation',
        'Step 2: Qualified Lead',
        'Step 2.1: Sales Call 1',
        'Step 3: Needs Assessment',
        'Step 3.1: Sales Call 2',
        'Step 4: Proposal/Quote Preparation',
        'Step 5: Negotiation',
        'Step 6: Closing',
        'Step 7: Implementation/Onboarding',
        'Step 8: Follow-up/Customer Success',
        'Step 9: Renewal/Expansion'
    ]) as kpi_name
)

select
    kpi_name as invalid_kpi_name
from {{ ref('rep_sales_funnel_monthly') }}
where kpi_name not in (select kpi_name from expected_kpis)
