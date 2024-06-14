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
    abi_data :data :result :: STRING <> 'Max rate limit reached'
{% endif %}
LIMIT
    50
), 
all_contracts AS (
    SELECT
        contract_address
    FROM
        base
    UNION
    SELECT
        contract_address
    FROM
        {{ ref('_retry_abis') }}
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
    klaytn.live.udf_api(concat('https://api-cypress.klaytnscope.com/v2/accounts/',contract_address)) as response,
    parse_json(response:data:result:matchedContract:contractAbi) as abi_data,
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


{# 
WITH contracts AS (

    SELECT
        contract_address,
        COUNT(*)
    FROM
        {{ ref('silver__logs') }}

{% if is_incremental() %}
WHERE
    contract_address NOT IN (
        SELECT
            DISTINCT contract_address
        FROM
            {{ this }}
    )
{% endif %}
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    30
), api_call AS (
    SELECT
        live.udf_api(
            'GET',
            CONCAT(
                'https://api-cypress.klaytnscope.com/v2/accounts/',
                contract_address
            ),
            OBJECT_CONSTRUCT(
                'date',
                'Mon, 10 Jun 2024 20:30:54 GMT',
                'content-type',
                'application/json; charset=utf-8',
                'x-request-id',
                'bc35709543d6424cae0467978ab3bfa4',
                'access-control-allow-origin',
                'https://klaytnscope.com',
                'vary',
                'Origin, Accept-Encoding',
                'access-control-allow-credentials',
                'true',
                'etag',
                'W/"1aa6c-K4tAT8uD7B4oEaC1//st4p54dlQ"',
                'cf-cache-status',
                'DYNAMIC',
                'report-to',
                '{"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v4?s=%2BZJi2e9J4gCW%2B6mSXOyAQEZ65B3Ik55LYElJ7tTk75ocQO8FTYcffdiuLeD34ToRt4yN1cNCkd3xkyYl0VtqSbyQtCog5pIxk8lhpSqSd1y4j6iZRY5clPGH4Q6yXrCoIqamZkj6hM3w2%2FnWUl4%3D"}],"group":"cf-nel","max_age":604800}',
                'nel',
                '{"success_fraction":0,"report_to":"cf-nel","max_age":604800}',
                'expect-ct',
                'max-age=86400, enforce',
                'referrer-policy',
                'same-origin',
                'x-content-type-options',
                'nosniff',
                'x-frame-options',
                'SAMEORIGIN',
                'x-xss-protection',
                '1; mode=block',
                'server',
                'cloudflare',
                'cf-ray',
                '891c1f309b960fd8-LAX',
                'alt-svc',
                'h3=":443"; ma=86400'
            ),
            OBJECT_CONSTRUCT()
        ) AS resp,
        contract_address,
        SYSDATE() AS _inserted_timestamp
    FROM
        contracts
),
response_parse AS (
    SELECT
        resp :data :result :matchedContract :contractAbi :: STRING AS abi,
        resp :data :result :matchedContract :block_number :: INTEGER AS creation_block,
        resp :data :result :matchedContract :contractName :: STRING AS contract_name,
        resp :data :result :symbol :: STRING AS symbol,
        resp :data :result :tokenName :: STRING AS token_name,
        resp,
        contract_address,
        _inserted_timestamp
    FROM
        api_call
)
SELECT
    CASE
        WHEN abi IS NULL THEN 'No ABI Found'
        ELSE abi
    END AS abi,
    creation_block,
    contract_name,
    symbol,
    token_name,
    resp,
    contract_address,
    _inserted_timestamp
FROM
    response_parse #}
