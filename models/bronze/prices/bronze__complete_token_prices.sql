{{ config (
    materialized = 'view'
) }}

SELECT
    HOUR,
    token_address,
    asset_id,
    symbol,
    NAME,
    decimals,
    price,
    blockchain,
    blockchain_name,
    blockchain_id,
    is_imputed,
    is_deprecated,
    provider,
    source,
    _inserted_timestamp,
    inserted_timestamp,
    modified_timestamp,
    complete_token_prices_id,
    _invocation_id
FROM
    {{ source(
        'silver_crosschain',
        'complete_token_prices'
    ) }}
WHERE
    blockchain IN ('klaytn','kaia')
UNION ALL
SELECT
    HOUR,
    token_address,
    asset_id,
    symbol,
    NAME,
    decimals,
    price,
    blockchain,
    blockchain_name,
    blockchain_id,
    is_imputed,
    is_deprecated,
    provider,
    source,
    _inserted_timestamp,
    inserted_timestamp,
    modified_timestamp,
    complete_token_prices_id,
    _invocation_id
FROM
    {{ source(
        'silver_crosschain',
        'complete_token_prices'
    ) }}
WHERE
    blockchain = 'klay token'
AND 
    token_address = '0xe4f05a66ec68b54a58b17c22107b02e0232cc817'
