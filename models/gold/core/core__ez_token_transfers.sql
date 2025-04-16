{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    {# tx_position, #} -- new column
    event_index,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    contract_address,
    from_address,
    to_address,
    raw_amount_precise,
    raw_amount,
    amount_precise,
    amount,
    amount_usd,
    decimals,
    symbol,
    transfers_id AS ez_token_transfers_id,
    inserted_timestamp,
    modified_timestamp,
    token_price, --deprecate
    has_decimal, --deprecate
    has_price, --deprecate
    _log_id, --deprecate
    _inserted_timestamp --deprecate
FROM
    {{ ref('silver__transfers') }}