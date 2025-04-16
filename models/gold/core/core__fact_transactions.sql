{{ config(
    materialized = 'incremental',
    unique_key = "block_number",
    incremental_strategy = 'delete+insert',
    cluster_by = "block_timestamp::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION",
    tags = ['non_realtime']
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
    tx_type, --new column
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
    modified_timestamp,
    block_hash, --deprecate
    POSITION --deprecate
FROM
    {{ source(
        'klaytn_silver',
        'transactions'
    ) }}

{% if is_incremental() %}
WHERE
    modified_timestamp > (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}