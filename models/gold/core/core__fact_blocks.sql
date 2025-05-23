{{ config(
    materialized = 'incremental',
    unique_key = "block_number",
    incremental_strategy = 'delete+insert',
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = "block_timestamp::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(hash,parent_hash,receipts_root,sha3_uncles)",
    tags = ['non_realtime']
) }}

SELECT
    A.block_number AS block_number,
    HASH as block_hash,
    block_timestamp,
    'mainnet' AS network,
    'kaia' AS blockchain,
    tx_count,
    difficulty,
    total_difficulty,
    extra_data,
    gas_limit,
    gas_used,
    parent_hash,
    receipts_root,
    sha3_uncles,
    SIZE,
    uncles AS uncle_blocks,
    OBJECT_CONSTRUCT(
        'baseFeePerGas',
        base_fee_per_gas,
        'difficulty',
        difficulty,
        'extraData',
        extra_data,
        'gasLimit',
        gas_limit,
        'gasUsed',
        gas_used,
        'hash',
        HASH,
        'logsBloom',
        logs_bloom,
        'miner',
        miner,
        'nonce',
        nonce,
        'number',
        NUMBER,
        'parentHash',
        parent_hash,
        'receiptsRoot',
        receipts_root,
        'sha3Uncles',
        sha3_uncles,
        'size',
        SIZE,
        'stateRoot',
        state_root,
        'timestamp',
        block_timestamp,
        'totalDifficulty',
        total_difficulty,
        'transactionsRoot',
        transactions_root,
        'uncles',
        uncles
    ) AS block_header_json, --deprecate
    hash, --deprecate
    blocks_id AS fact_blocks_id,
    {% if is_incremental() %}
        SYSDATE() AS inserted_timestamp,
        SYSDATE() AS modified_timestamp
    {% else %}
        CASE WHEN block_timestamp >= date_trunc('hour',SYSDATE()) - interval '4 hours' THEN SYSDATE() 
            ELSE GREATEST(block_timestamp, dateadd('day', -10, SYSDATE())) END AS inserted_timestamp,
        CASE WHEN block_timestamp >= date_trunc('hour',SYSDATE()) - interval '4 hours' THEN SYSDATE() 
            ELSE GREATEST(block_timestamp, dateadd('day', -10, SYSDATE())) END AS modified_timestamp
    {% endif %}
FROM
    {{ source(
        'klaytn_silver',
        'blocks'
    ) }} A

{% if is_incremental() %}
WHERE
    A.modified_timestamp > (
        SELECT
            MAX(
                modified_timestamp
            )
        FROM
            {{ this }}
    )
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY A.block_number
ORDER BY
    A.modified_timestamp DESC)) = 1
