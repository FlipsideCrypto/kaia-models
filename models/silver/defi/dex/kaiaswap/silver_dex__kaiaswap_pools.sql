{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'pool_address',
    tags = ['curated']
) }}

WITH pool_creation AS (

    SELECT
        block_number,
        block_timestamp,
        tx_hash,
        event_index,
        contract_address,
        regexp_substr_all(SUBSTR(DATA, 3, len(DATA)), '.{64}') AS segmented_data,
        LOWER(CONCAT('0x', SUBSTR(topics [1] :: STRING, 27, 40))) AS token0,
        LOWER(CONCAT('0x', SUBSTR(topics [2] :: STRING, 27, 40))) AS token1,
        LOWER(CONCAT('0x', SUBSTR(segmented_data [1] :: STRING, 25, 40))) AS pool_address,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            topics [3] :: STRING
        )) AS amount0,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            segmented_data [0] :: STRING
        )) AS amount1,
        _log_id,
        _inserted_timestamp
    FROM
        {{ ref ('silver__logs') }}
    WHERE
        contract_address = LOWER('0x8c7d3063579bdb0b90997e18a770eae32e1ebb08')
        AND topics [0] :: STRING = '0xf04da67755adf58739649e2fb9949a6328518141b7ac9e44aa10320688b04900' --PairCreated
        AND tx_status

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
    contract_address,
    event_index,
    token0,
    amount0,
    token1,
    amount1,
    pool_address,
    _log_id,
    _inserted_timestamp
FROM
    pool_creation qualify(ROW_NUMBER() over (PARTITION BY pool_address
ORDER BY
    _inserted_timestamp DESC)) = 1
