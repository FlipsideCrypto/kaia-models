{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

SELECT
    tx_hash,
    block_number,
    block_timestamp,
    tx_position,
    trace_index,
    from_address,
    to_address,
    amount,
    amount_precise_raw,
    amount_precise,
    amount_usd,
    origin_from_address,
    origin_to_address,
    origin_function_signature,
    native_transfers_id AS ez_native_transfers_id,
    inserted_timestamp,
    modified_timestamp,
    identifier -- deprecate
FROM
    {{ ref('silver__native_transfers') }}
