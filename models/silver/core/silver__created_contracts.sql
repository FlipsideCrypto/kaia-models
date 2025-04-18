{{ config (
    materialized = "incremental",
    unique_key = "created_contract_address",
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = "block_timestamp::DATE",
    tags = ['non_realtime']
) }}

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    to_address AS created_contract_address,
    from_address AS creator_address,
    input AS created_contract_input,
    modified_timestamp as _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['to_address']
    ) }} AS created_contracts_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM {{ ref('core__fact_traces') }}
WHERE
    TYPE ILIKE 'create%'
    AND to_address IS NOT NULL
    AND input IS NOT NULL
    AND input != '0x'
    AND trace_succeeded
    AND tx_succeeded

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) - INTERVAL '24 hours'
    FROM
        {{ this }}
)
{% endif %}

qualify(ROW_NUMBER() over(PARTITION BY created_contract_address
ORDER BY
    _inserted_timestamp DESC)) = 1