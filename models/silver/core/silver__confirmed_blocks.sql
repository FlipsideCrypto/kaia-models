{{ config(
    materialized = 'view'
) }}

SELECT
    *
FROM
    klaytn_dev.silver.confirmed_blocks
    {# {{ source(
        'klaytn_silver',
        'confirmed_blocks'
    ) }} #}
