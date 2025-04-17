{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'block_number',
    cluster_by = ['block_timestamp::DATE'],
    tags = ['curated','reorg']
) }}

WITH pools AS (

    SELECT
        pool_address,
        token0,
        token1
    FROM
        {{ ref('silver_dex__kaiaswap_pools') }}
),
swaps_base AS (
    SELECT
        block_number,
        origin_function_signature,
        origin_from_address,
        origin_to_address,
        topics,
        block_timestamp,
        tx_hash,
        event_index,
        contract_address,
        regexp_substr_all(SUBSTR(DATA, 3, len(DATA)), '.{64}') AS segmented_data,
        CONCAT('0x', SUBSTR(topics [1] :: STRING, 27, 40)) AS token_in,
        CONCAT('0x', SUBSTR(topics [2] :: STRING, 27, 40)) AS token_out,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                segmented_data [1] :: STRING
            )
        ) AS amount_in,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                topics [3] :: STRING
            )
        ) AS fee,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                segmented_data [2] :: STRING
            )
        ) AS amount_out,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                's2c',
                segmented_data [3] :: STRING
            )
        ) AS not_sure,
        origin_from_address AS sender,
        origin_to_address AS tx_to,
        concat(tx_hash, '-', event_index) AS _log_id,
        modified_timestamp AS _inserted_timestamp
    FROM
        {{ ref('core__fact_event_logs') }}
        INNER JOIN pools p
        ON p.pool_address = contract_address
    WHERE
        topics [0] :: STRING = '0x0fe977d619f8172f7fdbe8bb8928ef80952817d96936509f67d66346bc4cd10f'
        AND tx_succeeded

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) - INTERVAL '12 hours'
    FROM
        {{ this }}
)
AND _inserted_timestamp >= SYSDATE() - INTERVAL '7 day'
{% endif %}
)
SELECT
    block_number,
    block_timestamp,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    tx_hash,
    event_index,
    contract_address,
    sender,
    tx_to,
    token_out,
    token_in,
    amount_in AS amount_in_unadj,
    amount_out AS amount_out_unadj,
    'Swap' AS event_name,
    'kaiaswap' AS platform,
    _log_id,
    _inserted_timestamp
FROM
    swaps_base
WHERE
    token_in <> token_out
