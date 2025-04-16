{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    contract_address,
    topics,
    topics[0]::STRING AS topic_0, --new column
    topics[1]::STRING AS topic_1, --new column
    topics[2]::STRING AS topic_2, --new column
    topics[3]::STRING AS topic_3, --new column
    DATA,
    event_removed,
    origin_from_address,
    origin_to_address,
    origin_function_signature,
    tx_status AS tx_succeeded,
    _log_id, --deprecate
    logs_id AS fact_event_logs_id,
    inserted_timestamp,
    modified_timestamp
FROM
    {{ source(
        'klaytn_silver',
        'logs'
    ) }}

