{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = "created_block",
    cluster_by = ['_inserted_timestamp::DATE'],
    tags = ['curated']
) }}

WITH created_pools AS (

    SELECT
        block_number AS created_block,
        block_timestamp AS created_time,
        tx_hash AS created_tx_hash,
        regexp_substr_all(SUBSTR(DATA, 3, len(DATA)), '.{64}') AS segmented_data,
        LOWER(CONCAT('0x', SUBSTR(topics [1] :: STRING, 27, 40))) AS token0_address,
        LOWER(CONCAT('0x', SUBSTR(topics [2] :: STRING, 27, 40))) AS token1_address,
        utils.udf_hex_to_int(
            's2c',
            topics [3] :: STRING
        ) :: INTEGER AS fee,
        utils.udf_hex_to_int(
            's2c',
            segmented_data [0] :: STRING
        ) :: INTEGER AS tick_spacing,
        CONCAT('0x', SUBSTR(segmented_data [1] :: STRING, 25, 40)) AS pool_address,
        utils.udf_hex_to_int(
            's2c',
            segmented_data [2] :: STRING
        ) :: INTEGER AS ex_id,
        _inserted_timestamp
    FROM
        {{ ref('silver__logs') }}
    WHERE
        topics [0] = '0x20a108faf9dc51ca2b459a109d08568e65a9cb87569b6b3a334c275d504ff94f'
        AND contract_address = '0x0af25138860689f967f142f4b06c29afc84ae910'

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(
            _inserted_timestamp
        ) - INTERVAL '36 hours'
    FROM
        {{ this }}
)
{% endif %}
),
contracts AS (
    SELECT
        LOWER(contract_address) AS address,
        token_symbol as symbol, 
        token_name as name,
        token_decimals as decimals
    FROM
        {{ ref('silver__contracts') }}
    WHERE
        token_decimals IS NOT NULL
),
token_prices AS (
    SELECT
        HOUR,
        LOWER(token_address) AS token_address,
        price
    FROM
        {{ ref('price__ez_prices_hourly') }}
    WHERE
        HOUR :: DATE IN (
            SELECT
                DISTINCT created_time :: DATE
            FROM
                created_pools
        )
)
SELECT
    'kaia' AS blockchain,
    created_block,
    created_time,
    created_tx_hash,
    '0xa15be7e90df29a4aead0c7fc86f7a9fbe6502ac9' AS factory_address,
    token0_address,
    token1_address,
    c0.symbol AS token0_symbol,
    c1.symbol AS token1_symbol,
    c0.name AS token0_name,
    c1.name AS token1_name,
    c0.decimals AS token0_decimals,
    c1.decimals AS token1_decimals,
    p0.price AS token0_price,
    p1.price AS token1_price,
    fee :: INTEGER AS fee,
        (
            fee / 10000
        ) :: FLOAT AS fee_percent,
    tick_spacing,
    div0(
        token1_price,
        token0_price
    ) AS usd_ratio,
    pool_address,
    CONCAT(
        token0_symbol,
        '-',
        token1_symbol,
        ' ',
        fee,
        ' ',
        tick_spacing
    ) AS pool_name,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['pool_address']
    ) }} AS univ3_pools_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    created_pools p
    LEFT JOIN contracts c0
    ON c0.address = p.token0_address
    LEFT JOIN contracts c1
    ON c1.address = p.token1_address
    LEFT JOIN token_prices p0
    ON p0.token_address = p.token0_address
    AND p0.hour = DATE_TRUNC(
        'hour',
        created_time
    )
    LEFT JOIN token_prices p1
    ON p1.token_address = p.token1_address
    AND p1.hour = DATE_TRUNC(
        'hour',
        created_time
    )