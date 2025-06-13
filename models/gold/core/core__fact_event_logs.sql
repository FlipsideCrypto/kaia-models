{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = "block_timestamp::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION",
    tags = ['non_realtime']
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    contract_address,
    topics,
    topics [0] :: STRING AS topic_0,
    --new column
    topics [1] :: STRING AS topic_1,
    --new column
    topics [2] :: STRING AS topic_2,
    --new column
    topics [3] :: STRING AS topic_3,
    --new column
    DATA,
    event_removed,
    origin_from_address,
    origin_to_address,
    origin_function_signature,
    tx_status AS tx_succeeded,
    _log_id,
    --deprecate
    logs_id AS fact_event_logs_id,

{% if is_incremental() %}
SYSDATE() AS inserted_timestamp,
SYSDATE() AS modified_timestamp
{% else %}
    CASE
        WHEN block_timestamp >= DATE_TRUNC('hour', SYSDATE()) - INTERVAL '4 hours' THEN SYSDATE()
        ELSE GREATEST(block_timestamp, DATEADD('day', -10, SYSDATE()))END AS inserted_timestamp,
        CASE
            WHEN block_timestamp >= DATE_TRUNC('hour', SYSDATE()) - INTERVAL '4 hours' THEN SYSDATE()
            ELSE GREATEST(block_timestamp, DATEADD('day', -10, SYSDATE()))END AS modified_timestamp
            {% endif %}
            FROM
                {{ source(
                    'klaytn_silver',
                    'logs'
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
