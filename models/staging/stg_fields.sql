-- models/staging/stg_fields.sql
-- Stages the fields.csv file for use in enrichment (e.g., lost reason labels)

with source as (
    select * from {{ source('raw_data', 'fields') }}
)

select
    id as field_id,
    name as field_name,
    type as field_type,
    options
from source
