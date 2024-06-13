{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'ez_prices_hourly_id',
    tags = ['non_realtime']
) }}

SELECT
    HOUR,
    token_address,
    symbol,
    NAME,
    decimals,
    price,
    blockchain,
    FALSE AS is_native,
    is_imputed,
    is_deprecated,
    inserted_timestamp,
    modified_timestamp,
    complete_token_prices_id AS ez_prices_hourly_id
FROM
    {{ ref('silver__complete_token_prices') }}
{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(
                modified_timestamp
            )
        FROM
            {{ this }}
    )
{% endif %}
UNION ALL
SELECT
    HOUR,
    NULL AS token_address,
    symbol,
    NAME,
    decimals,
    price,
    blockchain,
    TRUE AS is_native,
    is_imputed,
    is_deprecated,
    inserted_timestamp,
    modified_timestamp,
    complete_native_prices_id AS ez_prices_hourly_id
FROM
    {{ ref('silver__complete_native_prices') }}
{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(
                modified_timestamp
            )
        FROM
            {{ this }}
    )
{% endif %}