{{ config(materialized='view') }}



with source as (
    select
        id,
        name,
        field_key,
        field_value_options
    from {{ source('postgres_public', 'fields') }}
)

select
    id as field_id,
    name as field_name,
    field_key,
    field_value_options as options
from source
