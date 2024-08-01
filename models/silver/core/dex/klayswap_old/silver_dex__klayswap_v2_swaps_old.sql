{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = ['block_timestamp::DATE'],
    tags = ['curated','reorg']
) }}

WITH pools AS (

    SELECT
        pool_address,
        token0,
        token1
    FROM
        {{ ref('silver_dex__klayswap_v2_pools') }}
),
swaps_base AS (
    SELECT
        block_number,
        origin_function_signature,
        origin_from_address,
        origin_to_address,
        block_timestamp,
        tx_hash,
        event_index,
        contract_address,
        regexp_substr_all(SUBSTR(DATA, 3, len(DATA)), '.{64}') AS segmented_data,
        CONCAT('0x', SUBSTR(segmented_data [0] :: STRING, 25, 40)) AS token0,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                segmented_data [1] :: STRING
            )
        ) AS amount0,
        CONCAT('0x', SUBSTR(segmented_data [2] :: STRING, 25, 40)) AS token1,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                segmented_data [3] :: STRING
            )
        ) AS amount1,
        origin_from_address AS sender,
        origin_to_address AS tx_to,
        _log_id,
        _inserted_timestamp
    FROM
        {{ ref('silver__logs') }}
        INNER JOIN pools p
        ON p.pool_address = contract_address
    WHERE
        topics [0] :: STRING = '0x022d176d604c15661a2acf52f28fd69bdd2c755884c08a67132ffeb8098330e0'
        AND tx_status = 'SUCCESS'

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) - INTERVAL '12 hours'
    FROM
        {{ this }}
)
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
    amount0In,
    amount1In,
    amount0Out,
    amount1Out,
    token0,
    amount0 AS amount_in_unadj,
    token1,
    amount1 AS amount_out_unadj,
    'Swap' AS event_name,
    'klayswap-v2' AS platform,
    _log_id,
    _inserted_timestamp
FROM
    swaps_base
