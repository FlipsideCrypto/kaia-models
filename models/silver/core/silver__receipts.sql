{{ config(
    materialized = 'view'
) }}

SELECT
    *
FROM
    {{ source(
        'klaytn_silver',
        'receipts'
    ) }}
