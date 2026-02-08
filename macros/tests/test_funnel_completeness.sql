{% test funnel_completeness(model) %}
-- Generic test: Funnel completeness (warn if early stages missing)
with expected_steps as (
    select unnest(array[1.0, 2.0, 2.1, 3.0, 3.1, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]) as funnel_step
),

actual_steps as (
    select distinct 
        month,
        funnel_step
    from {{ model }}
),

months as (
    select distinct month
    from {{ model }}
),

expected_combinations as (
    select 
        m.month,
        e.funnel_step
    from months m
    cross join expected_steps e
),

missing_steps as (
    select 
        ec.month,
        ec.funnel_step
    from expected_combinations ec
    left join actual_steps a
        on ec.month = a.month 
        and ec.funnel_step = a.funnel_step
    where a.funnel_step is null
)

select * from missing_steps
where funnel_step in (1.0, 2.0)
{% endtest %}
