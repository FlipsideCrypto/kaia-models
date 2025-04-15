{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    {# tx_position,  #} -- new column
    event_index,
    contract_address,
    topics,
    topics [0] :: STRING AS topic_0, --new column
    topics [1] :: STRING AS topic_1, --new column
    topics [2] :: STRING AS topic_2, --new column
    topics [3] :: STRING AS topic_3, --new column
    DATA,
    event_removed,
    origin_from_address,
    origin_to_address,
    origin_function_signature,
    tx_status AS tx_succeeded,
    event_name,
    decoded_data AS full_decoded_log,
    decoded_flat AS decoded_log,
    token_name AS contract_name,
    decoded_logs_id AS ez_decoded_event_logs_id,
    inserted_timestamp,
    modified_timestamp,
    tx_status --deprecate
FROM
    {{ ref('silver__decoded_logs') }}
    l
    LEFT JOIN {{ ref('silver__contracts') }} C USING (contract_address)