{{ config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = 'pool_address',
    tags = ['curated']
) }}

WITH contract_deployments AS (

    SELECT
        tx_hash,
        block_number,
        block_timestamp,
        from_address AS deployer_address,
        to_address AS contract_address,
        _inserted_timestamp
    FROM
        {{ ref('silver__traces') }}
    WHERE
        from_address = '0x5280c2d41dbbb9e17664a6c560194d99f329bbb6'
        AND to_address NOT IN (
            '0x84f8cb916eb8aa6b9ba676ac38db26fb111e524b',
            '0x442f2c12bd436cfdc736170274287cd70c5b6ab5'
        ) -- Exclude testAsset
        AND TYPE ILIKE 'create%'
        AND tx_status = TRUE
        AND trace_status = TRUE

{% if is_incremental() %}
AND _inserted_timestamp >= (
    SELECT
        MAX(_inserted_timestamp) - INTERVAL '12 hours'
    FROM
        {{ this }}
)
{% endif %}

qualify(ROW_NUMBER() over(PARTITION BY to_address
ORDER BY
    block_timestamp ASC)) = 1
)
SELECT
    tx_hash,
    block_number,
    block_timestamp,
    deployer_address,
    contract_address AS pool_address,
    _inserted_timestamp
FROM
    contract_deployments
