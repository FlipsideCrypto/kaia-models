{{ config (
    materialized = 'view'
) }}

SELECT
    token_address,
    asset_id,
    symbol,
    NAME,
    decimals,
    blockchain,
    blockchain_name,
    blockchain_id,
    is_deprecated,
    provider,
    source,
    _inserted_timestamp,
    inserted_timestamp,
    modified_timestamp,
    complete_token_asset_metadata_id,
    _invocation_id
FROM
    {{ source(
        'silver_crosschain',
        'complete_token_asset_metadata'
    ) }}
WHERE
    blockchain IN ('klaytn','kaia')
UNION ALL
SELECT
    token_address,
    asset_id,
    symbol,
    NAME,
    decimals,
    blockchain,
    blockchain_name,
    blockchain_id,
    is_deprecated,
    provider,
    source,
    _inserted_timestamp,
    inserted_timestamp,
    modified_timestamp,
    complete_token_asset_metadata_id,
    _invocation_id
FROM
    {{ source(
        'silver_crosschain',
        'complete_token_asset_metadata'
    ) }}
WHERE
    blockchain = 'klay token'
AND 
    token_address = '0xe4f05a66ec68b54a58b17c22107b02e0232cc817'