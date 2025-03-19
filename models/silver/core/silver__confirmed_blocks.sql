-- depends_on: {{ ref('bronze__confirm_blocks') }}
{% set build_mode = var('SILVER_CONFIRM_BLOCKS_RELOAD', false) %}

{{ config (
    materialized = "incremental",
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = ['modified_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION on equality(block_number)",
    tags = ['non_realtime']
) }}

WITH bronze_confirm_blocks AS (
    SELECT 
        block_number,
        partition_key,
        DATA:result AS block_json,
        block_json :hash :: STRING AS block_hash,
        block_json :transactions AS txs,
        _inserted_timestamp
    FROM 
    {% if is_incremental() %}
        {% if build_mode %}
            {{ ref('bronze__confirm_blocks_fr') }}
            WHERE partition_key BETWEEN (
                SELECT ROUND(MAX(block_number), -3) FROM {{ this }}
            )
            AND (
                SELECT ROUND(MAX(block_number), -3) FROM {{ this }} 
            ) + 10000000
            AND DATA:result IS NOT NULL
        {% else %}
            {{ ref('bronze__confirm_blocks') }}
            WHERE _inserted_timestamp >= (
                SELECT COALESCE(MAX(_inserted_timestamp), '1900-01-01'::TIMESTAMP) AS _inserted_timestamp
                FROM {{ this }}
            ) AND DATA:result IS NOT NULL
        {% endif %}
    {% else %}
        {{ ref('bronze__confirm_blocks_fr') }}
        WHERE DATA:result IS NOT NULL
        and partition_key <= 10000000
    {% endif %}
    qualify(ROW_NUMBER() over (PARTITION BY block_number ORDER BY _inserted_timestamp DESC)) = 1
)

SELECT 
    block_number,   
    partition_key,
    block_json,
    block_hash,
    VALUE :: STRING AS tx_hash,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(['block_number','tx_hash']) }} AS confirm_blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM bronze_confirm_blocks,
    LATERAL FLATTEN (
        input => txs
    )