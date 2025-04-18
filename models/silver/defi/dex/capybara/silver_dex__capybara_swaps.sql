{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'block_number',
    cluster_by = ['block_timestamp::DATE'],
    tags = ['curated','reorg']
) }}

WITH pools AS (

    SELECT
        pool_address
    FROM
        {{ ref('silver_dex__capybara_pools') }}
),
swaps_base AS (
    SELECT
        l.block_number,
        l.block_timestamp,
        l.tx_hash,
        origin_function_signature,
        origin_from_address,
        origin_to_address,
        l.event_index,
        l.contract_address,
        regexp_substr_all(SUBSTR(l.data, 3, len(l.data)), '.{64}') AS l_segmented_data,
        CONCAT('0x', SUBSTR(l.topics [1] :: STRING, 27, 40)) AS sender_address,
        CONCAT('0x', SUBSTR(l.topics [2] :: STRING, 27, 40)) AS to_address,
        CONCAT(
            '0x',
            SUBSTR(
                l_segmented_data [0] :: STRING,
                25,
                40
            )
        ) AS fromToken,
        CONCAT(
            '0x',
            SUBSTR(
                l_segmented_data [1] :: STRING,
                25,
                40
            )
        ) AS toToken,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                l_segmented_data [2] :: STRING
            )
        ) AS fromAmount,
        TRY_TO_NUMBER(
            utils.udf_hex_to_int(
                l_segmented_data [3] :: STRING
            )
        ) AS toAmount,
        concat(l.tx_hash, '-', l.event_index) AS _log_id,
        l.modified_timestamp AS _inserted_timestamp
    FROM
        {{ ref('core__fact_event_logs') }}
        l
        INNER JOIN pools p
        ON l.contract_address = p.pool_address
    WHERE
        topics [0] :: STRING = '0x7fa01e8d24e5a6ec56e00b4ff8ee7ed97e7650a7846ec494bbaa5d65f1be9ea4'
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
    tx_hash,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    event_index,
    contract_address,
    sender_address AS sender,
    to_address AS tx_to,
    fromToken AS token_in,
    toToken AS token_out,
    fromAmount AS amount_in_unadj,
    toAmount AS amount_out_unadj,
    'Swap' AS event_name,
    'capybara' AS platform,
    _log_id,
    _inserted_timestamp
FROM
    swaps_base
