{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = "block_timestamp::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION",
    tags = ['decoded_logs']
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    contract_address,
    token_name AS contract_name,
    event_name,
    decoded_flat AS decoded_log,
    decoded_data AS full_decoded_log,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    topics,
    DATA,
    event_removed,
    tx_status as tx_succeeded,
    decoded_logs_id AS ez_decoded_event_logs_id,
    inserted_timestamp,
    modified_timestamp
FROM
    {{ ref('silver__decoded_logs') }}
    l
    LEFT JOIN {{ ref('silver__contracts') }} C USING (contract_address)
{% if is_incremental() %}
WHERE
    modified_timestamp > (
        SELECT
            MAX(modified_timestamp) _INSERTED_TIMESTAMP
        FROM
            {{ this }}
    )
{% endif %}