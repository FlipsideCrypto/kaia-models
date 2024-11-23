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
        LOWER(CONCAT('0x', SUBSTR(segmented_data [0] :: STRING, 27, 40))) AS token0,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            segmented_data [1] :: STRING
        )) AS amount0,
        LOWER(CONCAT('0x', SUBSTR(segmented_data [2] :: STRING, 27, 40))) AS token1,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            segmented_data [3] :: STRING
        )) AS amount1,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            segmented_data [4] :: STRING
        )) AS fee,
        CONCAT('0x', SUBSTR(segmented_data [5] :: STRING, 25, 40)) AS pool_address,
        try_to_number(
        utils.udf_hex_to_int(
            's2c',
            segmented_data [6] :: STRING
        )) AS pool_id,
        _log_id,
        _inserted_timestamp
    FROM
        {{ ref ('silver__logs') }}
    WHERE
        contract_address = LOWER('0xb2ad0f20d54177916721c6b6466bce1eb1a56eef')
        AND topics [0] :: STRING = '0x0c10849134778806812b272cf9a9b3e2d56760a464b1d6169a99b2e0ed58c05d' --PairCreated
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
    pool_id,
    _log_id,
    _inserted_timestamp
FROM
    pool_creation qualify(ROW_NUMBER() over (PARTITION BY pool_address
ORDER BY
    _inserted_timestamp DESC)) = 1
