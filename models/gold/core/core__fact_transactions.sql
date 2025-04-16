{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    from_address,
    to_address,
    origin_function_signature,
    VALUE,
    value_precise_raw,
    value_precise,
    tx_fee,
    tx_fee_precise,
    tx_status as tx_succeeded,
    tx_type,
    nonce,
    POSITION as tx_position,
    input_data,
    gas_price,
    gas_used,
    effective_gas_price,
    gas AS gas_limit,
    cumulative_gas_used,
    max_fee_per_gas,
    max_priority_fee_per_gas,
    r,
    s,
    v,
    transactions_id AS fact_transactions_id,
    inserted_timestamp,
    modified_timestamp
FROM
    {{ source(
        'klaytn_silver',
        'transactions'
    ) }}