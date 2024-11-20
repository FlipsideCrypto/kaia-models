{{ config(
    materialized = 'incremental',
    unique_key = "contract_address",
    full_refresh = false,
    tags = ['curated']
) }}

WITH base AS (

    SELECT
        contract_address
    FROM
        {{ ref('silver__relevant_contracts') }}
    WHERE
        total_interaction_count >= 1000

{% if is_incremental() %}
EXCEPT
SELECT
    contract_address
FROM
    {{ this }}
WHERE
    abi_data :status_code :: INTEGER = 200
{% endif %}
order by total_interaction_count desc
LIMIT
    50
), 
all_contracts AS (
    SELECT
        contract_address
    FROM
        base
),
row_nos AS (
    SELECT
        contract_address,
        ROW_NUMBER() over (
            ORDER BY
                contract_address
        ) AS row_no
    FROM
        all_contracts
),
batched AS ({% for item in range(150) %}
SELECT
    rn.contract_address, 
    live.udf_api(concat('https://api-cypress.klaytnscope.com/v2/accounts/',contract_address)) as abi_data,
    SYSDATE() AS _inserted_timestamp
FROM
    row_nos rn
WHERE
    row_no = {{ item }}

    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %})
SELECT
    contract_address,
    abi_data,
    _inserted_timestamp
FROM
    batched 