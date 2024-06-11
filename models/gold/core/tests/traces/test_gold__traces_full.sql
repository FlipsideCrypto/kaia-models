{{ config (
    materialized = 'view',
    tags = ['full_test']
) }}

SELECT
    *
FROM
    {{ ref('core__fact_traces') }}
WHERE 
    from_address <> '0x'
AND
    to_address <> '0x'