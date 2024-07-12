{{ config(
    materialized = 'view'
) }}

SELECT
    *
FROM
    {{ source(
        'klaytn_silver',
        'confirmed_blocks'
    ) }}
